<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOP Perlindungan Konsumen - Money Changer</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
            color: #0d47a1;
            line-height: 1.7;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            box-shadow: 0 10px 30px rgba(13, 71, 161, 0.15);
            border-radius: 12px;
            overflow: hidden;
        }
        
        /* Header Styles */
        header {
            background: linear-gradient(135deg, #0d47a1 0%, #1976d2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
            position: relative;
        }
        
        .protection-badge {
            position: absolute;
            top: 20px;
            right: 30px;
            background: #ff9800;
            color: #0d47a1;
            padding: 10px 20px;
            border-radius: 30px;
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .header-content {
            max-width: 800px;
            margin: 0 auto;
            position: relative;
            z-index: 2;
        }
        
        h1 {
            font-size: 2.8rem;
            margin-bottom: 15px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .subtitle {
            font-size: 1.5rem;
            margin-bottom: 30px;
            font-weight: 300;
            color: #e3f2fd;
        }
        
        .doc-info {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .info-box {
            background: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            padding: 15px 25px;
            min-width: 200px;
            backdrop-filter: blur(10px);
            transition: transform 0.3s ease;
        }
        
        .info-box:hover {
            transform: translateY(-5px);
        }
        
        /* Main Content Styles */
        .content {
            padding: 40px;
        }
        
        section {
            margin-bottom: 50px;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(13, 71, 161, 0.05);
            border-left: 5px solid #0d47a1;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        section:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(13, 71, 161, 0.1);
        }
        
        h2 {
            color: #0d47a1;
            padding-bottom: 15px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            border-bottom: 2px solid #bbdefb;
        }
        
        h2 i {
            background: #bbdefb;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #0d47a1;
        }
        
        h3 {
            color: #1976d2;
            margin: 30px 0 20px;
            padding-left: 15px;
            border-left: 4px solid #64b5f6;
        }
        
        p {
            margin-bottom: 20px;
            text-align: justify;
        }
        
        ul, ol {
            margin: 20px 0;
            padding-left: 40px;
        }
        
        li {
            margin-bottom: 12px;
            position: relative;
        }
        
        li:before {
            content: "•";
            color: #0d47a1;
            font-weight: bold;
            display: inline-block;
            width: 1em;
            margin-left: -1em;
        }
        
        /* Table Styles */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 25px 0;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            border-radius: 10px;
            overflow: hidden;
        }
        
        th {
            background-color: #0d47a1;
            color: white;
            text-align: left;
            padding: 18px;
            font-weight: 600;
        }
        
        td {
            padding: 15px 18px;
            border-bottom: 1px solid #e3f2fd;
        }
        
        tr:nth-child(even) {
            background-color: #f5f9ff;
        }
        
        tr:hover {
            background-color: #e3f2fd;
        }
        
        /* Flow Chart */
        .flow-chart {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin: 40px 0;
            box-shadow: 0 8px 20px rgba(13, 71, 161, 0.1);
            border: 1px solid #bbdefb;
        }
        
        .flow-container {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 30px;
        }
        
        .flow-step {
            background: #e3f2fd;
            border: 2px solid #0d47a1;
            border-radius: 10px;
            padding: 25px;
            width: 280px;
            position: relative;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s ease;
        }
        
        .flow-step:hover {
            transform: translateY(-10px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            background: #bbdefb;
        }
        
        .step-number {
            position: absolute;
            top: -15px;
            left: -15px;
            background: #0d47a1;
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.2rem;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        .step-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
            color: #0d47a1;
        }
        
        .step-title {
            font-weight: bold;
            margin-bottom: 15px;
            color: #0d47a1;
            font-size: 1.2rem;
        }
        
        /* Customer Rights Box */
        .rights-box {
            background: #e3f2fd;
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
            text-align: center;
            border: 2px dashed #0d47a1;
        }
        
        .rights-title {
            font-size: 1.8rem;
            color: #0d47a1;
            margin-bottom: 20px;
        }
        
        .rights-container {
            display: flex;
            justify-content: space-around;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .right-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            min-width: 200px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            flex: 1;
        }
        
        .right-icon {
            font-size: 2rem;
            color: #0d47a1;
            margin-bottom: 15px;
        }
        
        /* Warning Box */
        .warning-box {
            background: #fff8e1;
            border-left: 5px solid #ffc107;
            padding: 25px;
            border-radius: 0 8px 8px 0;
            margin: 30px 0;
            display: flex;
            gap: 20px;
            align-items: center;
        }
        
        .warning-icon {
            font-size: 2.5rem;
            color: #ff9800;
        }
        
        /* Complaint Form */
        .complaint-form {
            background: #e3f2fd;
            padding: 30px;
            border-radius: 10px;
            margin: 30px 0;
            border: 1px solid #90caf9;
        }
        
        .form-title {
            text-align: center;
            margin-bottom: 25px;
            color: #0d47a1;
            font-weight: bold;
            font-size: 1.4rem;
        }
        
        .form-row {
            display: flex;
            margin-bottom: 20px;
            gap: 20px;
        }
        
        .form-group {
            flex: 1;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #0d47a1;
        }
        
        .form-line {
            border-bottom: 1px dashed #90caf9;
            height: 1px;
            margin: 15px 0;
        }
        
        /* Footer Styles */
        footer {
            background: linear-gradient(135deg, #0d47a1 0%, #1976d2 100%);
            color: white;
            padding: 50px 40px;
            text-align: center;
        }
        
        .signature-section {
            display: flex;
            justify-content: space-around;
            margin: 40px auto;
            max-width: 900px;
            flex-wrap: wrap;
            gap: 30px;
        }
        
        .signature-box {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 12px;
            padding: 30px;
            min-width: 300px;
            flex: 1;
            backdrop-filter: blur(10px);
        }
        
        .signature-line {
            height: 2px;
            background: white;
            margin: 40px 0 25px;
        }
        
        .footer-links {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 40px;
            flex-wrap: wrap;
        }
        
        .footer-link {
            color: #bbdefb;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .footer-link:hover {
            color: white;
            text-decoration: underline;
        }
        
        /* Responsive Design */
        @media (max-width: 992px) {
            .flow-container {
                justify-content: center;
            }
            
            .rights-container {
                flex-direction: column;
                align-items: center;
            }
        }
        
        @media (max-width: 768px) {
            h1 {
                font-size: 2.2rem;
            }
            
            .subtitle {
                font-size: 1.2rem;
            }
            
            .content {
                padding: 25px;
            }
            
            section {
                padding: 20px;
            }
            
            .doc-info {
                flex-direction: column;
                align-items: center;
            }
            
            .info-box {
                width: 100%;
            }
            
            .protection-badge {
                position: static;
                margin-top: 20px;
                display: inline-flex;
            }
            
            .form-row {
                flex-direction: column;
                gap: 15px;
            }
        }
        
        @media (max-width: 480px) {
            header {
                padding: 30px 15px;
            }
            
            h1 {
                font-size: 1.8rem;
            }
            
            .content {
                padding: 15px;
            }
            
            section {
                padding: 15px;
            }
            
            ul, ol {
                padding-left: 25px;
            }
        }
        
        .service-standard {
            display: flex;
            justify-content: space-around;
            margin: 30px 0;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .standard-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            min-width: 200px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }
        
        .standard-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #0d47a1;
            margin: 10px 0;
        }
        
        .resolution-steps {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin: 25px 0;
        }
        
        .resolution-card {
            background: #e3f2fd;
            border-radius: 8px;
            padding: 20px;
            flex: 1;
            min-width: 250px;
        }
        
        .resolution-title {
            font-weight: bold;
            color: #0d47a1;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="protection-badge">
                <i class="fas fa-shield-alt"></i> HAK KONSUMEN
            </div>
            
            <div class="header-content">
                <h1>STANDAR OPERASIONAL PROSEDUR</h1>
                <div class="subtitle">PERLINDUNGAN KONSUMEN MONEY CHANGER</div>
                
                <div class="doc-info">
                    <div class="info-box">
                        <i class="fas fa-file-alt"></i> Kode Dokumen: SOP-PK-005
                    </div>
                    <div class="info-box">
                        <i class="fas fa-building"></i> PT. Audric Valasindo Kapital
                    </div>
                    <div class="info-box">
                        <i class="fas fa-calendar-alt"></i> Efektif: 19 Juni 2025
                    </div>
                </div>
            </div>
        </header>
        
        <div class="content">
            <section id="purpose">
                <h2><i class="fas fa-bullseye"></i> TUJUAN DAN RUANG LINGKUP</h2>
                <p>SOP ini bertujuan untuk menjamin perlindungan hak-hak konsumen dalam setiap transaksi di PT. Audric Valasindo Kapital dengan:</p>
                <ul>
                    <li>Memastikan transparansi informasi produk dan layanan</li>
                    <li>Melindungi data pribadi dan keamanan transaksi konsumen</li>
                    <li>Menyediakan mekanisme pengaduan yang efektif</li>
                    <li>Mencegah praktik bisnis yang merugikan konsumen</li>
                    <li>Memenuhi standar perlindungan konsumen sesuai UU No. 8 Tahun 1999</li>
                </ul>
                
                <p><strong>Ruang Lingkup:</strong> SOP ini berlaku untuk seluruh interaksi dengan konsumen di semua channel layanan (offline, online, telepon).</p>
            </section>
            
            <section id="principles">
                <h2><i class="fas fa-hand-holding-heart"></i> PRINSIP PERLINDUNGAN KONSUMEN</h2>
                
                <div class="rights-box">
                    <div class="rights-title">5 HAK DASAR KONSUMEN</div>
                    <div class="rights-container">
                        <div class="right-card">
                            <div class="right-icon"><i class="fas fa-info-circle"></i></div>
                            <div class="step-title">Hak Informasi</div>
                            <p>Mendapatkan informasi lengkap dan jelas tentang kurs, biaya, dan syarat transaksi</p>
                        </div>
                        
                        <div class="right-card">
                            <div class="right-icon"><i class="fas fa-check-circle"></i></div>
                            <div class="step-title">Hak Memilih</div>
                            <p>Memilih produk dan layanan sesuai kebutuhan tanpa tekanan</p>
                        </div>
                        
                        <div class="right-card">
                            <div class="right-icon"><i class="fas fa-shield-alt"></i></div>
                            <div class="step-title">Hak Keamanan</div>
                            <p>Mendapatkan jaminan keamanan transaksi dan perlindungan data</p>
                        </div>
                        
                        <div class="right-card">
                            <div class="right-icon"><i class="fas fa-comments"></i></div>
                            <div class="step-title">Hak Didengar</div>
                            <p>Pendapat dan keluhan konsumen harus didengar dan ditindaklanjuti</p>
                        </div>
                        
                        <div class="right-card">
                            <div class="right-icon"><i class="fas fa-gavel"></i></div>
                            <div class="step-title">Hak Ganti Rugi</div>
                            <p>Mendapatkan kompensasi jika dirugikan oleh layanan perusahaan</p>
                        </div>
                    </div>
                </div>
                
                <h3>Kewajiban Perusahaan</h3>
                <div class="flow-container">
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-comment-dots"></i></div>
                        <div class="step-title">Transparansi</div>
                        <p>Menampilkan kurs, biaya, dan syarat dengan jelas</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-lock"></i></div>
                        <div class="step-title">Keamanan</div>
                        <p>Melindungi data dan transaksi konsumen</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-balance-scale"></i></div>
                        <div class="step-title">Keadilan</div>
                        <p>Perlakuan sama untuk semua konsumen</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-headset"></i></div>
                        <div class="step-title">Responsif</div>
                        <p>Menanggapi keluhan dengan cepat dan tepat</p>
                    </div>
                </div>
            </section>
            
            <section id="standards">
                <h2><i class="fas fa-star"></i> STANDAR PELAYANAN KONSUMEN</h2>
                
                <h3>Komitmen Waktu Layanan</h3>
                <div class="service-standard">
                    <div class="standard-card">
                        <i class="fas fa-clock"></i>
                        <div>Waktu Transaksi</div>
                        <div class="standard-value">≤ 5 Menit</div>
                        <div>Per transaksi biasa</div>
                    </div>
                    
                    <div class="standard-card">
                        <i class="fas fa-phone-volume"></i>
                        <div>Respon Telepon</div>
                        <div class="standard-value">3 Ring</div>
                        <div>Maksimal</div>
                    </div>
                    
                    <div class="standard-card">
                        <i class="fas fa-envelope"></i>
                        <div>Balas Email</div>
                        <div class="standard-value">1 Hari Kerja</div>
                        <div>Maksimal</div>
                    </div>
                    
                    <div class="standard-card">
                        <i class="fas fa-comments"></i>
                        <div>Keluhan</div>
                        <div class="standard-value">2 Hari Kerja</div>
                        <div>Penyelesaian awal</div>
                    </div>
                </div>
                
                <h3>Informasi Wajib untuk Konsumen</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Informasi</th>
                            <th>Metode Penyampaian</th>
                            <th>Waktu Penyampaian</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Kurs valuta asing</td>
                            <td>Papan digital, website, aplikasi</td>
                            <td>Real-time dan sebelum transaksi</td>
                        </tr>
                        <tr>
                            <td>Biaya transaksi</td>
                            <td>Brochure, website, papan pengumuman</td>
                            <td>Sebelum transaksi</td>
                        </tr>
                        <tr>
                            <td>Syarat dan ketentuan</td>
                            <td>Website, formulir transaksi</td>
                            <td>Sebelum persetujuan transaksi</td>
                        </tr>
                        <tr>
                            <td>Prosedur pengaduan</td>
                            <td>Website, cabang, bukti transaksi</td>
                            <td>Setiap interaksi dengan konsumen</td>
                        </tr>
                        <tr>
                            <td>Kebijakan privasi</td>
                            <td>Website, formulir registrasi</td>
                            <td>Sebelum pengumpulan data pribadi</td>
                        </tr>
                    </tbody>
                </table>
            </section>
            
            <section id="complaint">
                <h2><i class="fas fa-comment-dots"></i> PROSEDUR PENANGANAN KELUHAN</h2>
                
                <h3>Alur Penanganan Keluhan</h3>
                <div class="flow-chart">
                    <div class="flow-container">
                        <div class="flow-step">
                            <div class="step-number">1</div>
                            <div class="step-icon"><i class="fas fa-comment-medical"></i></div>
                            <div class="step-title">Penerimaan</div>
                            <p>Terima keluhan melalui semua channel dan catat dalam sistem</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">2</div>
                            <div class="step-icon"><i class="fas fa-search"></i></div>
                            <div class="step-title">Verifikasi</div>
                            <p>Periksa bukti transaksi dan rekam jejak</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">3</div>
                            <div class="step-icon"><i class="fas fa-user-cog"></i></div>
                            <div class="step-title">Eskalasi</div>
                            <p>Serahkan ke PIC sesuai jenis keluhan</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">4</div>
                            <div class="step-icon"><i class="fas fa-sync-alt"></i></div>
                            <div class="step-title">Penyelesaian</div>
                            <p>Berikan solusi dalam waktu 2x24 jam</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">5</div>
                            <div class="step-icon"><i class="fas fa-check-double"></i></div>
                            <div class="step-title">Konfirmasi</div>
                            <p>Pastikan konsumen puas dengan solusi</p>
                        </div>
                    </div>
                </div>
                
                <h3>Formulir Pengaduan Konsumen</h3>
                <div class="complaint-form">
                    <div class="form-title">FORMULIR PENGADUAN KONSUMEN</div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Nama Lengkap</label>
                            <div>___________________________________</div>
                        </div>
                        <div class="form-group">
                            <label>No. Telepon/Email</label>
                            <div>___________________________________</div>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Tanggal Transaksi</label>
                            <div>___________________________________</div>
                        </div>
                        <div class="form-group">
                            <label>Lokasi Transaksi</label>
                            <div>___________________________________</div>
                        </div>
                    </div>
                    
                    <div class="form-line"></div>
                    
                    <div class="form-group">
                        <label>Jenis Pengaduan</label>
                        <div>
                            [ ] Kesalahan Kurs &nbsp;&nbsp; [ ] Kesalahan Hitung &nbsp;&nbsp; 
                            [ ] Pelayanan &nbsp;&nbsp; [ ] Keamanan &nbsp;&nbsp; 
                            [ ] Lainnya: ________
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Detail Pengaduan</label>
                        <div>________________________________________________<br>
                            ________________________________________________<br>
                            ________________________________________________</div>
                    </div>
                    
                    <div class="form-group">
                        <label>Permintaan Penyelesaian</label>
                        <div>________________________________________________<br>
                            ________________________________________________</div>
                    </div>
                    
                    <div class="form-line"></div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Tanda Tangan Pelanggan</label>
                            <div>_________________________</div>
                        </div>
                        <div class="form-group">
                            <label>Petugas Penerima</label>
                            <div>_________________________</div>
                        </div>
                    </div>
                </div>
                
                <h3>Jenis Penyelesaian Keluhan</h3>
                <div class="resolution-steps">
                    <div class="resolution-card">
                        <div class="resolution-title"><i class="fas fa-redo"></i> Perbaikan Langsung</div>
                        <p>Untuk kesalahan operasional kecil (misal: kesalahan hitung, kesalahan nominal)</p>
                    </div>
                    
                    <div class="resolution-card">
                        <div class="resolution-title"><i class="fas fa-money-bill-wave"></i> Kompensasi Finansial</div>
                        <p>Ganti rugi untuk kerugian finansial konsumen dengan persetujuan manajer</p>
                    </div>
                    
                    <div class="resolution-card">
                        <div class="resolution-title"><i class="fas fa-gift"></i> Kompensasi Non-Finansial</div>
                        <p>Voucher, layanan gratis, atau bentuk kompensasi lainnya</p>
                    </div>
                    
                    <div class="resolution-card">
                        <div class="resolution-title"><i class="fas fa-handshake"></i> Mediasi Eksternal</div>
                        <p>Melibatkan pihak ketiga untuk penyelesaian sengketa yang kompleks</p>
                    </div>
                </div>
            </section>
            
            <section id="training">
                <h2><i class="fas fa-user-graduate"></i> PELATIHAN DAN MONITORING</h2>
                
                <h3>Program Pelatihan Karyawan</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Jenis Pelatihan</th>
                            <th>Frekuensi</th>
                            <th>Materi</th>
                            <th>Peserta</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Orientasi Pelayanan</td>
                            <td>Setiap penerimaan karyawan baru</td>
                            <td>Prinsip perlindungan konsumen, standar pelayanan</td>
                            <td>Semua karyawan</td>
                        </tr>
                        <tr>
                            <td>Penanganan Keluhan</td>
                            <td>6 Bulanan</td>
                            <td>Teknik komunikasi, penyelesaian konflik, sistem pengaduan</td>
                            <td>Frontliner, CS</td>
                        </tr>
                        <tr>
                            <td>Update Regulasi</td>
                            <td>Tahunan</td>
                            <td>Perubahan UU Perlindungan Konsumen, kebijakan baru</td>
                            <td>Semua karyawan</td>
                        </tr>
                        <tr>
                            <td>Simulasi Kasus</td>
                            <td>Triwulanan</td>
                            <td>Penanganan skenario pengaduan kompleks</td>
                            <td>Manajer, Supervisor</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Monitoring Kepuasan Konsumen</h3>
                <div class="flow-container">
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-comment-alt"></i></div>
                        <div class="step-title">Survei Langsung</div>
                        <p>Kuesioner kepuasan setelah transaksi</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-mobile-alt"></i></div>
                        <div class="step-title">SMS/Email Follow-up</div>
                        <p>Survei elektronik 24 jam setelah transaksi</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-star"></i></div>
                        <div class="step-title">Review Online</div>
                        <p>Pemantauan ulasan di Google, media sosial</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-chart-pie"></i></div>
                        <div class="step-title">Analisis Data</div>
                        <p>Laporan bulanan NPS (Net Promoter Score)</p>
                    </div>
                </div>
                
                <div class="warning-box">
                    <div class="warning-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <div>
                        <h3>PENTING: SANKSI PELANGGARAN</h3>
                        <p>Pelanggaran terhadap standar perlindungan konsumen dapat berakibat:</p>
                        <ul>
                            <li>Peringatan lisan/tulisan untuk pelanggaran ringan</li>
                            <li>Pelatihan ulang wajib untuk pelanggaran sedang</li>
                            <li>Sanksi disiplin hingga pemutusan hubungan kerja untuk pelanggaran berat</li>
                            <li>Pelaporan ke Otoritas Jasa Keuangan untuk pelanggaran regulasi</li>
                        </ul>
                    </div>
                </div>
            </section>
        </div>
        
        <footer>
            <div class="signature-section">
                <div class="signature-box">
                    <p>Disusun Oleh:</p>
                    <p><strong>Manajer Layanan Pelanggan</strong></p>
                    <div class="signature-line"></div>
                    <p>Nama: ________________________</p>
                    <p>Tanda Tangan: ________________</p>
                </div>
                
                <div class="signature-box">
                    <p>Disetujui Oleh:</p>
                    <p><strong>Direktur Utama</strong></p>
                    <div class="signature-line"></div>
                    <p>Nama: ________________________</p>
                    <p>Tanda Tangan: ________________</p>
                </div>
            </div>
            
            <p>PT. Audric Valasindo Kapital</p>
            <p>Jl. Taman Galaxy Raya Blok A-21 | Telp: (021) 38711345 | Email: audricvalasindokapital@gmail.com</p>
            
            <div class="footer-links">
                <a href="#" class="footer-link">Layanan Pengaduan</a>
                <a href="#" class="footer-link">Kebijakan Privasi</a>
                <a href="#" class="footer-link">FAQ</a>
                <a href="#" class="footer-link">Hubungi Kami</a>
            </div>
            
            <p style="margin-top: 30px; color: #bbdefb;">
                "Kepuasan Anda adalah Prioritas Utama Kami"
            </p>
        </footer>
    </div>
</body>
</html>