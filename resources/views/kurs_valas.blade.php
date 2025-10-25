<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daftar Nilai Tukar AVK</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body {
      background: linear-gradient(135deg, #0a0a23, #1b1b3a);
      color: #fff;
      font-family: "Segoe UI", sans-serif;
      overflow: hidden;
    }
    .title {
      text-align: center;
      font-size: 3rem;
      font-weight: 700;
      color: #00e0ff;
      margin-top: 1rem;
      text-shadow: 0 0 20px rgba(0,224,255,0.6);
    }
    table {
      font-size: 1.6rem;
    }
    th {
      background-color: #007bff;
      color: white;
      text-align: center;
    }
    td {
      text-align: center;
      vertical-align: middle;
    }
    .table tbody tr:nth-child(even) {
      background-color: rgba(255,255,255,0.05);
    }
    .table tbody tr:nth-child(odd) {
      background-color: rgba(255,255,255,0.1);
    }
    .rate-up {
      color: #00ff88;
      font-weight: bold;
    }
    .rate-down {
      color: #ff4d4d;
      font-weight: bold;
    }

    /* ===== TICKER ===== */
    .ticker-container {
      position: fixed;
      bottom: 0;
      width: 100%;
      background: rgba(0, 0, 0, 0.85);
      overflow: hidden;
      white-space: nowrap;
      border-top: 2px solid #00e0ff;
    }
    .ticker {
      display: inline-block;
      padding: 15px 0;
      animation: ticker 40s linear infinite;
      font-size: 1.5rem;
    }
    @keyframes ticker {
      0% { transform: translateX(100%); }
      100% { transform: translateX(-100%); }
    }
    .ticker span {
      margin-right: 3rem;
    }
    .rate-up-txt {
      color: #00ff88;
    }
    .rate-down-txt {
      color: #ff4d4d;
    }

    footer {
      text-align: center;
      font-size: 1.2rem;
      color: #aaa;
      position: absolute;
      bottom: 50px;
      width: 100%;
    }
  </style>
</head>
<body>
  <div class="container-fluid mt-4">
    <h1 class="title">💱 DAFTAR NILAI TUKAR MONEY CHANGER</h1>

    <table class="table table-borderless table-hover text-white mt-4">
      <thead>
        <tr>
          <th>Negara</th>
          <th>Mata Uang</th>
          <th>Jual</th>
          <th>Beli</th>
          <th>Perubahan</th>
        </tr>
      </thead>
      <tbody id="exchangeTable">
        <tr>
          <td>🇺🇸 Amerika Serikat</td>
          <td>USD</td>
          <td>Rp 16.050</td>
          <td>Rp 15.950</td>
          <td class="rate-up">▲ +0.15%</td>
        </tr>
        <tr>
          <td>🇪🇺 Eropa</td>
          <td>EUR</td>
          <td>Rp 17.100</td>
          <td>Rp 16.950</td>
          <td class="rate-down">▼ -0.12%</td>
        </tr>
        <tr>
          <td>🇸🇬 Singapura</td>
          <td>SGD</td>
          <td>Rp 11.800</td>
          <td>Rp 11.650</td>
          <td class="rate-up">▲ +0.05%</td>
        </tr>
        <tr>
          <td>🇯🇵 Jepang</td>
          <td>JPY</td>
          <td>Rp 110,50</td>
          <td>Rp 108,90</td>
          <td class="rate-down">▼ -0.20%</td>
        </tr>
        <tr>
          <td>🇬🇧 Inggris</td>
          <td>GBP</td>
          <td>Rp 19.250</td>
          <td>Rp 19.050</td>
          <td class="rate-up">▲ +0.10%</td>
        </tr>
      </tbody>
    </table>
  </div>

  <footer>Update terakhir: 24 Oktober 2025 — Sumber: Money Changer ABC</footer>

  <!-- ===== RUNNING TICKER ===== -->
  <div class="ticker-container">
    <div class="ticker" id="tickerContent">
      <span>🇺🇸 USD: Jual Rp16.050 / Beli Rp15.950 <span class="rate-up-txt">▲ +0.15%</span></span>
      <span>🇪🇺 EUR: Jual Rp17.100 / Beli Rp16.950 <span class="rate-down-txt">▼ -0.12%</span></span>
      <span>🇸🇬 SGD: Jual Rp11.800 / Beli Rp11.650 <span class="rate-up-txt">▲ +0.05%</span></span>
      <span>🇯🇵 JPY: Jual Rp110,50 / Beli Rp108,90 <span class="rate-down-txt">▼ -0.20%</span></span>
      <span>🇬🇧 GBP: Jual Rp19.250 / Beli Rp19.050 <span class="rate-up-txt">▲ +0.10%</span></span>
    </div>
  </div>

  <script>
    // Auto refresh tiap 60 detik
    setInterval(() => {
      location.reload();
    }, 60000);
  </script>
</body>
</html>
