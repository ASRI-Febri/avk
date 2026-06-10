@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    @php
        $s = $summary;
        $cash      = $s ? (float) $s->Cash : 0;
        $bank      = $s ? (float) $s->Bank : 0;
        $invValas  = $s ? (float) $s->InventoryValas : 0;
        $invOther  = $s ? (float) $s->InventoryOther : 0;
        $ar        = $s ? (float) $s->Receivable : 0;
        $prepaid   = $s ? (float) $s->Prepaid : 0;
        $ap        = $s ? (float) $s->Payable : 0;
        $tax       = $s ? (float) $s->TaxPayable : 0;
        $custAdv   = $s ? (float) $s->CustomerAdvance : 0;
        $deposit   = $s ? (float) $s->Deposit : 0;

        $cashBank      = $cash + $bank;
        $currentAsset  = $cashBank + $invValas + $invOther + $ar + $prepaid;
        $currentLiab   = $ap + $tax + $custAdv + $deposit;
        $workingCap    = $currentAsset - $currentLiab;
        $currentRatio  = $currentLiab != 0 ? $currentAsset / $currentLiab : 0;
        // Quick ratio (kas+bank+piutang) / liabilitas lancar — persediaan dikeluarkan
        $quickRatio    = $currentLiab != 0 ? ($cashBank + $ar) / $currentLiab : 0;

        // ---- Tren ----
        $cats = []; $cashArr = []; $invArr = [];
        foreach ($records_trend as $r) {
            $cats[]    = trim($r->PeriodLabel);
            $cashArr[] = round((float) $r->CashBank, 2);
            $invArr[]  = round((float) $r->InventoryValas, 2);
        }

        $assetLabels = ['Kas','Bank','Persediaan Valas','Persediaan Lain','Piutang','Dibayar Dimuka'];
        $assetValues = [round($cash,2), round($bank,2), round($invValas,2), round($invOther,2), round($ar,2), round($prepaid,2)];
    @endphp

    @include('money_changer.analytic_filter')

    <!-- KPI CARDS -->
    <div class="row mb-2">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Kas & Bank</p>
                <h5 class="mb-0">IDR {{ number_format($cashBank, 0) }}</h5>
                <small class="text-muted">per {{ \Carbon\Carbon::parse($AsOfDate)->format('d M Y') }}</small>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Modal Kerja Bersih</p>
                <h5 class="mb-0 {{ $workingCap >= 0 ? 'text-success' : 'text-danger' }}">IDR {{ number_format($workingCap, 0) }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Current Ratio</p>
                <h5 class="mb-0 {{ $currentRatio >= 1 ? 'text-success' : 'text-danger' }}">{{ number_format($currentRatio, 2) }}x</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Quick Ratio</p>
                <h5 class="mb-0 {{ $quickRatio >= 1 ? 'text-success' : 'text-warning' }}">{{ number_format($quickRatio, 2) }}x</h5>
            </div></div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-7 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Tren Saldo Kas & Bank vs Persediaan Valas (12 Bulan)</h4></div>
                <div class="card-body"><div id="chart-liquidity-trend"></div></div>
            </div>
        </div>
        <div class="col-lg-5 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Komposisi Aset Lancar</h4></div>
                <div class="card-body"><div id="chart-asset-composition"></div></div>
            </div>
        </div>
    </div>

    <!-- WORKING CAPITAL TABLE -->
    <div class="row">
        <div class="col-lg-6 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Aset Lancar</h4></div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered mb-0">
                        <tbody>
                            <tr><td>Kas</td><td class="text-end">{{ number_format($cash, 0) }}</td></tr>
                            <tr><td>Bank</td><td class="text-end">{{ number_format($bank, 0) }}</td></tr>
                            <tr><td>Persediaan Valas</td><td class="text-end">{{ number_format($invValas, 0) }}</td></tr>
                            <tr><td>Persediaan Lain</td><td class="text-end">{{ number_format($invOther, 0) }}</td></tr>
                            <tr><td>Piutang Usaha</td><td class="text-end">{{ number_format($ar, 0) }}</td></tr>
                            <tr><td>Biaya Dibayar Dimuka</td><td class="text-end">{{ number_format($prepaid, 0) }}</td></tr>
                            <tr class="fw-bold"><td>Total Aset Lancar</td><td class="text-end">{{ number_format($currentAsset, 0) }}</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-lg-6 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Liabilitas Lancar</h4></div>
                <div class="card-body table-responsive">
                    <table class="table table-bordered mb-0">
                        <tbody>
                            <tr><td>Hutang Usaha</td><td class="text-end">{{ number_format($ap, 0) }}</td></tr>
                            <tr><td>Hutang Pajak / PPN</td><td class="text-end">{{ number_format($tax, 0) }}</td></tr>
                            <tr><td>Uang Muka Penjualan</td><td class="text-end">{{ number_format($custAdv, 0) }}</td></tr>
                            <tr><td>Titipan</td><td class="text-end">{{ number_format($deposit, 0) }}</td></tr>
                            <tr class="fw-bold"><td>Total Liabilitas Lancar</td><td class="text-end">{{ number_format($currentLiab, 0) }}</td></tr>
                            <tr class="fw-bold {{ $workingCap >= 0 ? 'table-success' : 'table-danger' }}">
                                <td>Modal Kerja Bersih</td><td class="text-end">{{ number_format($workingCap, 0) }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="{{ URL::asset('assets/libs/apexcharts/apexcharts.min.js') }}"></script>
    <script>
        (function () {
            var fmt = function (val) { return 'IDR ' + new Intl.NumberFormat('id-ID').format(Math.round(val)); };
            var compact = function (v) { return new Intl.NumberFormat('id-ID', { notation: 'compact' }).format(v); };

            new ApexCharts(document.querySelector("#chart-liquidity-trend"), {
                chart: { type: 'line', height: 360, toolbar: { show: false } },
                series: [
                    { name: 'Kas & Bank', data: @json($cashArr) },
                    { name: 'Persediaan Valas', data: @json($invArr) }
                ],
                stroke: { width: 3, curve: 'smooth' },
                colors: ['#4099ff', '#ffb64d'],
                xaxis: { categories: @json($cats) },
                yaxis: { labels: { formatter: compact } },
                dataLabels: { enabled: false },
                tooltip: { y: { formatter: fmt } },
                legend: { position: 'top' },
                markers: { size: 4 }
            }).render();

            new ApexCharts(document.querySelector("#chart-asset-composition"), {
                chart: { type: 'donut', height: 360 },
                series: @json($assetValues),
                labels: @json($assetLabels),
                legend: { position: 'bottom' },
                dataLabels: { enabled: true, formatter: function (v) { return v.toFixed(1) + '%'; } },
                tooltip: { y: { formatter: fmt } }
            }).render();
        })();
    </script>

@endsection
