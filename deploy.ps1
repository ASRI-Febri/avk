# =============================================================================
#  deploy.ps1 - Pull-based deployment AVK (Laravel 7) untuk Windows Server
# -----------------------------------------------------------------------------
#  Jalankan dari mana saja:
#     powershell -ExecutionPolicy Bypass -File C:\path\ke\avk\deploy.ps1
#
#  Script ini menarik kode terbaru dari GitHub (origin/main), memasang
#  dependency PHP, lalu membersihkan cache. Aset front-end (public/js, css)
#  sudah ikut di-commit sehingga TIDAK perlu npm di server.
#
#  CATATAN: stored procedure / perubahan tabel SQL TIDAK diterapkan otomatis.
#           Terapkan file .sql baru lewat SSMS (lihat bagian akhir / DEPLOYMENT.md).
# =============================================================================

$ErrorActionPreference = 'Stop'

# ----------------------------- KONFIGURASI -----------------------------------
$AppPath  = 'C:\inetpub\wwwroot\avk'   # <-- SESUAIKAN dengan folder aplikasi di server
$Branch   = 'main'
$Php      = 'php'                       # <-- atau path lengkap, mis. 'C:\php\php.exe'
$Composer = 'composer'                  # <-- atau 'php C:\composer\composer.phar'
# -----------------------------------------------------------------------------

Set-Location $AppPath
Write-Host "==> Deploy AVK dari origin/$Branch ..." -ForegroundColor Cyan

# Tampilkan commit sebelum/sesudah untuk audit.
$before = (git rev-parse --short HEAD)

# 1) Maintenance mode (pengunjung lihat halaman 'sedang dipelihara').
& $Php artisan down --retry=15 2>$null

try {
    # 2) Ambil kode terbaru. reset --hard = deploy bersih: perubahan lokal di
    #    server DIBUANG. Server tidak boleh dipakai mengedit kode langsung.
    git fetch --all --prune
    git reset --hard "origin/$Branch"

    $after = (git rev-parse --short HEAD)
    Write-Host "    $before -> $after" -ForegroundColor DarkGray

    # 3) Dependency PHP (cepat bila composer.lock tidak berubah).
    & $Composer install --no-dev --optimize-autoloader --no-interaction

    # 4) Bersihkan cache Laravel (config/route/view/cache).
    & $Php artisan config:clear
    & $Php artisan route:clear
    & $Php artisan view:clear
    & $Php artisan cache:clear

    Write-Host "==> Kode & dependency selesai diperbarui." -ForegroundColor Green
}
finally {
    # 5) Selalu keluar dari maintenance mode walau ada error di atas.
    & $Php artisan up
}

# 6) Pengingat stored procedure: tampilkan file .sql yang berubah di commit baru.
$sqlChanged = git diff --name-only "$before" "HEAD" -- 'app/StoredProcedure/*.sql' 'SQLTable/*.sql' 'app/SQLTable/*.sql'
if ($sqlChanged) {
    Write-Host ""
    Write-Host "!!  ADA PERUBAHAN SQL - terapkan manual ke SQL Server (SSMS):" -ForegroundColor Yellow
    $sqlChanged | ForEach-Object { Write-Host "      $_" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "==> DEPLOY SELESAI." -ForegroundColor Cyan
