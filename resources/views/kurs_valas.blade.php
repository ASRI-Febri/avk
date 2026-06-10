<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daftar Nilai Tukar AVK</title>
  <meta http-equiv="refresh" content="60">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/css/flag-icons.min.css" />
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
    .flag { width: 2.4rem; height: 1.7rem; border-radius: .25rem; box-shadow: 0 0 6px rgba(0,0,0,.5); }

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
    .s-txt { color: #ffd45e; }
    .b-txt { color: #00ff88; }

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
  @php
    $records = $records ?? [];
    $fmt = function ($v) {
        $v = (float) $v;
        $dec = ($v > 0 && $v < 1000) ? 2 : 0;
        return 'Rp ' . number_format($v, $dec, ',', '.');
    };
    $flagClass = function ($ic) {
        $ic = trim((string) $ic);
        if ($ic === '') return 'fi fi-xx';
        return strpos($ic, 'fi-') === false ? 'fi fi-' . strtolower($ic) : $ic;
    };
  @endphp

  <div class="container-fluid mt-4">
    <h1 class="title">💱 DAFTAR NILAI TUKAR AVK</h1>

    <table class="table table-borderless table-hover text-white mt-4">
      <thead>
        <tr>
          <th></th>
          <th>Negara</th>
          <th>Mata Uang</th>
          <th>Jual</th>
          <th>Beli</th>
        </tr>
      </thead>
      <tbody id="exchangeTable">
        @forelse($records as $r)
          <tr>
            <td><span class="flag {{ $flagClass($r['IconFlag']) }}"></span></td>
            <td>{{ $r['CountryName'] }}</td>
            <td>{{ $r['CurrencyID'] }}</td>
            <td>{{ $fmt($r['SellRate']) }}</td>
            <td>{{ $fmt($r['BuyRate']) }}</td>
          </tr>
        @empty
          <tr><td colspan="5">Belum ada data kurs.</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>

  <footer>Update terakhir: {{ date('d F Y H:i') }} WIB — Sumber: Money Changer AVK</footer>

  <!-- ===== RUNNING TICKER ===== -->
  <div class="ticker-container">
    <div class="ticker" id="tickerContent">
      @foreach($records as $r)
        <span>
          <span class="flag {{ $flagClass($r['IconFlag']) }}"></span>
          {{ $r['CurrencyID'] }}: Jual <span class="s-txt">{{ $fmt($r['SellRate']) }}</span> /
          Beli <span class="b-txt">{{ $fmt($r['BuyRate']) }}</span>
        </span>
      @endforeach
    </div>
  </div>
</body>
</html>
