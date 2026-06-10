# Deployment AVK — Windows Server (pull dari GitHub)

Aplikasi sudah ter-deploy di VPS Windows Server 2016 dan terhubung ke repo
GitHub (`origin/main`). Dokumen ini menjelaskan cara mempermudah deployment:
**push dari lokal → pull di server**.

Kunci yang membuat ini sederhana:

- Aset hasil build (`public/js`, `public/css`, `public/assets`) **ikut di-commit**,
  sehingga **server tidak perlu Node/npm**.
- `.env`, `vendor/`, `node_modules/` ada di `.gitignore` → `git pull` **tidak**
  menimpa konfigurasi/secret di server.

---

## 0) Alur kerja singkat

**Di komputer developer (mac/Windows):**

```bash
# Bila mengubah file di resources/js atau resources/sass:
npm run production          # build aset ke public/js & public/css
git add -A
git commit -m "Fitur X"
git push origin main
```

**Di server (VPS), jalankan salah satu cara di bagian 3.**

> Penting: build aset (`npm run production`) dilakukan di **lokal** lalu di-commit.
> Jangan mengedit kode langsung di server — server hanya menarik (pull).

---

## 1) Persiapan satu kali di server

### a. Git for Windows
Pastikan `git`, `php`, dan `composer` bisa dipanggil dari PowerShell:

```powershell
git --version
php --version
composer --version
```

### b. Autentikasi GitHub (repo privat)
Cara termudah — **Personal Access Token (PAT)** disimpan oleh Git Credential Manager:

1. Buat token di GitHub: Settings → Developer settings →
   **Fine-grained tokens** → akses **Contents: Read-only** untuk repo `avk`.
2. Pertama kali `git fetch`, Windows akan meminta login → tempel **token**
   sebagai password. Setelahnya tersimpan dan tidak ditanya lagi.

> Alternatif lebih aman: **deploy key** (SSH key read-only khusus server).

### c. Pastikan remote benar
```powershell
cd C:\inetpub\wwwroot\avk      # sesuaikan path
git remote -v                  # harus menunjuk ke github.com/ASRI-Febri/avk.git
```

### d. Sesuaikan path di `deploy.ps1`
Edit variabel `$AppPath`, `$Php`, `$Composer` di bagian atas `deploy.ps1`.

---

## 2) Yang TIDAK ikut ter-deploy otomatis

| Item | Alasan | Tindakan |
|------|--------|----------|
| `.env` | di-gitignore | Diatur sekali di server; tidak tersentuh pull |
| `vendor/` | di-gitignore | `composer install` (sudah ada di `deploy.ps1`) |
| **Stored procedure / tabel SQL** | DB terpisah | **Terapkan manual** file `.sql` baru via SSMS |

`deploy.ps1` akan **menampilkan daftar file `.sql` yang berubah** pada commit
baru, sebagai pengingat untuk diterapkan ke SQL Server.

---

## 3) Cara menjalankan deployment

### Cara A — Manual (paling sederhana, paling aman)
RDP ke server, lalu:

```powershell
powershell -ExecutionPolicy Bypass -File C:\inetpub\wwwroot\avk\deploy.ps1
```

Script otomatis: maintenance mode → `git reset --hard origin/main` →
`composer install` → bersihkan cache → kembali online.

### Cara B — Otomatis penuh (GitHub Actions self-hosted runner)
Agar setiap `git push` ke `main` langsung men-deploy:

1. Pasang runner: repo GitHub → **Settings → Actions → Runners → New
   self-hosted runner → Windows**, ikuti perintahnya (jalankan sebagai service).
2. Buat workflow `.github/workflows/deploy.yml`:

   ```yaml
   name: Deploy
   on:
     push:
       branches: [ main ]
   jobs:
     deploy:
       runs-on: [self-hosted, windows]
       steps:
         - name: Jalankan deploy.ps1
           run: powershell -ExecutionPolicy Bypass -File C:\inetpub\wwwroot\avk\deploy.ps1
   ```

   Setelah ini, push ke `main` otomatis memicu deploy di server.
   (Tetap terapkan SQL `.sql` baru secara manual.)

### Cara C — Scheduled Task (pull berkala)
Task Scheduler → buat task yang menjalankan `deploy.ps1` tiap mis. 10 menit.
Sederhana, tapi tanpa kontrol kapan rilis — kurang disarankan untuk produksi.

**Rekomendasi:** mulai dengan **Cara A**; naik ke **Cara B** bila ingin otomatis.

---

## 4) Catatan tambahan

- **Izin folder**: pastikan user IIS/Apache punya akses tulis ke `storage\` dan
  `bootstrap\cache\`. Ini hanya perlu diatur sekali (pull tidak mengubahnya).
- **`route:cache` dihindari** di script karena beberapa route memakai closure
  (Laravel 7 akan gagal cache route bila ada closure). Cukup `route:clear`.
- **Rollback cepat** bila rilis bermasalah:
  ```powershell
  git reset --hard <commit-lama>
  php artisan up
  ```
- **Hygiene `.DS_Store`** (opsional): file `.DS_Store` masih ter-track dari masa
  lalu. Untuk berhenti melacaknya:
  ```bash
  git rm -r --cached --ignore-unmatch '*.DS_Store'
  git commit -m "Stop tracking .DS_Store"
  ```
