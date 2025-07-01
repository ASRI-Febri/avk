<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOP APU PPT - Money Changer</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #f0f9ff 0%, #e6f7ff 100%);
            color: #1a237e;
            line-height: 1.7;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            box-shadow: 0 10px 30px rgba(0, 30, 90, 0.15);
            border-radius: 12px;
            overflow: hidden;
        }
        
        /* Header Styles */
        header {
            background: linear-gradient(135deg, #1a237e 0%, #283593 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
            position: relative;
        }
        
        .compliance-badge {
            position: absolute;
            top: 20px;
            right: 30px;
            background: #4caf50;
            padding: 10px 20px;
            border-radius: 30px;
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
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
            background: rgba(255, 255, 255, 0.15);
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
            box-shadow: 0 5px 15px rgba(0, 30, 90, 0.05);
            border-left: 5px solid #1a237e;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        section:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 30, 90, 0.1);
        }
        
        h2 {
            color: #1a237e;
            padding-bottom: 15px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            border-bottom: 2px solid #e3f2fd;
        }
        
        h2 i {
            background: #e3f2fd;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #1a237e;
        }
        
        h3 {
            color: #283593;
            margin: 30px 0 20px;
            padding-left: 15px;
            border-left: 4px solid #5c6bc0;
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
            color: #1a237e;
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
            background-color: #1a237e;
            color: white;
            text-align: left;
            padding: 18px;
            font-weight: 600;
        }
        
        td {
            padding: 15px 18px;
            border-bottom: 1px solid #e8eaf6;
        }
        
        tr:nth-child(even) {
            background-color: #f5f7ff;
        }
        
        tr:hover {
            background-color: #e8eaf6;
        }
        
        /* Flow Chart */
        .flow-chart {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin: 40px 0;
            box-shadow: 0 8px 20px rgba(0, 30, 90, 0.1);
            border: 1px solid #e3f2fd;
        }
        
        .flow-container {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 30px;
        }
        
        .flow-step {
            background: #e3f2fd;
            border: 2px solid #1a237e;
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
            background: #1a237e;
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
            color: #1a237e;
        }
        
        .step-title {
            font-weight: bold;
            margin-bottom: 15px;
            color: #1a237e;
            font-size: 1.2rem;
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
        
        /* Footer Styles */
        footer {
            background: linear-gradient(135deg, #1a237e 0%, #283593 100%);
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
            
            .compliance-badge {
                position: static;
                margin-top: 20px;
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
        
        .risk-level {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: bold;
            margin-left: 10px;
        }
        
        .high-risk {
            background: #ffcdd2;
            color: #c62828;
        }
        
        .medium-risk {
            background: #fff9c4;
            color: #f57f17;
        }
        
        .low-risk {
            background: #c8e6c9;
            color: #388e3c;
        }
        
        .compliance-table th {
            background: #5c6bc0;
        }
        
        .kyc-form {
            background: #e3f2fd;
            padding: 30px;
            border-radius: 10px;
            margin: 30px 0;
        }
        
        .form-title {
            text-align: center;
            margin-bottom: 25px;
            color: #1a237e;
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
            color: #1a237e;
        }
        
        .form-line {
            border-bottom: 1px dashed #90caf9;
            height: 1px;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="compliance-badge">
                <i class="fas fa-shield-alt"></i> SOP COMPLIANCE
            </div>
            
            <div class="header-content">
                <h1>STANDAR OPERASIONAL PROSEDUR</h1>
                <div class="subtitle">ANTI PENCUCIAN UANG DAN PENCEGAHAN PENDANAAN TERORISME (APU PPT)</div>
                
                <div class="doc-info">
                    <div class="info-box">
                        <i class="fas fa-file-alt"></i> Kode Dokumen: SOP-APU-003
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
                <p>SOP ini bertujuan untuk mencegah penyalahgunaan jasa money changer sebagai sarana pencucian uang (money laundering) dan pendanaan terorisme (terrorism financing) dengan menetapkan prosedur:</p>
                <ul>
                    <li>Identifikasi dan verifikasi pelanggan (Know Your Customer/KYC)</li>
                    <li>Pemantauan transaksi secara berkelanjutan</li>
                    <li>Pelaporan transaksi mencurigakan (Suspicious Transaction Report/STR)</li>
                    <li>Pencatatan dan dokumentasi sesuai regulasi</li>
                    <li>Pembentukan budaya kepatuhan di seluruh level organisasi</li>
                </ul>
                
                <div class="warning-box">
                    <div class="warning-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <div>
                        <h3>PERINGATAN PENTING</h3>
                        <p>Pelanggaran terhadap prosedur APU PPT dapat mengakibatkan sanksi berat berupa:</p>
                        <ul>
                            <li>Denda administratif hingga Rp. 20 Miliar (UU TPPU No. 8 Tahun 2010)</li>
                            <li>Pencabutan izin usaha</li>
                            <li>Tuntutan pidana dengan ancaman hukuman penjara</li>
                        </ul>
                    </div>
                </div>
            </section>
            
            <section id="principles">
                <h2><i class="fas fa-balance-scale"></i> PRINSIP DASAR APU PPT</h2>
                <p>Setiap karyawan wajib memahami dan menerapkan 5 prinsip dasar pencegahan pencucian uang:</p>
                
                <div class="flow-container">
                    <div class="flow-step">
                        <div class="step-number">1</div>
                        <div class="step-icon"><i class="fas fa-user-check"></i></div>
                        <div class="step-title">Kebijakan KYC</div>
                        <p>Verifikasi identitas pelanggan dan pihak yang menguntungkan (beneficial owner)</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">2</div>
                        <div class="step-icon"><i class="fas fa-chart-line"></i></div>
                        <div class="step-title">Due Diligence</div>
                        <p>Pemantauan transaksi secara berkelanjutan dan penilaian risiko pelanggan</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">3</div>
                        <div class="step-icon"><i class="fas fa-flag"></i></div>
                        <div class="step-title">Pelaporan</div>
                        <p>Pelaporan transaksi mencurigakan (STR) dan transaksi tunai bernilai besar (CTR)</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">4</div>
                        <div class="step-icon"><i class="fas fa-archive"></i></div>
                        <div class="step-title">Pencatatan</div>
                        <p>Penyimpanan dokumen dan rekaman transaksi minimal 5 tahun</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">5</div>
                        <div class="step-icon"><i class="fas fa-user-graduate"></i></div>
                        <div class="step-title">Pelatihan</div>
                        <p>Sosialisasi dan pelatihan APU PPT berkala untuk seluruh karyawan</p>
                    </div>
                </div>
            </section>
            
            <section id="kyc">
                <h2><i class="fas fa-id-card"></i> PROSEDUR IDENTIFIKASI PELANGGAN (KYC)</h2>
                
                <h3>1. Identifikasi Dasar</h3>
                <p>Wajib dilakukan untuk semua transaksi:</p>
                <ul>
                    <li>Mengisi formulir identifikasi pelanggan</li>
                    <li>Meminta dokumen asli identitas (KTP/Paspor)</li>
                    <li>Memverifikasi keaslian dokumen dengan alat pendeteksi</li>
                    <li>Mencatat nomor dokumen dan informasi lengkap</li>
                </ul>
                
                <h3>2. Enhanced Due Diligence (EDD)</h3>
                <p>Wajib dilakukan untuk:</p>
                <ul>
                    <li>Transaksi ≥ Rp. 500.000.000 <span class="risk-level high-risk">RISIKO TINGGI</span></li>
                    <li>Pelanggan dari negara high-risk (daftar FATF)</li>
                    <li>Politically Exposed Persons (PEP) dan keluarganya</li>
                    <li>Transaksi yang tidak sesuai profil pelanggan</li>
                </ul>
                <p>Prosedur EDD mencakup:</p>
                <ul>
                    <li>Verifikasi sumber dana dan tujuan transaksi</li>
                    <li>Persetujuan dari Compliance Officer</li>
                    <li>Pemantauan khusus selama 6 bulan</li>
                </ul>
                
                <h3>3. Formulir Identifikasi Pelanggan</h3>
                <div class="kyc-form">
                    <div class="form-title">FORMULIR VERIFIKASI PELANGGAN (CDD)</div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Nama Lengkap</label>
                            <div>___________________________________</div>
                        </div>
                        <div class="form-group">
                            <label>Jenis Identitas</label>
                            <div>[ ] KTP &nbsp; [ ] SIM &nbsp; [ ] Paspor &nbsp; [ ] Lainnya</div>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Nomor Identitas</label>
                            <div>___________________________________</div>
                        </div>
                        <div class="form-group">
                            <label>Tanggal Lahir</label>
                            <div>___________________________________</div>
                        </div>
                    </div>
                    
                    <div class="form-line"></div>
                    
                    <div class="form-group">
                        <label>Alamat Lengkap</label>
                        <div>___________________________________</div>
                        <div>___________________________________</div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Pekerjaan</label>
                            <div>___________________________________</div>
                        </div>
                        <div class="form-group">
                            <label>Sumber Dana</label>
                            <div>[ ] Gaji &nbsp; [ ] Usaha &nbsp; [ ] Investasi &nbsp; [ ] Lainnya</div>
                        </div>
                    </div>
                    
                    <div class="form-line"></div>
                    
                    <div class="form-group">
                        <label>Detail Transaksi</label>
                        <div>Mata Uang: __________ Jumlah: __________</div>
                    </div>
                    
                    <div class="form-group">
                        <label>Tujuan Transaksi</label>
                        <div>[ ] Tabungan &nbsp; [ ] Investasi &nbsp; [ ] Bisnis &nbsp; [ ] Pendidikan &nbsp; [ ] Lainnya</div>
                    </div>
                    
                    <div class="form-line"></div>
                    
                    <div class="form-group">
                        <label>Pernyataan Pelanggan</label>
                        <p>Saya menyatakan bahwa informasi di atas benar dan dana yang digunakan berasal dari sumber yang sah.</p>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Tanda Tangan Pelanggan</label>
                            <div>_________________________</div>
                        </div>
                        <div class="form-group">
                            <label>Petugas</label>
                            <div>_________________________</div>
                        </div>
                    </div>
                </div>
            </section>
            
            <section id="monitoring">
                <h2><i class="fas fa-binoculars"></i> PEMANTAUAN TRANSAKSI</h2>
                
                <h3>Indikator Transaksi Mencurigakan</h3>
                <table class="compliance-table">
                    <thead>
                        <tr>
                            <th>Kategori</th>
                            <th>Contoh Perilaku Mencurigakan</th>
                            <th>Tingkat Risiko</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Pola Transaksi</strong></td>
                            <td>Transaksi terpecah-pecah di bawah batas pelaporan, transaksi berulang tanpa alasan jelas</td>
                            <td><span class="risk-level high-risk">Tinggi</span></td>
                        </tr>
                        <tr>
                            <td><strong>Perilaku Pelanggan</strong></td>
                            <td>Gugup, terburu-buru, menghindari kontak mata, tidak memahami detail transaksi</td>
                            <td><span class="risk-level medium-risk">Sedang</span></td>
                        </tr>
                        <tr>
                            <td><strong>Asal Dana</strong></td>
                            <td>Sumber dana tidak jelas, tidak sesuai profil pekerjaan, menggunakan pihak ketiga tanpa alasan</td>
                            <td><span class="risk-level high-risk">Tinggi</span></td>
                        </tr>
                        <tr>
                            <td><strong>Identitas</strong></td>
                            <td>Dokumen kadaluarsa, foto tidak sesuai, informasi identitas tidak konsisten</td>
                            <td><span class="risk-level high-risk">Tinggi</span></td>
                        </tr>
                        <tr>
                            <td><strong>Negara Asal</strong></td>
                            <td>Pelanggan dari negara high-risk FATF atau sanksi PBB</td>
                            <td><span class="risk-level high-risk">Tinggi</span></td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Prosedur Pelaporan Transaksi Mencurigakan (STR)</h3>
                <div class="flow-chart">
                    <div class="flow-container">
                        <div class="flow-step">
                            <div class="step-number">1</div>
                            <div class="step-icon"><i class="fas fa-clipboard-list"></i></div>
                            <div class="step-title">Identifikasi</div>
                            <p>Petugas mengidentifikasi indikasi transaksi mencurigakan</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">2</div>
                            <div class="step-icon"><i class="fas fa-file-alt"></i></div>
                            <div class="step-title">Dokumentasi</div>
                            <p>Mengumpulkan bukti dan mengisi formulir laporan internal</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">3</div>
                            <div class="step-icon"><i class="fas fa-user-shield"></i></div>
                            <div class="step-title">Review CO</div>
                            <p>Compliance Officer mengevaluasi dan memutuskan pelaporan</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">4</div>
                            <div class="step-icon"><i class="fas fa-paper-plane"></i></div>
                            <div class="step-title">Pelaporan</div>
                            <p>Mengirim STR ke PPATK maksimal 3x24 jam setelah identifikasi</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">5</div>
                            <div class="step-icon"><i class="fas fa-lock"></i></div>
                            <div class="step-title">Pemblokiran</div>
                            <p>Membekukan transaksi jika diperintahkan otoritas</p>
                        </div>
                    </div>
                </div>
            </section>
            
            <section id="training">
                <h2><i class="fas fa-graduation-cap"></i> PELATIHAN DAN AUDIT</h2>
                
                <h3>Program Pelatihan APU PPT</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Jenis Pelatihan</th>
                            <th>Peserta</th>
                            <th>Frekuensi</th>
                            <th>Materi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Induksi</strong></td>
                            <td>Karyawan baru</td>
                            <td>Sebelum mulai kerja</td>
                            <td>Dasar APU PPT, SOP KYC, kewajiban hukum</td>
                        </tr>
                        <tr>
                            <td><strong>Reguler</strong></td>
                            <td>Semua karyawan</td>
                            <td>Tahunan</td>
                            <td>Update regulasi, studi kasus, teknik identifikasi</td>
                        </tr>
                        <tr>
                            <td><strong>Lanjutan</strong></td>
                            <td>Compliance Officer, Supervisor</td>
                            <td>6 bulan</td>
                            <td>Analisis transaksi, investigasi STR, manajemen risiko</td>
                        </tr>
                        <tr>
                            <td><strong>Simulasi</strong></td>
                            <td>Frontliner, Teller</td>
                            <td>Triwulanan</td>
                            <td>Penanganan skenario transaksi mencurigakan</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Prosedur Audit Kepatuhan</h3>
                <ul>
                    <li><strong>Audit Internal:</strong> Dilakukan setiap 3 bulan oleh tim audit internal</li>
                    <li><strong>Audit Eksternal:</strong> Dilakukan tahunan oleh auditor independen</li>
                    <li><strong>Pemeriksaan Regulator:</strong> Koordinasi dengan PPATK, BI, dan OJK</li>
                    <li><strong>Temuan Audit:</strong> Wajib ditindaklanjuti maksimal 14 hari kerja</li>
                </ul>
                
                <div class="warning-box">
                    <div class="warning-icon">
                        <i class="fas fa-user-secret"></i>
                    </div>
                    <div>
                        <h3>KERAHASIAAN LAPORAN</h3>
                        <p>Setiap karyawan dilarang keras memberitahu pelanggan atau pihak lain tentang:</p>
                        <ul>
                            <li>Adanya laporan STR yang telah dibuat</li>
                            <li>Proses investigasi yang sedang berlangsung</li>
                            <li>Permintaan informasi dari otoritas terkait</li>
                        </ul>
                        <p>Pelanggaran kerahasiaan dapat dikenakan sanksi pidana sesuai UU TPPU.</p>
                    </div>
                </div>
            </section>
            
            <section id="regulation">
                <h2><i class="fas fa-gavel"></i> REGULASI DAN SANKSI</h2>
                
                <h3>Dasar Hukum APU PPT</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Regulasi</th>
                            <th>Isi Penting</th>
                            <th>Otoritas Pengawas</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>UU No. 8 Tahun 2010</strong><br>(TPPU)</td>
                            <td>Pencegahan dan pemberantasan pencucian uang</td>
                            <td>PPATK</td>
                        </tr>
                        <tr>
                            <td><strong>POJK 12/POJK.01/2017</strong></td>
                            <td>Penerapan program APU dan PPT bagi Penyedia Jasa Keuangan</td>
                            <td>OJK</td>
                        </tr>
                        <tr>
                            <td><strong>PBI No. 22/19/PBI/2019</strong></td>
                            <td>Penyelenggaraan usaha money changer</td>
                            <td>Bank Indonesia</td>
                        </tr>
                        <tr>
                            <td><strong>SE BI No. 21/32/DPU</strong></td>
                            <td>Pedoman KYC dan identifikasi nasabah</td>
                            <td>Bank Indonesia</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Sanksi Pelanggaran</h3>
                <div class="flow-container">
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-money-bill-wave"></i></div>
                        <div class="step-title">Sanksi Administratif</div>
                        <p>Denda hingga Rp 1 Miliar, pembekuan izin usaha</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-gavel"></i></div>
                        <div class="step-title">Sanksi Pidana</div>
                        <p>Penjara 5-15 tahun dan denda Rp 5-15 Miliar (UU TPPU Pasal 3-5)</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-icon"><i class="fas fa-user-slash"></i></div>
                        <div class="step-title">Sanksi Individu</div>
                        <p>Pencabutan izin profesi, larangan menjadi pengurus perusahaan</p>
                    </div>
                </div>
            </section>
        </div>
        
        <footer>
            <div class="signature-section">
                <div class="signature-box">
                    <p>Disusun Oleh:</p>
                    <p><strong>Compliance Officer</strong></p>
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
                <a href="#" class="footer-link">Kebijakan Privasi</a>
                <a href="#" class="footer-link">SOP Terkait</a>
                <a href="#" class="footer-link">Kode Etik Perusahaan</a>
                <a href="#" class="footer-link">Portal Compliance</a>
            </div>
            
            <p style="margin-top: 30px; color: #bbdefb;">
                Dokumen ini merupakan rahasia perusahaan dan hanya untuk penggunaan internal
            </p>
        </footer>
    </div>
</body>
</html>