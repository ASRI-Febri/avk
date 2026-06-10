@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    @php
        // ---- Tren 12 bulan ----
        $cats = []; $salesArr = []; $purchArr = []; $trxArr = [];
        foreach ($records_trend as $r) {
            $cats[]     = trim($r->PeriodLabel);
            $salesArr[] = round((float) $r->SalesBase, 2);
            $purchArr[] = round((float) $r->PurchaseBase, 2);
            $trxArr[]   = (int) $r->SalesTrx + (int) $r->PurchaseTrx;
        }
        // ---- KPI periode berjalan (baris terakhir) ----
        $cur = (count($records_trend) > 0) ? end($records_trend) : null;
        $curSales = $cur ? (float) $cur->SalesBase : 0;
        $curPurch = $cur ? (float) $cur->PurchaseBase : 0;
        $curTrx   = $cur ? ((int) $cur->SalesTrx + (int) $cur->PurchaseTrx) : 0;
        $totalVol = $curSales + $curPurch;
        $avgTicket = $curTrx != 0 ? $totalVol / $curTrx : 0;

        // ---- Per mata uang ----
        $vCats = []; $vSales = []; $vPurch = [];
        foreach ($records_currency as $c) {
            $vCats[]  = trim($c->CurrencyID);
            $vSales[] = round((float) $c->SalesBase, 2);
            $vPurch[] = round((float) $c->PurchaseBase, 2);
        }
    @endphp

    @include('money_changer.analytic_filter')

    <!-- KPI CARDS -->
    <div class="row mb-2">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Volume Jual ({{ $PeriodDesc }})</p>
                <h5 class="mb-0">IDR {{ number_format($curSales, 0) }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Volume Beli</p>
                <h5 class="mb-0">IDR {{ number_format($curPurch, 0) }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Jumlah Transaksi</p>
                <h5 class="mb-0">{{ number_format($curTrx, 0) }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Rata-rata Tiket</p>
                <h5 class="mb-0">IDR {{ number_format($avgTicket, 0) }}</h5>
            </div></div>
        </div>
    </div>

    <!-- TREND CHART -->
    <div class="card mb-3">
        <div class="card-header"><h4 class="card-title mb-0">Tren Volume Transaksi (12 Bulan)</h4></div>
        <div class="card-body"><div id="chart-volume-trend"></div></div>
    </div>

    <div class="row">
        <div class="col-lg-7 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Volume Jual vs Beli per Mata Uang</h4></div>
                <div class="card-body"><div id="chart-volume-currency"></div></div>
            </div>
        </div>
        <div class="col-lg-5 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Kontribusi Volume Jual per Mata Uang</h4></div>
                <div class="card-body"><div id="chart-volume-share"></div></div>
            </div>
        </div>
    </div>

    <!-- TABLE -->
    <div class="card mb-3">
        <div class="card-header"><h4 class="card-title mb-0">Volume per Mata Uang ({{ $PeriodDesc }})</h4></div>
        <div class="card-body table-responsive">
            <table class="table table-bordered table-striped mb-0">
                <thead>
                    <tr class="text-secondary">
                        <th>Mata Uang</th>
                        <th class="text-end">Volume Jual (IDR)</th>
                        <th class="text-end">Trx Jual</th>
                        <th class="text-end">Volume Beli (IDR)</th>
                        <th class="text-end">Trx Beli</th>
                        <th class="text-end">Total (IDR)</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($records_currency as $c)
                        <tr>
                            <td>{{ $c->CurrencyID }} - {{ $c->CurrencyName }}</td>
                            <td class="text-end">{{ number_format((float) $c->SalesBase, 0) }}</td>
                            <td class="text-end">{{ number_format((int) $c->SalesTrx, 0) }}</td>
                            <td class="text-end">{{ number_format((float) $c->PurchaseBase, 0) }}</td>
                            <td class="text-end">{{ number_format((int) $c->PurchaseTrx, 0) }}</td>
                            <td class="text-end fw-semibold">{{ number_format((float) $c->TotalBase, 0) }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="6" class="text-center text-muted">Tidak ada transaksi pada periode ini.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <script src="{{ URL::asset('assets/libs/apexcharts/apexcharts.min.js') }}"></script>
    <script>
        (function () {
            var fmt = function (val) { return 'IDR ' + new Intl.NumberFormat('id-ID').format(Math.round(val)); };
            var compact = function (v) { return new Intl.NumberFormat('id-ID', { notation: 'compact' }).format(v); };

            new ApexCharts(document.querySelector("#chart-volume-trend"), {
                chart: { type: 'area', height: 350, toolbar: { show: false } },
                series: [
                    { name: 'Volume Jual', data: @json($salesArr) },
                    { name: 'Volume Beli', data: @json($purchArr) }
                ],
                stroke: { width: 2, curve: 'smooth' },
                fill: { type: 'gradient', gradient: { opacityFrom: 0.4, opacityTo: 0.05 } },
                colors: ['#2ed8b6', '#4099ff'],
                xaxis: { categories: @json($cats) },
                yaxis: { labels: { formatter: compact } },
                dataLabels: { enabled: false },
                tooltip: { y: { formatter: fmt } },
                legend: { position: 'top' }
            }).render();

            new ApexCharts(document.querySelector("#chart-volume-currency"), {
                chart: { type: 'bar', height: 340, toolbar: { show: false } },
                series: [
                    { name: 'Jual', data: @json($vSales) },
                    { name: 'Beli', data: @json($vPurch) }
                ],
                plotOptions: { bar: { borderRadius: 3, columnWidth: '60%' } },
                colors: ['#2ed8b6', '#4099ff'],
                xaxis: { categories: @json($vCats) },
                yaxis: { labels: { formatter: compact } },
                dataLabels: { enabled: false },
                tooltip: { y: { formatter: fmt } },
                legend: { position: 'top' }
            }).render();

            new ApexCharts(document.querySelector("#chart-volume-share"), {
                chart: { type: 'pie', height: 340 },
                series: @json($vSales),
                labels: @json($vCats),
                legend: { position: 'bottom' },
                tooltip: { y: { formatter: fmt } }
            }).render();
        })();
    </script>

@endsection
