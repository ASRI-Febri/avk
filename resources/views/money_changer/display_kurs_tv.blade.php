<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kurs Valuta Asing — AVK Money Changer</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.3.2/css/flag-icons.min.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Rajdhani:wght@500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-1: #060a1a;
            --bg-2: #0e1430;
            --accent: #20e3ff;
            --accent-2: #4f7bff;
            --gold: #ffd45e;
            --up: #21e08a;
            --down: #ff5c6c;
            --muted: #93a4cc;
            --card-bg: rgba(255, 255, 255, .045);
            --card-br: rgba(255, 255, 255, .09);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        html, body {
            height: 100%;
            width: 100%;
            overflow: hidden;
            background:
                radial-gradient(1200px 600px at 12% -10%, rgba(79, 123, 255, .18), transparent 60%),
                radial-gradient(1200px 600px at 110% 110%, rgba(32, 227, 255, .14), transparent 55%),
                linear-gradient(135deg, var(--bg-1), var(--bg-2));
            color: #fff;
            font-family: "Inter", "Segoe UI", sans-serif;
        }

        .screen {
            height: 100vh;
            width: 100vw;
            display: flex;
            flex-direction: column;
            padding: 2.2vmin 2.6vmin 0;
        }

        /* ===================== HEADER ===================== */
        header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 1.8vmin;
            border-bottom: .25vmin solid rgba(255, 255, 255, .08);
        }

        .brand { display: flex; align-items: center; gap: 1.6vmin; }

        .brand .logo {
            width: 6.6vmin; height: 6.6vmin;
            border-radius: 1.4vmin;
            background: linear-gradient(145deg, var(--accent), var(--accent-2));
            display: grid; place-items: center;
            font-family: "Rajdhani", sans-serif;
            font-weight: 700; font-size: 3.2vmin; color: #04122b;
            box-shadow: 0 0 4vmin rgba(32, 227, 255, .45);
        }

        .brand .name { font-family: "Rajdhani", sans-serif; font-weight: 700; font-size: 3.4vmin; line-height: 1; letter-spacing: .4px; }
        .brand .name small { display: block; font-family: "Inter"; font-weight: 500; font-size: 1.5vmin; letter-spacing: 5px; color: var(--accent); margin-top: .5vmin; }

        .title-center { text-align: center; }
        .title-center h1 {
            font-family: "Rajdhani", sans-serif; font-weight: 700;
            font-size: 4vmin; letter-spacing: .6px;
            background: linear-gradient(90deg, #fff, var(--accent));
            -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent;
        }
        .title-center .sub { font-size: 1.5vmin; letter-spacing: 4px; color: var(--muted); margin-top: .4vmin; }

        .clock { text-align: right; }
        .clock .time { font-family: "Rajdhani", sans-serif; font-weight: 700; font-size: 4vmin; line-height: 1; letter-spacing: 1px; }
        .clock .date { font-size: 1.6vmin; color: var(--muted); margin-top: .5vmin; }
        .live { display: inline-flex; align-items: center; gap: .8vmin; margin-top: .8vmin; font-size: 1.35vmin; letter-spacing: 3px; color: var(--up); }
        .live .dot { width: 1.2vmin; height: 1.2vmin; border-radius: 50%; background: var(--up); box-shadow: 0 0 1.6vmin var(--up); animation: pulse 1.6s infinite; }

        @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: .35; transform: scale(.7); } }

        /* ===================== GRID ===================== */
        main { flex: 1; min-height: 0; position: relative; padding: 2vmin 0; }

        .grid {
            height: 100%;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            grid-auto-rows: 1fr;
            gap: 1.6vmin;
        }
        .grid.cols-3 { grid-template-columns: repeat(3, 1fr); }
        .grid.cols-2 { grid-template-columns: repeat(2, 1fr); }

        .card {
            background: var(--card-bg);
            border: .18vmin solid var(--card-br);
            border-radius: 1.8vmin;
            padding: 1.8vmin 2vmin;
            display: flex; flex-direction: column; justify-content: space-between;
            backdrop-filter: blur(6px);
            box-shadow: inset 0 .2vmin 0 rgba(255, 255, 255, .06), 0 1.4vmin 3vmin rgba(0, 0, 0, .25);
            overflow: hidden; position: relative;
        }
        .card::before {
            content: ""; position: absolute; left: 0; top: 0; bottom: 0; width: .6vmin;
            background: linear-gradient(var(--accent), var(--accent-2));
        }

        .card-head { display: flex; align-items: center; gap: 1.4vmin; }
        .flag {
            width: 5.4vmin; height: 4vmin; border-radius: .7vmin; flex: none;
            background-size: cover !important; background-position: center !important;
            box-shadow: 0 .4vmin 1.2vmin rgba(0, 0, 0, .5); border: .12vmin solid rgba(255, 255, 255, .25);
        }
        .ccy { min-width: 0; }
        .ccy .code { font-family: "Rajdhani", sans-serif; font-weight: 700; font-size: 4vmin; line-height: 1; letter-spacing: .5px; }
        .ccy .country { font-size: 1.5vmin; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 22vmin; margin-top: .3vmin; }

        .rates { display: grid; grid-template-columns: 1fr 1fr; gap: 1.2vmin; }
        .rate-box { background: rgba(3, 8, 24, .5); border-radius: 1.1vmin; padding: 1.1vmin 1.4vmin; border: .12vmin solid rgba(255, 255, 255, .05); }
        .rate-box .label { font-size: 1.35vmin; letter-spacing: 3px; color: var(--muted); display: flex; align-items: center; justify-content: space-between; }
        .rate-box .val { font-family: "Rajdhani", sans-serif; font-weight: 700; font-size: 3.3vmin; line-height: 1.1; margin-top: .4vmin; white-space: nowrap; }
        .rate-box.jual { border-color: rgba(255, 212, 94, .22); }
        .rate-box.jual .val { color: var(--gold); }
        .rate-box.beli .val { color: #cfe6ff; }

        .trend { font-size: 1.6vmin; line-height: 1; }
        .trend.up { color: var(--up); }
        .trend.down { color: var(--down); }
        .trend.flat { color: var(--muted); opacity: .5; }

        @keyframes flashUp { 0% { background: rgba(33, 224, 138, .35); } 100% { background: rgba(3, 8, 24, .5); } }
        @keyframes flashDown { 0% { background: rgba(255, 92, 108, .35); } 100% { background: rgba(3, 8, 24, .5); } }
        .rate-box.flash-up { animation: flashUp 1.6s ease-out; }
        .rate-box.flash-down { animation: flashDown 1.6s ease-out; }

        /* page dots */
        .dots { position: absolute; bottom: -.2vmin; left: 50%; transform: translateX(-50%); display: flex; gap: 1vmin; }
        .dots .d { width: 1.3vmin; height: 1.3vmin; border-radius: 50%; background: rgba(255, 255, 255, .2); transition: all .3s; }
        .dots .d.active { background: var(--accent); width: 3.2vmin; border-radius: 1vmin; }

        /* ===================== TICKER ===================== */
        .ticker-wrap {
            flex: none; height: 6.4vmin; margin: 0 -2.6vmin;
            background: rgba(0, 0, 0, .55); border-top: .25vmin solid rgba(32, 227, 255, .5);
            overflow: hidden; display: flex; align-items: center; position: relative;
        }
        .ticker-tag {
            position: absolute; left: 0; top: 0; bottom: 0; z-index: 2;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            color: #04122b; font-family: "Rajdhani", sans-serif; font-weight: 700;
            font-size: 2vmin; letter-spacing: 2px; padding: 0 2.4vmin; display: grid; place-items: center;
        }
        .ticker { display: inline-flex; white-space: nowrap; padding-left: 100%; animation: ticker 48s linear infinite; }
        .ticker .item { font-size: 2vmin; margin-right: 4vmin; display: inline-flex; align-items: center; gap: 1vmin; }
        .ticker .item .fi { width: 2.6vmin; height: 1.9vmin; border-radius: .3vmin; }
        .ticker .item b { font-family: "Rajdhani", sans-serif; font-weight: 700; color: var(--accent); }
        .ticker .item .s { color: var(--gold); }
        .ticker .item .b { color: #cfe6ff; }
        @keyframes ticker { 0% { transform: translateX(0); } 100% { transform: translateX(-100%); } }

        .updated { position: absolute; right: 2.4vmin; z-index: 2; font-size: 1.4vmin; color: var(--muted);
            background: rgba(0, 0, 0, .55); padding: .4vmin 1.4vmin; border-radius: 1vmin; }

        .empty { height: 100%; display: grid; place-items: center; font-size: 3vmin; color: var(--muted); }
    </style>
</head>

<body>
    <div class="screen">

        <!-- ===================== HEADER ===================== -->
        <header>
            <div class="brand">
                <div class="logo">AVK</div>
                <div class="name">AVK MONEY CHANGER<small>VALUTA ASING</small></div>
            </div>
            <div class="title-center">
                <h1>KURS VALUTA ASING</h1>
                <div class="sub">FOREIGN EXCHANGE RATES</div>
            </div>
            <div class="clock">
                <div class="time" id="clock-time">--:--:--</div>
                <div class="date" id="clock-date">—</div>
                <div class="live"><span class="dot"></span> LIVE</div>
            </div>
        </header>

        <!-- ===================== GRID ===================== -->
        <main>
            <div class="grid" id="grid"></div>
            <div class="dots" id="dots"></div>
        </main>

        <!-- ===================== TICKER ===================== -->
        <div class="ticker-wrap">
            <div class="ticker-tag">KURS HARI INI</div>
            <div class="ticker" id="ticker"></div>
            <div class="updated">Diperbarui: <span id="updated">—</span></div>
        </div>
    </div>

    <script>
        // ====== Data awal dari server (render langsung, tetap jalan walau koneksi data berikutnya gagal) ======
        var INITIAL = @json($records);
        var DATA_URL = "{{ $url_data }}";

        var REFRESH_MS = 30000;   // ambil data baru tiap 30 detik
        var PAGE_MS    = 12000;   // rotasi halaman tiap 12 detik
        var PER_PAGE   = 12;      // 4 kolom x 3 baris

        var state = { rows: Array.isArray(INITIAL) ? INITIAL : [], last: {}, page: 0, pages: 1 };

        // ---------- Formatting ----------
        function fmtRate(v) {
            v = Number(v) || 0;
            var dec = v > 0 && v < 1000 ? 2 : 0;
            return v.toLocaleString('id-ID', { minimumFractionDigits: dec, maximumFractionDigits: dec });
        }
        function flagClass(ic) {
            ic = (ic || '').trim();
            if (!ic) return 'fi fi-xx';
            return ic.indexOf('fi-') === -1 ? ('fi fi-' + ic.toLowerCase()) : ic;
        }
        function trendSym(d) { return d > 0 ? '▲' : (d < 0 ? '▼' : '—'); }
        function trendCls(d) { return d > 0 ? 'up' : (d < 0 ? 'down' : 'flat'); }

        // ---------- Clock ----------
        var HARI = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
        var BULAN = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
        function pad(n) { return (n < 10 ? '0' : '') + n; }
        function tickClock() {
            var d = new Date();
            document.getElementById('clock-time').textContent = pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds());
            document.getElementById('clock-date').textContent = HARI[d.getDay()] + ', ' + d.getDate() + ' ' + BULAN[d.getMonth()] + ' ' + d.getFullYear();
        }

        // ---------- Render grid ----------
        function buildCard(row, prev) {
            var sell = Number(row.SellRate) || 0, buy = Number(row.BuyRate) || 0;
            var dSell = prev ? sell - (Number(prev.SellRate) || 0) : 0;
            var dBuy  = prev ? buy - (Number(prev.BuyRate) || 0) : 0;

            var flashS = dSell > 0 ? 'flash-up' : (dSell < 0 ? 'flash-down' : '');
            var flashB = dBuy > 0 ? 'flash-up' : (dBuy < 0 ? 'flash-down' : '');

            var card = document.createElement('div');
            card.className = 'card';
            card.innerHTML =
                '<div class="card-head">' +
                    '<span class="flag ' + flagClass(row.IconFlag) + '"></span>' +
                    '<div class="ccy">' +
                        '<div class="code">' + (row.CurrencyID || '') + '</div>' +
                        '<div class="country">' + (row.CountryName || '') + '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="rates">' +
                    '<div class="rate-box jual ' + flashS + '">' +
                        '<div class="label">JUAL <span class="trend ' + trendCls(dSell) + '">' + trendSym(dSell) + '</span></div>' +
                        '<div class="val">' + fmtRate(sell) + '</div>' +
                    '</div>' +
                    '<div class="rate-box beli ' + flashB + '">' +
                        '<div class="label">BELI <span class="trend ' + trendCls(dBuy) + '">' + trendSym(dBuy) + '</span></div>' +
                        '<div class="val">' + fmtRate(buy) + '</div>' +
                    '</div>' +
                '</div>';
            return card;
        }

        function colsClassFor(n) {
            if (n <= 4) return ' cols-2';
            if (n <= 9) return ' cols-3';
            return '';
        }

        function render() {
            var grid = document.getElementById('grid');
            var rows = state.rows;

            if (!rows.length) {
                grid.className = 'grid';
                grid.innerHTML = '<div class="empty">Belum ada data kurs untuk ditampilkan.</div>';
                document.getElementById('dots').innerHTML = '';
                return;
            }

            state.pages = Math.ceil(rows.length / PER_PAGE);
            if (state.page >= state.pages) state.page = 0;

            var start = state.page * PER_PAGE;
            var pageRows = rows.slice(start, start + PER_PAGE);

            grid.className = 'grid' + colsClassFor(pageRows.length);
            grid.innerHTML = '';
            pageRows.forEach(function (row) {
                grid.appendChild(buildCard(row, state.last[row.CurrencyID]));
            });

            // page dots
            var dots = document.getElementById('dots');
            dots.innerHTML = '';
            if (state.pages > 1) {
                for (var i = 0; i < state.pages; i++) {
                    var d = document.createElement('span');
                    d.className = 'd' + (i === state.page ? ' active' : '');
                    dots.appendChild(d);
                }
            }
        }

        function renderTicker() {
            var t = document.getElementById('ticker');
            if (!state.rows.length) { t.innerHTML = ''; return; }
            var html = '';
            // gandakan agar loop mulus
            for (var rep = 0; rep < 2; rep++) {
                state.rows.forEach(function (row) {
                    html += '<span class="item">' +
                        '<span class="fi ' + flagClass(row.IconFlag) + '"></span>' +
                        '<b>' + (row.CurrencyID || '') + '</b> ' +
                        'Jual <span class="s">' + fmtRate(row.SellRate) + '</span> · ' +
                        'Beli <span class="b">' + fmtRate(row.BuyRate) + '</span>' +
                        '</span>';
                });
            }
            t.innerHTML = html;
        }

        // ---------- Refresh data ----------
        function applyData(rows, serverTime) {
            // simpan nilai lama untuk deteksi tren
            var prev = {};
            state.rows.forEach(function (r) { prev[r.CurrencyID] = r; });
            state.last = prev;
            state.rows = rows || [];
            render();
            renderTicker();

            var d = serverTime ? new Date(serverTime) : new Date();
            document.getElementById('updated').textContent =
                pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds());
        }

        function fetchData() {
            fetch(DATA_URL, { cache: 'no-store' })
                .then(function (r) { return r.json(); })
                .then(function (j) { applyData(j.rows, j.server_time); })
                .catch(function () { /* pertahankan tampilan terakhir bila gagal */ });
        }

        function nextPage() {
            if (state.pages <= 1) return;
            state.page = (state.page + 1) % state.pages;
            render();
        }

        // ---------- Init ----------
        tickClock();
        setInterval(tickClock, 1000);

        applyData(state.rows, null);  // render awal dari data server
        fetchData();                  // sinkron pertama
        setInterval(fetchData, REFRESH_MS);
        setInterval(nextPage, PAGE_MS);
    </script>
</body>

</html>
