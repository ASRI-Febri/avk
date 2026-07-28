# =============================================================================
#  deploy.ps1 - Pull-based deployment AVK (Laravel 7) untuk Windows Server
# -----------------------------------------------------------------------------
#  Jalankan dari mana saja:
#     powershell -ExecutionPolicy Bypass -File C:\xampp7\htdocs\avk\deploy.ps1
#
#  Script ini menarik kode terbaru dari GitHub (origin/main), memasang
#  dependency PHP, lalu membersihkan cache. Aset front-end (public/js, css)
#  sudah ikut di-commit sehingga TIDAK perlu npm di server.
#
#  PENTING: server ini punya DUA instalasi XAMPP -
#     C:\xampp   -> PHP 5 (aplikasi lama)
#     C:\xampp7  -> PHP 7 (AVK)
#  Karena itu php.exe dan composer SELALU dipanggil lewat path lengkap PHP 7,
#  tidak pernah mengandalkan PATH (yang bisa menunjuk ke PHP 5).
#
#  CATATAN: stored procedure / perubahan tabel SQL TIDAK diterapkan otomatis.
#           Terapkan file .sql baru lewat SSMS (lihat bagian akhir / DEPLOYMENT.md).
# =============================================================================

$ErrorActionPreference = 'Stop'

# ----------------------------- KONFIGURASI -----------------------------------
$AppPath  = 'C:\xampp7\htdocs\avk'      # folder aplikasi di server
$Branch   = 'main'
$Php      = 'C:\xampp7\php\php.exe'     # WAJIB php.exe PHP 7 (boleh diisi foldernya)
$Composer = ''                          # kosong = deteksi otomatis composer.phar/composer
# -----------------------------------------------------------------------------

function Abort($message) {
    Write-Host ""
    Write-Host "!!  DEPLOY DIBATALKAN: $message" -ForegroundColor Red
    exit 1
}

# =============================================================================
# 0) VALIDASI PHP - penyebab paling sering gagal deploy di server ini
# =============================================================================

# Bila $Php diisi foldernya saja (mis. C:\xampp7\php), lengkapi ke php.exe.
if (Test-Path -LiteralPath $Php -PathType Container) {
    $Php = Join-Path $Php 'php.exe'
}

if (-not (Test-Path -LiteralPath $Php -PathType Leaf)) {
    Abort "php.exe tidak ditemukan di '$Php'. Perbaiki variabel `$Php di bagian KONFIGURASI (contoh: C:\xampp7\php\php.exe)."
}

# Pastikan yang terpakai PHP 7, bukan PHP 5 dari C:\xampp.
$phpVersion = (& $Php -r "echo PHP_VERSION;")
if ($LASTEXITCODE -ne 0 -or -not $phpVersion) {
    Abort "Gagal menjalankan '$Php'. Pastikan file tersebut benar-benar php.exe yang berfungsi."
}
if ([int]($phpVersion.Split('.')[0]) -lt 7) {
    Abort "PHP yang terpakai versi $phpVersion (dari '$Php'). AVK butuh PHP 7.2.5+. Arahkan `$Php ke C:\xampp7\php\php.exe."
}

Set-Location $AppPath
Write-Host "==> Deploy AVK dari origin/$Branch ..." -ForegroundColor Cyan
Write-Host "    PHP $phpVersion ($Php)" -ForegroundColor DarkGray

# =============================================================================
# 1) COMMIT SAAT INI (untuk audit & daftar perubahan SQL)
# =============================================================================
# Pada deploy pertama setelah 'git init', HEAD belum menunjuk commit mana pun
# sehingga rev-parse wajar gagal - itu bukan error yang perlu menghentikan deploy.
$before = ''
try {
    $headRef = (git rev-parse --verify --quiet HEAD 2>$null)
    if ($LASTEXITCODE -eq 0 -and $headRef) { $before = (git rev-parse --short HEAD) }
} catch {
    $before = ''
}

if (-not $before) {
    Write-Host "    Deploy pertama: belum ada commit di folder ini." -ForegroundColor DarkGray
}

# =============================================================================
# 2) MAINTENANCE MODE
# =============================================================================
if (Test-Path -LiteralPath (Join-Path $AppPath 'artisan')) {
    try { & $Php artisan down --retry=15 2>$null } catch { }
}

try {
    # =========================================================================
    # 3) AMBIL KODE TERBARU
    #    reset --hard = deploy bersih: perubahan lokal di server DIBUANG.
    #    Server tidak boleh dipakai mengedit kode langsung.
    # =========================================================================
    git fetch --all --prune
    if ($LASTEXITCODE -ne 0) { throw "git fetch gagal. Periksa koneksi/autentikasi GitHub." }

    git reset --hard "origin/$Branch"
    if ($LASTEXITCODE -ne 0) { throw "git reset gagal ke origin/$Branch." }

    $after = (git rev-parse --short HEAD)
    if ($before) {
        Write-Host "    $before -> $after" -ForegroundColor DarkGray
    } else {
        Write-Host "    HEAD sekarang: $after" -ForegroundColor DarkGray
    }

    # =========================================================================
    # 4) DEPENDENCY PHP
    #    Composer dijalankan lewat php.exe PHP 7 agar tidak memakai PHP 5.
    # =========================================================================
    $composerPhar = ''
    if ($Composer -and (Test-Path -LiteralPath $Composer -PathType Leaf)) {
        $composerPhar = $Composer
    } else {
        foreach ($candidate in @(
            (Join-Path $AppPath 'composer.phar'),
            'C:\ProgramData\ComposerSetup\bin\composer.phar',
            'C:\composer\composer.phar'
        )) {
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $composerPhar = $candidate; break }
        }
    }

    if ($composerPhar) {
        Write-Host "    composer: $composerPhar" -ForegroundColor DarkGray
        & $Php $composerPhar install --no-dev --optimize-autoloader --no-interaction
        if ($LASTEXITCODE -ne 0) { throw "composer install gagal." }
    } else {
        Write-Host ""
        Write-Host "!!  composer.phar tidak ditemukan - langkah composer install DILEWATI." -ForegroundColor Yellow
        Write-Host "    Folder vendor/ yang ada tetap dipakai. Bila composer.lock berubah," -ForegroundColor Yellow
        Write-Host "    jalankan manual:  $Php composer.phar install --no-dev --optimize-autoloader" -ForegroundColor Yellow
        Write-Host ""
    }

    # =========================================================================
    # 5) BERSIHKAN CACHE LARAVEL
    # =========================================================================
    & $Php artisan config:clear
    & $Php artisan route:clear
    & $Php artisan view:clear
    & $Php artisan cache:clear

    Write-Host "==> Kode & dependency selesai diperbarui." -ForegroundColor Green
}
finally {
    # Selalu keluar dari maintenance mode walau ada error di atas.
    if (Test-Path -LiteralPath (Join-Path $AppPath 'artisan')) {
        try { & $Php artisan up } catch { }
    }
}

# =============================================================================
# 6) PENGINGAT STORED PROCEDURE / TABEL SQL
# =============================================================================
if ($before) {
    $sqlChanged = git diff --name-only "$before" "HEAD" -- 'SQLStoredProcedure/*.sql' 'SQLTable/*.sql'
    if ($sqlChanged) {
        Write-Host ""
        Write-Host "!!  ADA PERUBAHAN SQL - terapkan manual ke SQL Server (SSMS):" -ForegroundColor Yellow
        $sqlChanged | ForEach-Object { Write-Host "      $_" -ForegroundColor Yellow }
    }
} else {
    Write-Host ""
    Write-Host "!!  DEPLOY PERTAMA - tidak ada pembanding commit sebelumnya." -ForegroundColor Yellow
    Write-Host "    Pastikan seluruh tabel & stored procedure di folder SQLTable\ dan" -ForegroundColor Yellow
    Write-Host "    SQLStoredProcedure\ sudah diterapkan ke SQL Server lewat SSMS." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==> DEPLOY SELESAI." -ForegroundColor Cyan
