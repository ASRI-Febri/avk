<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOP Penerapan Kurs - Money Changer</title>
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
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            color: #212529;
            line-height: 1.7;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            overflow: hidden;
        }
        
        /* Header Styles */
        header {
            background: linear-gradient(135deg, #2b8a3e 0%, #40c057 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
            position: relative;
        }
        
        .currency-badge {
            position: absolute;
            top: 20px;
            right: 30px;
            background: #ffd43b;
            color: #2b8a3e;
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
            color: #e6fcf5;
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
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            border-left: 5px solid #2b8a3e;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        section:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        }
        
        h2 {
            color: #2b8a3e;
            padding-bottom: 15px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            border-bottom: 2px solid #d3f9d8;
        }
        
        h2 i {
            background: #d3f9d8;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #2b8a3e;
        }
        
        h3 {
            color: #40c057;
            margin: 30px 0 20px;
            padding-left: 15px;
            border-left: 4px solid #74c69d;
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
            color: #2b8a3e;
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
            background-color: #2b8a3e;
            color: white;
            text-align: left;
            padding: 18px;
            font-weight: 600;
        }
        
        td {
            padding: 15px 18px;
            border-bottom: 1px solid #ebfbee;
        }
        
        tr:nth-child(even) {
            background-color: #f1f3f5;
        }
        
        tr:hover {
            background-color: #ebfbee;
        }
        
        /* Flow Chart */
        .flow-chart {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin: 40px 0;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            border: 1px solid #d3f9d8;
        }
        
        .flow-container {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 30px;
        }
        
        .flow-step {
            background: #d3f9d8;
            border: 2px solid #2b8a3e;
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
            background: #b2f2bb;
        }
        
        .step-number {
            position: absolute;
            top: -15px;
            left: -15px;
            background: #2b8a3e;
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
            color: #2b8a3e;
        }
        
        .step-title {
            font-weight: bold;
            margin-bottom: 15px;
            color: #2b8a3e;
            font-size: 1.2rem;
        }
        
        /* Exchange Rate Display */
        .rate-display {
            background: #d3f9d8;
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
            text-align: center;
        }
        
        .rate-title {
            font-size: 1.8rem;
            color: #2b8a3e;
            margin-bottom: 20px;
        }
        
        .rate-container {
            display: flex;
            justify-content: space-around;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .rate-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            min-width: 200px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }
        
        .currency {
            font-size: 1.5rem;
            font-weight: bold;
            color: #2b8a3e;
            margin-bottom: 10px;
        }
        
        .rate-value {
            font-size: 1.8rem;
            font-weight: bold;
            color: #e67700;
        }
        
        .rate-change {
            font-size: 0.9rem;
            margin-top: 5px;
        }
        
        .positive {
            color: #2b8a3e;
        }
        
        .negative {
            color: #e03131;
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
            color: #2b8a3e;
            font-weight: bold;
        }
        
        /* Footer Styles */
        footer {
            background: linear-gradient(135deg, #2b8a3e 0%, #40c057 100%);
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
            color: #d3f9d8;
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
            
            .rate-container {
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
            
            .currency-badge {
                position: static;
                margin-top: 20px;
                display: inline-flex;
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
        
        .rate-formula {
            background: #e6fcf5;
            padding: 20px;
            border-radius: 10px;
            margin: 25px 0;
            font-family: 'Courier New', monospace;
            text-align: center;
            font-size: 1.2rem;
            border: 1px dashed #74c69d;
        }
        
        .update-schedule {
            display: flex;
            justify-content: space-around;
            margin: 30px 0;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .update-card {
            background: #d3f9d8;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            min-width: 200px;
        }
        
        .update-time {
            font-size: 1.8rem;
            font-weight: bold;
            color: #2b8a3e;
            margin: 10px 0;
        }
        
        .market-status {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin: 30px 0;
            flex-wrap: wrap;
        }
        
        .status-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            min-width: 200px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }
        
        .status-value {
            font-size: 1.2rem;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .stable {
            color: #2b8a3e;
        }
        
        .volatile {
            color: #e67700;
        }
        
        .high-volatility {
            color: #e03131;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="currency-badge">
                <i class="fas fa-chart-line"></i> MANAJEMEN KURS
            </div>
            
            <div class="header-content">
                <h1>STANDAR OPERASIONAL PROSEDUR</h1>
                <div class="subtitle">PENERAPAN KURS VALUTA ASING</div>
                
                <div class="doc-info">
                    <div class="info-box">
                        <i class="fas fa-file-alt"></i> Kode Dokumen: SOP-KURS-004
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
                <p>SOP ini menetapkan prosedur penetapan, penerapan, dan pemantauan kurs valuta asing di PT. Audric Valasindo Kapital untuk:</p>
                <ul>
                    <li>Memastikan penetapan kurs yang kompetitif dan menguntungkan</li>
                    <li>Menjaga konsistensi dan transparansi dalam penentuan kurs</li>
                    <li>Mengelola risiko fluktuasi nilai tukar secara efektif</li>
                    <li>Mematuhi regulasi Bank Indonesia terkait penyampaian informasi kurs</li>
                    <li>Memberikan pelayanan terbaik kepada pelanggan</li>
                </ul>
                
                <p><strong>Ruang Lingkup:</strong> Prosedur ini berlaku untuk semua transaksi penukaran valuta asing di seluruh cabang PT. Audric Valasindo Kapital.</p>
            </section>
            
            <section id="sources">
                <h2><i class="fas fa-database"></i> SUMBER PENETAPAN KURS</h2>
                
                <div class="flow-container">
                    <div class="flow-step">
                        <div class="step-number">1</div>
                        <div class="step-icon"><i class="fas fa-globe"></i></div>
                        <div class="step-title">Pasar Internasional</div>
                        <p>Nilai tukar dari pasar valas global (Forex)</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">2</div>
                        <div class="step-icon"><i class="fas fa-landmark"></i></div>
                        <div class="step-title">Bank Indonesia</div>
                        <p>Kurs tengah BI (JISDOR) sebagai acuan</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">3</div>
                        <div class="step-icon"><i class="fas fa-university"></i></div>
                        <div class="step-title">Bank Koresponden</div>
                        <p>Kurs dari mitra bank untuk transaksi besar</p>
                    </div>
                    
                    <div class="flow-step">
                        <div class="step-number">4</div>
                        <div class="step-icon"><i class="fas fa-balance-scale"></i></div>
                        <div class="step-title">Pesaing Lokal</div>
                        <p>Analisis kurs dari money changer sekitar</p>
                    </div>
                </div>
                
                <h3>Prioritas Sumber Kurs</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Mata Uang</th>
                            <th>Sumber Utama</th>
                            <th>Sumber Sekunder</th>
                            <th>Update Minimal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>USD (Dolar AS)</td>
                            <td>Bank Indonesia & Forex</td>
                            <td>Bank Koresponden</td>
                            <td>15 Menit</td>
                        </tr>
                        <tr>
                            <td>EUR (Euro)</td>
                            <td>Pasar Forex</td>
                            <td>BI & Bank Koresponden</td>
                            <td>30 Menit</td>
                        </tr>
                        <tr>
                            <td>SGD (Dolar Singapura)</td>
                            <td>Bank Koresponden</td>
                            <td>BI & Forex</td>
                            <td>1 Jam</td>
                        </tr>
                        <tr>
                            <td>JPY (Yen Jepang)</td>
                            <td>Pasar Forex</td>
                            <td>Bank Koresponden</td>
                            <td>1 Jam</td>
                        </tr>
                        <tr>
                            <td>AUD (Dolar Australia)</td>
                            <td>Pasar Forex</td>
                            <td>Bank Koresponden</td>
                            <td>2 Jam</td>
                        </tr>
                    </tbody>
                </table>
            </section>
            
            <section id="calculation">
                <h2><i class="fas fa-calculator"></i> PERHITUNGAN KURS</h2>
                
                <h3>Formula Dasar Penetapan Kurs</h3>
                <div class="rate-formula">
                    Kurs Jual = Kurs Acuan + (Spread × Faktor Risiko) + Biaya Operasional
                    <br><br>
                    Kurs Beli = Kurs Acuan - (Spread × Faktor Risiko) - Biaya Operasional
                </div>
                
                <h3>Variabel Penentu Spread</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Faktor</th>
                            <th>Pengaruh pada Spread</th>
                            <th>Rentang Nilai</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Volatilitas Pasar</td>
                            <td>Meningkatkan spread</td>
                            <td>0.5% - 3%</td>
                        </tr>
                        <tr>
                            <td>Permintaan Pelanggan</td>
                            <td>Menurunkan spread (vol. tinggi)</td>
                            <td>0.2% - 1.5%</td>
                        </tr>
                        <tr>
                            <td>Persediaan Valas</td>
                            <td>Meningkatkan spread (stok rendah)</td>
                            <td>0.3% - 2%</td>
                        </tr>
                        <tr>
                            <td>Kebijakan Perusahaan</td>
                            <td>Margin keuntungan minimum</td>
                            <td>Minimal 0.8%</td>
                        </tr>
                    </tbody>
                </table>
                
                <h3>Contoh Perhitungan</h3>
                <div class="chart-container">
                    <div class="chart-box">
                        <div class="chart-title">Kurs Jual USD</div>
                        <canvas id="buyRateChart"></canvas>
                    </div>
                    <div class="chart-box">
                        <div class="chart-title">Kurs Beli USD</div>
                        <canvas id="sellRateChart"></canvas>
                    </div>
                </div>
            </section>
            
            <section id="update">
                <h2><i class="fas fa-sync-alt"></i> PROSEDUR UPDATE KURS</h2>
                
                <h3>Jadwal Update Kurs</h3>
                <div class="update-schedule">
                    <div class="update-card">
                        <i class="fas fa-sun"></i>
                        <div>Pembukaan</div>
                        <div class="update-time">08:00 WIB</div>
                        <div>Kurs pembukaan hari</div>
                    </div>
                    
                    <div class="update-card">
                        <i class="fas fa-clock"></i>
                        <div>Update Reguler</div>
                        <div class="update-time">Setiap 30 Menit</div>
                        <div>Untuk mata uang utama</div>
                    </div>
                    
                    <div class="update-card">
                        <i class="fas fa-bolt"></i>
                        <div>Update Cepat</div>
                        <div class="update-time">Sesuai Perubahan</div>
                        <div>Ketika pasar volatil</div>
                    </div>
                    
                    <div class="update-card">
                        <i class="fas fa-moon"></i>
                        <div>Penutupan</div>
                        <div class="update-time">17:00 WIB</div>
                        <div>Kurs penutupan hari</div>
                    </div>
                </div>
                
                <h3>Alur Update Kurs</h3>
                <div class="flow-chart">
                    <div class="flow-container">
                        <div class="flow-step">
                            <div class="step-number">1</div>
                            <div class="step-icon"><i class="fas fa-search"></i></div>
                            <div class="step-title">Monitoring</div>
                            <p>Tim riset memantau sumber kurs terkini</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">2</div>
                            <div class="step-icon"><i class="fas fa-calculator"></i></div>
                            <div class="step-title">Perhitungan</div>
                            <p>Hitung kurs baru berdasarkan formula</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">3</div>
                            <div class="step-icon"><i class="fas fa-check-circle"></i></div>
                            <div class="step-title">Persetujuan</div>
                            <p>Manajer keuangan menyetujui kurs baru</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">4</div>
                            <div class="step-icon"><i class="fas fa-sync"></i></div>
                            <div class="step-title">Update Sistem</div>
                            <p>Input kurs ke sistem dan platform</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">5</div>
                            <div class="step-icon"><i class="fas fa-bullhorn"></i></div>
                            <div class="step-title">Komunikasi</div>
                            <p>Informasikan ke semua cabang dan channel</p>
                        </div>
                    </div>
                </div>
            </section>
            
            <section id="display">
                <h2><i class="fas fa-desktop"></i> TAMPILAN DAN KOMUNIKASI KURS</h2>
                
                <div class="rate-display">
                    <div class="rate-title">KURS REAL-TIME</div>
                    <div class="rate-container">
                        <div class="rate-card">
                            <div class="currency">USD / IDR</div>
                            <div class="rate-value">15,420</div>
                            <div class="rate-change"><span class="positive">+0.2%</span> (Beli)</div>
                            <div class="rate-value">15,680</div>
                            <div class="rate-change"><span class="positive">+0.15%</span> (Jual)</div>
                        </div>
                        
                        <div class="rate-card">
                            <div class="currency">EUR / IDR</div>
                            <div class="rate-value">16,820</div>
                            <div class="rate-change"><span class="negative">-0.3%</span> (Beli)</div>
                            <div class="rate-value">17,120</div>
                            <div class="rate-change"><span class="negative">-0.25%</span> (Jual)</div>
                        </div>
                        
                        <div class="rate-card">
                            <div class="currency">SGD / IDR</div>
                            <div class="rate-value">11,420</div>
                            <div class="rate-change"><span class="positive">+0.1%</span> (Beli)</div>
                            <div class="rate-value">11,620</div>
                            <div class="rate-change"><span class="positive">+0.05%</span> (Jual)</div>
                        </div>
                    </div>
                </div>
                
                <h3>Saluran Informasi Kurs</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Saluran</th>
                            <th>Update Frekuensi</th>
                            <th>Penanggung Jawab</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Papan Kurs Digital</strong></td>
                            <td>Real-time</td>
                            <td>Manajer Cabang</td>
                        </tr>
                        <tr>
                            <td><strong>Website Perusahaan</strong></td>
                            <td>Setiap 15 menit</td>
                            <td>Tim IT</td>
                        </tr>
                        <tr>
                            <td><strong>Aplikasi Mobile</strong></td>
                            <td>Setiap 30 menit</td>
                            <td>Tim IT</td>
                        </tr>
                        <tr>
                            <td><strong>Media Sosial</strong></td>
                            <td>2x sehari (pagi & sore)</td>
                            <td>Tim Marketing</td>
                        </tr>
                        <tr>
                            <td><strong>SMS Blast</strong></td>
                            <td>Harian (kurs spesial)</td>
                            <td>Tim Marketing</td>
                        </tr>
                    </tbody>
                </table>
            </section>
            
            <section id="monitoring">
                <h2><i class="fas fa-chart-line"></i> PEMANTAUAN DAN EVALUASI</h2>
                
                <h3>Parameter Pemantauan</h3>
                <div class="market-status">
                    <div class="status-card">
                        <i class="fas fa-chart-bar"></i>
                        <div>Volatilitas Pasar</div>
                        <div class="status-value volatile">Sedang</div>
                        <div>(Perubahan < 1%)</div>
                    </div>
                    
                    <div class="status-card">
                        <i class="fas fa-percentage"></i>
                        <div>Spread Rata-rata</div>
                        <div class="status-value">1.8%</div>
                        <div>(Target: 1.5-2%)</div>
                    </div>
                    
                    <div class="status-card">
                        <i class="fas fa-medal"></i>
                        <div>Peringkat Kompetitif</div>
                        <div class="status-value">#2 dari 10</div>
                        <div>(Berdasar survei)</div>
                    </div>
                    
                    <div class="status-card">
                        <i class="fas fa-comments-dollar"></i>
                        <div>Respons Pelanggan</div>
                        <div class="status-value stable">Positif</div>
                        <div>(85% puas)</div>
                    </div>
                </div>
                
                <h3>Prosedur Penyesuaian Darurat</h3>
                <div class="flow-chart">
                    <div class="flow-container">
                        <div class="flow-step">
                            <div class="step-number">1</div>
                            <div class="step-icon"><i class="fas fa-exclamation-triangle"></i></div>
                            <div class="step-title">Deteksi Anomali</div>
                            <p>Identifikasi perubahan kurs > 2% dalam 1 jam</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">2</div>
                            <div class="step-icon"><i class="fas fa-lock"></i></div>
                            <div class="step-title">Bekukan Sementara</div>
                            <p>Hentikan transaksi untuk mata uang terkait</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">3</div>
                            <div class="step-icon"><i class="fas fa-phone"></i></div>
                            <div class="step-title">Konsultasi</div>
                            <p>Hubungi bank koresponden dan tim riset</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">4</div>
                            <div class="step-icon"><i class="fas fa-calculator"></i></div>
                            <div class="step-title">Hitung Ulang</div>
                            <p>Tentukan kurs baru dengan spread diperlebar</p>
                        </div>
                        
                        <div class="flow-step">
                            <div class="step-number">5</div>
                            <div class="step-icon"><i class="fas fa-sync"></i></div>
                            <div class="step-title">Update & Lanjutkan</div>
                            <p>Perbarui kurs dan lanjutkan transaksi</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>
        
        <footer>
            <div class="signature-section">
                <div class="signature-box">
                    <p>Disusun Oleh:</p>
                    <p><strong>Manajer Keuangan</strong></p>
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
                <a href="#" class="footer-link">SOP Transaksi</a>
                <a href="#" class="footer-link">SOP APU PPT</a>
                <a href="#" class="footer-link">Kebijakan Perusahaan</a>
                <a href="#" class="footer-link">Portal Karyawan</a>
            </div>
            
            <p style="margin-top: 30px; color: #d3f9d8;">
                Dokumen ini diperbarui secara berkala sesuai perubahan pasar dan regulasi
            </p>
        </footer>
    </div>
    
    <script>
        // Buy Rate Chart
        const buyRateCtx = document.getElementById('buyRateChart').getContext('2d');
        const buyRateChart = new Chart(buyRateCtx, {
            type: 'bar',
            data: {
                labels: ['Kurs Acuan', '+ Spread', '+ Biaya Op.', '+ Faktor Risiko', 'Kurs Jual'],
                datasets: [{
                    label: 'Perhitungan Kurs Jual USD',
                    data: [15380, 200, 50, 70, 15700],
                    backgroundColor: [
                        'rgba(40, 167, 69, 0.7)',
                        'rgba(255, 193, 7, 0.7)',
                        'rgba(13, 110, 253, 0.7)',
                        'rgba(220, 53, 69, 0.7)',
                        'rgba(111, 66, 193, 0.7)'
                    ],
                    borderColor: [
                        '#28a745',
                        '#ffc107',
                        '#0d6efd',
                        '#dc3545',
                        '#6f42c1'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 15000,
                        title: {
                            display: true,
                            text: 'Nilai (IDR)'
                        }
                    }
                }
            }
        });
        
        // Sell Rate Chart
        const sellRateCtx = document.getElementById('sellRateChart').getContext('2d');
        const sellRateChart = new Chart(sellRateCtx, {
            type: 'bar',
            data: {
                labels: ['Kurs Acuan', '- Spread', '- Biaya Op.', '- Faktor Risiko', 'Kurs Beli'],
                datasets: [{
                    label: 'Perhitungan Kurs Beli USD',
                    data: [15380, 180, 40, 60, 15100],
                    backgroundColor: [
                        'rgba(40, 167, 69, 0.7)',
                        'rgba(255, 193, 7, 0.7)',
                        'rgba(13, 110, 253, 0.7)',
                        'rgba(220, 53, 69, 0.7)',
                        'rgba(253, 126, 20, 0.7)'
                    ],
                    borderColor: [
                        '#28a745',
                        '#ffc107',
                        '#0d6efd',
                        '#dc3545',
                        '#fd7e14'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 15000,
                        title: {
                            display: true,
                            text: 'Nilai (IDR)'
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>