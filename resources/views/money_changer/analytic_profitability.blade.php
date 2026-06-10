@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    @php
        // ---- Tren 12 bulan ----
        $cats = []; $revArr = []; $cogsArr = []; $gpArr = []; $npArr = [];
        foreach ($records_trend as $r) {
            $rev = (float) $r->Revenue; $cogs = (float) $r->COGS; $opex = (float) $r->OpEx;
            $cats[]   = trim($r->PeriodLabel);
            $revArr[] = round($rev, 2);
            $cogsArr[]= round($cogs, 2);
            $gpArr[]  = round($rev - $cogs, 2);
            $npArr[]  = round($rev - $cogs - $opex, 2);
        }
        // ---- KPI periode berjalan (baris terakhir tren) ----
        $cur = (count($records_trend) > 0) ? end($records_trend) : null;
        $curRev  = $cur ? (float) $cur->Revenue : 0;
        $curCogs = $cur ? (float) $cur->COGS : 0;
        $curOpex = $cur ? (float) $cur->OpEx : 0;
        $curGp   = $curRev - $curCogs;
        $curNp   = $curGp - $curOpex;
        $gmPct   = $curRev != 0 ? ($curGp / $curRev) * 100 : 0;
        $nmPct   = $curRev != 0 ? ($curNp / $curRev) * 100 : 0;

        // ---- Margin per mata uang ----
        $mCats = []; $mProfit = []; $mSpreadPct = [];
        foreach ($records_margin as $m) {
            $spread = (float) $m->AvgSellRate - (float) $m->AvgBuyRate;
            $m->Spread = $spread;
            $m->SpreadPct = ((float) $m->AvgBuyRate != 0) ? ($spread / (float) $m->AvgBuyRate) * 100 : 0;
            $m->EstGrossProfit = $spread * (float) $m->SellForeign;
            $mCats[]      = trim($m->CurrencyID);
            $mProfit[]    = round($m->EstGrossProfit, 2);
            $mSpreadPct[] = round($m->SpreadPct, 2);
        }
    @endphp

    @include('money_changer.analytic_filter')

    <!-- KPI CARDS -->
    <div class="row mb-2">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Revenue ({{ $PeriodDesc }})</p>
                <h5 class="mb-0">IDR {{ number_format($curRev, 0) }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">HPP / COGS</p>
                <h5 class="mb-0">IDR {{ number_format($curCogs, 0) }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Laba Kotor</p>
                <h5 class="mb-0 text-success">IDR {{ number_format($curGp, 0) }}</h5>
                <small class="text-muted">Gross Margin {{ number_format($gmPct, 1) }}%</small>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Laba Bersih</p>
                <h5 class="mb-0 {{ $curNp >= 0 ? 'text-success' : 'text-danger' }}">IDR {{ number_format($curNp, 0) }}</h5>
                <small class="text-muted">Net Margin {{ number_format($nmPct, 1) }}%</small>
            </div></div>
        </div>
    </div>

    <!-- TREND CHART -->
    <div class="card mb-3">
        <div class="card-header"><h4 class="card-title mb-0">Tren Profitabilitas (12 Bulan)</h4></div>
        <div class="card-body"><div id="chart-profit-trend"></div></div>
    </div>

    <div class="row">
        <div class="col-lg-6 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Estimasi Laba Kotor per Mata Uang</h4></div>
                <div class="card-body"><div id="chart-margin-profit"></div></div>
            </div>
        </div>
        <div class="col-lg-6 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Spread Beli-Jual per Mata Uang (%)</h4></div>
                <div class="card-body"><div id="chart-margin-spread"></div></div>
            </div>
        </div>
    </div>

    <!-- MARGIN TABLE -->
    <div class="card mb-3">
        <div class="card-header"><h4 class="card-title mb-0">Detail Spread & Margin per Mata Uang ({{ $PeriodDesc }})</h4></div>
        <div class="card-body table-responsive">
            <table class="table table-bordered table-striped mb-0">
                <thead>
                    <tr class="text-secondary">
                        <th>Mata Uang</th>
                        <th class="text-end">Volume Jual</th>
                        <th class="text-end">Kurs Beli Rata2</th>
                        <th class="text-end">Kurs Jual Rata2</th>
                        <th class="text-end">Spread</th>
                        <th class="text-end">Spread %</th>
                        <th class="text-end">Est. Laba Kotor (IDR)</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($records_margin as $m)
                        <tr>
                            <td>{{ $m->CurrencyID }} - {{ $m->CurrencyName }}</td>
                            <td class="text-end">{{ number_format((float) $m->SellForeign, 2) }}</td>
                            <td class="text-end">{{ number_format((float) $m->AvgBuyRate, 2) }}</td>
                            <td class="text-end">{{ number_format((float) $m->AvgSellRate, 2) }}</td>
                            <td class="text-end">{{ number_format((float) $m->Spread, 2) }}</td>
                            <td class="text-end">{{ number_format((float) $m->SpreadPct, 2) }}%</td>
                            <td class="text-end {{ $m->EstGrossProfit >= 0 ? 'text-success' : 'text-danger' }}">
                                {{ number_format((float) $m->EstGrossProfit, 0) }}
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="7" class="text-center text-muted">Tidak ada transaksi pada periode ini.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <script src="{{ URL::asset('assets/libs/apexcharts/apexcharts.min.js') }}"></script>
    <script>
        (function () {
            var fmt = function (val) { return 'IDR ' + new Intl.NumberFormat('id-ID').format(Math.round(val)); };

            new ApexCharts(document.querySelector("#chart-profit-trend"), {
                chart: { type: 'line', height: 350, toolbar: { show: false } },
                series: [
                    { name: 'Revenue', type: 'column', data: @json($revArr) },
                    { name: 'HPP', type: 'column', data: @json($cogsArr) },
                    { name: 'Laba Kotor', type: 'line', data: @json($gpArr) },
                    { name: 'Laba Bersih', type: 'line', data: @json($npArr) }
                ],
                stroke: { width: [0, 0, 3, 3], curve: 'smooth' },
                colors: ['#4099ff', '#ff5b5b', '#2ed8b6', '#ffb64d'],
                xaxis: { categories: @json($cats) },
                yaxis: { labels: { formatter: function (v) { return new Intl.NumberFormat('id-ID', { notation: 'compact' }).format(v); } } },
                dataLabels: { enabled: false },
                tooltip: { y: { formatter: fmt } },
                legend: { position: 'top' }
            }).render();

            new ApexCharts(document.querySelector("#chart-margin-profit"), {
                chart: { type: 'bar', height: 320, toolbar: { show: false } },
                series: [{ name: 'Est. Laba Kotor', data: @json($mProfit) }],
                plotOptions: { bar: { horizontal: true, borderRadius: 3 } },
                colors: ['#2ed8b6'],
                xaxis: { categories: @json($mCats) },
                dataLabels: { enabled: false },
                tooltip: { y: { formatter: fmt } }
            }).render();

            new ApexCharts(document.querySelector("#chart-margin-spread"), {
                chart: { type: 'bar', height: 320, toolbar: { show: false } },
                series: [{ name: 'Spread %', data: @json($mSpreadPct) }],
                plotOptions: { bar: { borderRadius: 3, columnWidth: '55%' } },
                colors: ['#4099ff'],
                xaxis: { categories: @json($mCats) },
                dataLabels: { enabled: true, formatter: function (v) { return v + '%'; } },
                tooltip: { y: { formatter: function (v) { return v + '%'; } } }
            }).render();
        })();
    </script>

@endsection
