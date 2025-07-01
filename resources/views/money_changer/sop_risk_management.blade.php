<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOP Manajemen Risiko - Money Changer</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: #f0f7ff;
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            box-shadow: 0 0 25px rgba(0, 0, 100, 0.1);
            border-radius: 10px;
            overflow: hidden;
        }
        
        /* Header Styles */
        header {
            background: linear-gradient(135deg, #1e3a8a, #3b82f6);
            color: white;
            padding: 40px 30px;
            text-align: center;
            position: relative;
        }
        
        .company-logo {
            position: absolute;
            top: 20px;
            left: 30px;
            font-size: 24px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .header-content {
            max-width: 800px;
            margin: 0 auto;
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
            border-radius: 8px;
            padding: 15px 25px;
            min-width: 200px;
            backdrop-filter: blur(10px);
        }
        
        /* Main Content Styles */
        .content {
            padding: 40px;
        }
        
        section {
            margin-bottom: 50px;
        }
        
        h2 {
            color: #1e3a8a;
            border-bottom: 2px solid #3b82f6;
            padding-bottom: 10px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        h2 i {
            background: #dbeafe;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        h3 {
            color: #2563eb;
            margin: 25px 0 15px;
            padding-left: 10px;
            border-left: 4px solid #3b82f6;
        }
        
        p {
            margin-bottom: 15px;
            text-align: justify;
        }
        
        ul, ol {
            margin: 15px 0;
            padding-left: 30px;
        }
        
        li {
            margin-bottom: 8px;
        }
        
        /* Table Styles */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            border-radius: 8px;
            overflow: hidden;
        }
        
        th {
            background-color: #1e3a8a;
            color: white;
            text-align: left;
            padding: 15px;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #e5e7eb;
        }
        
        tr:nth-child(even) {
            background-color: #f3f4f6;
        }
        
        tr:hover {
            background-color: #dbeafe;
        }
        
        /* Chart Container */
        .chart-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin: 30px 0;
        }
        
        .chart-box {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }
        
        .chart-title {
            text-align: center;
            margin-bottom: 15px;
            color: #1e3a8a;
            font-weight: bold;
        }
        
        /* Flow Chart */
        .flow-chart {
            background: white;
            border-radius: 10px;
            padding: 30px;
            margin: 40px 0;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }
        
        .flow-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
        }
        
        .flow-step {
            background: #dbeafe;
            border: 2px solid #3b82f6;
            border-radius: 10px;
            padding: 20px;
            width: 80%;
            margin-bottom: 30px;
            position: relative;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .flow-step:after {
            content: "";
            position: absolute;
            bottom: -30px;
            left: 50%;
            transform: translateX(-50%);
            width: 2px;
            height: 30px;
            background: #3b82f6;
        }
        
        .flow-step:last-child:after {
            display: none;
        }
        
        .step-number {
            position: absolute;
            top: -15px;
            left: -15px;
            background: #1e3a8a;
            color: white;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }
        
        .decision {
            background: #ffedd5;
            border: 2px solid #f97316;
            position: relative;
        }
        
        .decision:before {
            content: "⭯";
            position: absolute;
            right: -30px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 24px;
            color: #f97316;
        }
        
        /* Footer Styles */
        footer {
            background: linear-gradient(135deg, #1e3a8a, #3b82f6);
            color: white;
            padding: 40px;
            text-align: center;
        }
        
        .signature-section {
            display: flex;
            justify-content: space-around;
            margin: 40px auto;
            max-width: 800px;
            flex-wrap: wrap;
        }
        
        .signature-box {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 8px;
            padding: 25px;
            min-width: 300px;
            margin: 10px;
            backdrop-filter: blur(10px);
        }
        
        .signature-line {
            height: 2px;
            background: white;
            margin: 40px 0 20px;
        }
        
        /* Responsive Design */
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
            
            .flow-step {
                width: 95%;
            }
            
            .doc-info {
                flex-direction: column;
                align-items: center;
            }
            
            .info-box {
                width: 100%;
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
                padding: 20px;
            }
            
            .flow-step {
                font-size: 0.9rem;
                padding: 15px;
            }
        }
        
        .risk-matrix {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2px;
            margin: 25px 0;
        }
        
        .matrix-header {
            background: #1e3a8a;
            color: white;
            padding: 15px;
            text-align: center;
            font-weight: bold;
        }
        
        .matrix-cell {
            padding: 15px;
            text-align: center;
        }
        
        .low-risk {
            background: #dcfce7;
        }
        
        .medium-risk {
            background: #fef9c3;
        }
        
        .high-risk {
            background: #fee2e2;
        }
        
        .critical-risk {
            background: #ffcccc;
            color: #b91c1c;
            font-weight: bold;
        }
        
        .matrix-legend {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
        }
        
        .legend-low { background: #dcfce7; }
        .legend-medium { background: #fef9c3; }
        .legend-high { background: #fee2e2; }
        .legend-critical { background: #ffcccc; }
        
        .mitigation-examples {
            background: #f0f9ff;
            border-left: 4px solid #0ea5e9;
            padding: 20px;
            border-radius: 0 8px 8px 0;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="company-logo">
                <i class="fas fa-exchange-alt"></i>
                <span>PT. Audric Valasindo Kapital</span>
            </div>
            
            <div class="header-content">
                <h1>STANDAR OPERASIONAL PROSEDUR</h1>
                <div class="subtitle">MANAJEMEN RISIKO PERUSAHAAN MONEY CHANGER</div>
                
                <div class="doc-info">
                    <div class="info-box">
                        <i class="fas fa-file-alt"></i> Kode Dokumen: SOP-RM-002
                    </div>
                    <div class="info-box">
                        <i class="fas fa-calendar-alt"></i> Tanggal Efektif: 19 Juni 2025
                    </div>
                    <div class="info-box">
                        <i class="fas fa-sync-alt"></i> Revisi: 01
                    </div>
                </div>
            </div>
        </header>
        
        <div class="content">
            <section id="purpose">
                <h2><i class="fas fa-bullseye"></i> TUJUAN</h2>
                <p>SOP ini bertujuan untuk:</p>
                <ul>
                    <li>Mengidentifikasi, menilai, dan memitigasi risiko operasional, finansial, dan kepatuhan pada perusahaan money changer</li>
                    <li>Melindungi aset perusahaan dari kerugian akibat fluktuasi kurs, pemalsuan uang, dan fraud</li>
                    <li>Memastikan kepatuhan terhadap regulasi Bank Indonesia dan UU Pencegahan Pencucian Uang</li>
                    <li>Membangun kerangka kerja manajemen risiko yang komprehensif dan berkelanjutan</li>
                </ul>
            </section>
            
            <section id="scope">
                <h2><i class="fas fa-globe-asia"></i> RUANG LINGKUP</h2>
                <p>SOP ini berlaku untuk seluruh aktivitas operasional PT. Audric Valasindo Kapital dengan cakupan:</p>
                <ul>
                    <li>Manajemen risiko pasar (fluktuasi kurs valas)</li>
                    <li>Risiko operasional (pemalsuan uang, human error, keamanan fisik)</li>
                    <li>Risiko kepatuhan (pelaporan transaksi, CDD, regulasi BI)</li>
                    <li>Risiko likuiditas dan reputasi</li>
                    <li>Risiko teknologi dan keamanan data</li>
                </ul>
            </section>
            
            <section id="risk-management">
                <h2><i class="fas fa-exclamation-triangle"></i> MANAJEMEN RISIKO</h2>
                
                <h3>Identifikasi Risiko</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Jenis Risiko</th>
                            <th>Contoh</th>
                            <th>Frekuensi Penilaian</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Risiko Pasar</strong></td>
                            <td>Fluktuasi kurs USD-IDR</td>
                            <td>Real-time</td>
                        </tr>
                        <tr>
                            <td><strong>Risiko Operasional</strong></td>
                            <td>Uang palsu, kesalahan hitung, keamanan fisik</td>
                            <td>Harian</td>
                        </tr>
                        <tr>
                            <td><strong>Risiko Kepatuhan</strong></td>
                            <td>Pelanggaran AML/CFT, ketidaklengkapan dokumen CDD</td>
                            <td>Mingguan</td>
                        </tr>
                        <tr>
                            <td><strong>Risiko Reputasi</strong></td>
                            <td>Keluhan pelanggan, pemberitaan negatif</td>
                            <td>Bulanan</td>
                        </tr>
                        <tr>
                            <td><strong>Risiko Teknologi</strong></td>
                            <td>Serangan siber, kegagalan sistem, kebocoran data</td>
                            <td>Triwulanan</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Penilaian Risiko (Risk Assessment)</h3>
                <p>Penilaian risiko dilakukan menggunakan matriks Probabilitas vs Dampak:</p>
                
                <div class="risk-matrix">
                    <div class="matrix-header"></div>
                    <div class="matrix-header">Dampak Rendah</div>
                    <div class="matrix-header">Dampak Sedang</div>
                    <div class="matrix-header">Dampak Tinggi</div>
                    
                    <div class="matrix-header">Prob. Tinggi</div>
                    <div class="matrix-cell medium-risk">Risiko Sedang</div>
                    <div class="matrix-cell high-risk">Risiko Tinggi</div>
                    <div class="matrix-cell critical-risk">Risiko Kritis</div>
                    
                    <div class="matrix-header">Prob. Sedang</div>
                    <div class="matrix-cell low-risk">Risiko Rendah</div>
                    <div class="matrix-cell medium-risk">Risiko Sedang</div>
                    <div class="matrix-cell high-risk">Risiko Tinggi</div>
                    
                    <div class="matrix-header">Prob. Rendah</div>
                    <div class="matrix-cell low-risk">Risiko Rendah</div>
                    <div class="matrix-cell low-risk">Risiko Rendah</div>
                    <div class="matrix-cell medium-risk">Risiko Sedang</div>
                </div>
                
                <div class="matrix-legend">
                    <div class="legend-item">
                        <div class="legend-color legend-low"></div>
                        <span>Rendah (Lanjutkan dengan pemantauan rutin)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color legend-medium"></div>
                        <span>Sedang (Perlu rencana mitigasi)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color legend-high"></div>
                        <span>Tinggi (Mitigasi segera diperlukan)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color legend-critical"></div>
                        <span>Kritis (Tindakan darurat segera)</span>
                    </div>
                </div>
                
                <h3>Strategi Mitigasi Risiko</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Risiko</th>
                            <th>Strategi Mitigasi</th>
                            <th>Penanggung Jawab</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Fluktuasi Kurs</strong></td>
                            <td>
                                <ul>
                                    {{-- <li>Hedging kontrak dengan bank mitra</li> --}}
                                    <li>Batasi eksposur valas per hari (max USD 50,000)</li>
                                    <li>Update kurs real-time berdasarkan market movement</li>
                                </ul>
                            </td>
                            <td>Manajer Keuangan</td>
                        </tr>
                        <tr>
                            <td><strong>Uang Palsu</strong></td>
                            <td>
                                <ul>
                                    <li>Gunakan 3 alat verifikasi (UV, magnetic, watermark)</li>
                                    <li>Pelatihan teller bulanan</li>
                                    <li>Audit kas mendadak</li>
                                </ul>
                            </td>
                            <td>Supervisor Operasional</td>
                        </tr>
                        <tr>
                            <td><strong>Fraud Transaksi</strong></td>
                            <td>
                                <ul>
                                    <li>Verifikasi biometrik untuk transaksi > Rp 100 juta</li>
                                    <li>Limit transaksi per pelanggan/hari</li>
                                    <li>Dual control untuk transaksi besar</li>
                                </ul>
                            </td>
                            <td>Manajer Kepatuhan</td>
                        </tr>
                        <tr>
                            <td><strong>Cyber Risk</strong></td>
                            <td>
                                <ul>
                                    <li>Enkripsi data pelanggan</li>
                                    <li>Audit IT triwulanan</li>
                                    <li>Backup data harian offsite</li>
                                </ul>
                            </td>
                            <td>IT Security Officer</td>
                        </tr>
                    </tbody>
                </table>
                
                <div class="mitigation-examples">
                    <h4><i class="fas fa-lightbulb"></i> Contoh Mitigasi Efektif:</h4>
                    <p>Untuk risiko uang palsu, perusahaan menggunakan kombinasi alat deteksi:</p>
                    <ul>
                        <li>UV Light untuk memeriksa watermark dan benang pengaman</li>
                        <li>Counterfeit detector pen untuk menguji kandungan pati kertas</li>
                        <li>Microscope 100x untuk memeriksa microprinting</li>
                    </ul>
                </div>
                
                <h3>Prosedur Tanggap Darurat</h3>
                <div class="flow-chart">
                    <h4><i class="fas fa-bolt"></i> Skenario: Terjadi Fluktuasi Kurs Ekstrim</h4>
                    <div class="flow-container">
                        <div class="flow-step">
                            <div class="step-number">1</div>
                            <strong>Bekukan sementara transaksi valas tertentu</strong>
                            <p>Segera hentikan transaksi untuk mata uang yang mengalami fluktuasi ekstrim</p>
                        </div>
                        {{-- <div class="flow-step">
                            <div class="step-number">2</div>
                            <strong>Konsultasi dengan bank mitra</strong>
                            <p>Lakukan hedging darurat dan koordinasi dengan bank mitra</p>
                        </div> --}}
                        <div class="flow-step">
                            <div class="step-number">3</div>
                            <strong>Update informasi ke pelanggan</strong>
                            <p>Informasikan perubahan kurs melalui website, SMS, dan papan pengumuman di lokasi</p>
                        </div>
                        <div class="flow-step">
                            <div class="step-number">4</div>
                            <strong>Laporan ke manajemen</strong>
                            <p>Buat laporan insiden dan rekomendasi untuk mencegah terulangnya kejadian</p>
                        </div>
                    </div>
                </div>
                
                <div class="flow-chart">
                    <h4><i class="fas fa-bolt"></i> Skenario: Temuan Uang Palsu</h4>
                    <div class="flow-container">
                        <div class="flow-step">
                            <div class="step-number">1</div>
                            <strong>Konfisikasi uang</strong>
                            <p>Tahan uang yang diduga palsu dan beri surat penolakan transaksi</p>
                        </div>
                        <div class="flow-step decision">
                            <div class="step-number">2</div>
                            <strong>Verifikasi oleh supervisor</strong>
                            <p>Supervisor melakukan verifikasi ulang dengan alat tambahan</p>
                        </div>
                        <div class="flow-step">
                            <div class="step-number">3</div>
                            <strong>Laporkan ke otoritas</strong>
                            <p>Lapor ke Bank Indonesia dan kepolisian maksimal 1x24 jam</p>
                        </div>
                        <div class="flow-step">
                            <div class="step-number">4</div>
                            <strong>Audit internal</strong>
                            <p>Periksa CCTV dan catatan transaksi terkait untuk analisis lebih lanjut</p>
                        </div>
                    </div>
                </div>
            </section>
            
            <section id="monitoring">
                <h2><i class="fas fa-chart-line"></i> MONITORING & PELAPORAN</h2>
                
                <h3>Laporan Rutin</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Jenis Laporan</th>
                            <th>Frekuensi</th>
                            <th>Penerima</th>
                            <th>Konten Utama</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Risk Dashboard</td>
                            <td>Mingguan</td>
                            <td>Manajer Operasional</td>
                            <td>Update eksposur risiko, insiden mingguan</td>
                        </tr>
                        <tr>
                            <td>Compliance Report</td>
                            <td>Bulanan</td>
                            <td>Direktur, Komisaris</td>
                            <td>Kepatuhan regulasi, temuan audit</td>
                        </tr>
                        <tr>
                            <td>Audit Internal</td>
                            <td>Triwulanan</td>
                            <td>Komite Manajemen Risiko</td>
                            <td>Evaluasi efektivitas mitigasi risiko</td>
                        </tr>
                        <tr>
                            <td>Laporan Regulator</td>
                            <td>Bulanan/Tahunan</td>
                            <td>OJK, Bank Indonesia</td>
                            <td>Transaksi mencurigakan, kepatuhan AML</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Key Risk Indicator (KRI)</h3>
                <div class="chart-container">
                    <div class="chart-box">
                        <div class="chart-title">Rasio Kesalahan Transaksi</div>
                        <canvas id="errorRateChart"></canvas>
                    </div>
                    <div class="chart-box">
                        <div class="chart-title">Insiden Uang Palsu</div>
                        <canvas id="counterfeitChart"></canvas>
                    </div>
                    <div class="chart-box">
                        <div class="chart-title">Kepatuhan Pelaporan BI</div>
                        <canvas id="complianceChart"></canvas>
                    </div>
                </div>
            </section>
            
            <section id="attachments">
                <h2><i class="fas fa-paperclip"></i> LAMPIRAN</h2>
                
                <h3>Formulir Pelaporan Insiden Risiko</h3>
                <table>
                    <tbody>
                        <tr>
                            <td width="20%"><strong>Tanggal</strong></td>
                            <td>________________________</td>
                        </tr>
                        <tr>
                            <td><strong>Jenis Risiko</strong></td>
                            <td>
                                [ ] Pasar &nbsp;&nbsp; [ ] Operasional &nbsp;&nbsp; 
                                [ ] Kepatuhan &nbsp;&nbsp; [ ] Teknologi &nbsp;&nbsp; 
                                [ ] Lainnya: ________
                            </td>
                        </tr>
                        <tr>
                            <td><strong>Deskripsi Insiden</strong></td>
                            <td>________________________________________________<br>
                                ________________________________________________</td>
                        </tr>
                        <tr>
                            <td><strong>Dampak</strong></td>
                            <td>
                                Kerugian Finansial: Rp ________ <br>
                                Dampak Reputasi: [ ] Rendah [ ] Sedang [ ] Tinggi <br>
                                Pelanggaran Regulasi: [ ] Ya [ ] Tidak
                            </td>
                        </tr>
                        <tr>
                            <td><strong>Tindakan Segera</strong></td>
                            <td>________________________________________________<br>
                                ________________________________________________</td>
                        </tr>
                        <tr>
                            <td><strong>Ditangani Oleh</strong></td>
                            <td>________________________ (Tanda Tangan)</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Daftar Regulasi Terkait</h3>
                <ul>
                    <li>PBI No. 22/2019 tentang Penyelenggaraan Money Changer</li>
                    <li>SE BI No. 21/32/DPU tentang Pedoman KYC/AML</li>
                    <li>UU No. 8 Tahun 2010 tentang Pencegahan Pencucian Uang</li>
                    <li>POJK No. 12/POJK.01/2017 tentang Penerapan Program APU dan PPT</li>
                    <li>Peraturan BI No. 14/27/PBI/2012 tentang Transparansi Produk dan Penggunaan Data Pribadi</li>
                </ul>
            </section>
            
            <section id="review">
                <h2><i class="fas fa-sync-alt"></i> PROSEDUR REVIEW</h2>
                <ul>
                    <li><strong>Review SOP:</strong> Dilakukan setiap 6 bulan</li>
                    <li><strong>Penanggung Jawab:</strong> Tim Manajemen Risiko</li>
                    <li><strong>Update:</strong> Disesuaikan dengan perubahan regulasi dan skala bisnis</li>
                    <li><strong>Pelatihan:</strong> Wajib diikuti seluruh staf minimal 1x/tahun</li>
                    <li><strong>Batas Toleransi Risiko:</strong> Maksimal 0.5% dari modal bulanan</li>
                    <li><strong>Simulasi Krisis:</strong> Dilaksanakan setiap 3 bulan</li>
                </ul>
            </section>
        </div>
        
        <footer>
            <div class="signature-section">
                <div class="signature-box">
                    <p>Disusun Oleh:</p>
                    <p><strong>Manajer Operasional</strong></p>
                    <div class="signature-line"></div>
                    <p>Nama Lengkap & Tanda Tangan</p>
                </div>
                
                <div class="signature-box">
                    <p>Disetujui Oleh:</p>
                    <p><strong>Direktur Utama</strong></p>
                    <div class="signature-line"></div>
                    <p>Nama Lengkap & Tanda Tangan</p>
                </div>
            </div>
            
            <p>PT. Audric Valasindo Kapital</p>
            <p>Jl. Taman Galaxy Raya Blok A-21 | Telp: (021) 38711345 | Email: audricvalasindokapital@gmail.com</p>
            <p style="margin-top: 20px;">SOP ini mengacu pada standar ISO 31000:2018 dan regulasi Otoritas Jasa Keuangan</p>
        </footer>
    </div>
    
    <script>
        // Error Rate Chart
        const errorRateCtx = document.getElementById('errorRateChart').getContext('2d');
        const errorRateChart = new Chart(errorRateCtx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'],
                datasets: [{
                    label: 'Kesalahan Transaksi (%)',
                    data: [0.15, 0.12, 0.08, 0.05, 0.04, 0.03],
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    borderWidth: 3,
                    pointRadius: 6,
                    pointBackgroundColor: '#1e3a8a',
                    tension: 0.3,
                    fill: true
                }, {
                    label: 'Target Maksimal',
                    data: [0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
                    borderColor: '#ef4444',
                    borderWidth: 2,
                    borderDash: [5, 5],
                    pointRadius: 0,
                    fill: false
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 0.2,
                        ticks: {
                            callback: function(value) {
                                return value * 100 + '%';
                            }
                        }
                    }
                }
            }
        });
        
        // Counterfeit Chart
        const counterfeitCtx = document.getElementById('counterfeitChart').getContext('2d');
        const counterfeitChart = new Chart(counterfeitCtx, {
            type: 'bar',
            data: {
                labels: ['USD', 'EUR', 'SGD', 'AUD', 'GBP'],
                datasets: [{
                    label: 'Insiden Uang Palsu',
                    data: [8, 3, 5, 2, 1],
                    backgroundColor: [
                        'rgba(239, 68, 68, 0.7)',
                        'rgba(249, 115, 22, 0.7)',
                        'rgba(234, 179, 8, 0.7)',
                        'rgba(59, 130, 246, 0.7)',
                        'rgba(139, 92, 246, 0.7)'
                    ],
                    borderColor: [
                        '#dc2626',
                        '#ea580c',
                        '#ca8a04',
                        '#2563eb',
                        '#7e22ce'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Jumlah Insiden'
                        }
                    }
                }
            }
        });
        
        // Compliance Chart
        const complianceCtx = document.getElementById('complianceChart').getContext('2d');
        const complianceChart = new Chart(complianceCtx, {
            type: 'doughnut',
            data: {
                labels: ['Tepat Waktu', 'Terlambat < 3 hari', 'Terlambat > 3 hari'],
                datasets: [{
                    data: [89, 8, 3],
                    backgroundColor: [
                        '#10b981',
                        '#f59e0b',
                        '#ef4444'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    </script>
</body>
</html>