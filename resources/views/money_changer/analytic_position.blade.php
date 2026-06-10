@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    @php
        $rows = $records_position;
        $totalValue = 0;
        foreach ($rows as $r) { $totalValue += (float) $r->PositionValueIDR; }

        $labels = []; $values = []; $maxPct = 0; $maxCur = '-';
        foreach ($rows as $r) {
            $val = (float) $r->PositionValueIDR;
            $pct = $totalValue != 0 ? ($val / $totalValue) * 100 : 0;
            $r->Pct = $pct;
            if ($pct > $maxPct) { $maxPct = $pct; $maxCur = trim($r->CurrencyID); }
            $labels[] = trim($r->CurrencyID);
            $values[] = round($val, 2);
        }
        $numCurrency = count($rows);

        // Indeks konsentrasi Herfindahl-Hirschman (0-10000); makin tinggi makin terkonsentrasi.
        $hhi = 0;
        foreach ($rows as $r) { $hhi += pow($r->Pct, 2); }
    @endphp

    @include('money_changer.analytic_filter')

    <!-- KPI CARDS -->
    <div class="row mb-2">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Total Nilai Posisi Valas</p>
                <h5 class="mb-0">IDR {{ number_format($totalValue, 0) }}</h5>
                <small class="text-muted">per {{ \Carbon\Carbon::parse($AsOfDate)->format('d M Y') }}</small>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Jumlah Mata Uang Dipegang</p>
                <h5 class="mb-0">{{ $numCurrency }}</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Eksposur Terbesar</p>
                <h5 class="mb-0">{{ $maxCur }} &middot; {{ number_format($maxPct, 1) }}%</h5>
            </div></div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card shadow-sm h-100"><div class="card-body">
                <p class="text-muted text-truncate mb-2">Indeks Konsentrasi (HHI)</p>
                <h5 class="mb-0 {{ $hhi > 2500 ? 'text-danger' : ($hhi > 1500 ? 'text-warning' : 'text-success') }}">
                    {{ number_format($hhi, 0) }}
                </h5>
                <small class="text-muted">{{ $hhi > 2500 ? 'Tinggi' : ($hhi > 1500 ? 'Sedang' : 'Rendah') }}</small>
            </div></div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-5 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Komposisi Eksposur (Nilai IDR)</h4></div>
                <div class="card-body"><div id="chart-position-donut"></div></div>
            </div>
        </div>
        <div class="col-lg-7 mb-3">
            <div class="card h-100">
                <div class="card-header"><h4 class="card-title mb-0">Nilai Posisi per Mata Uang</h4></div>
                <div class="card-body"><div id="chart-position-bar"></div></div>
            </div>
        </div>
    </div>

    <!-- POSITION TABLE -->
    <div class="card mb-3">
        <div class="card-header"><h4 class="card-title mb-0">Net Open Position per Mata Uang</h4></div>
        <div class="card-body table-responsive">
            <table class="table table-bordered table-striped mb-0">
                <thead>
                    <tr class="text-secondary">
                        <th>Mata Uang</th>
                        <th class="text-end">Posisi (Valas)</th>
                        <th class="text-end">Kurs Beli Rata2</th>
                        <th class="text-end">Nilai Posisi (IDR)</th>
                        <th class="text-end">% Eksposur</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($rows as $r)
                        <tr>
                            <td>{{ $r->CurrencyID }} - {{ $r->CurrencyName }}</td>
                            <td class="text-end">{{ number_format((float) $r->PositionForeign, 2) }}</td>
                            <td class="text-end">{{ number_format((float) $r->AvgRate, 2) }}</td>
                            <td class="text-end">{{ number_format((float) $r->PositionValueIDR, 0) }}</td>
                            <td class="text-end">{{ number_format((float) $r->Pct, 1) }}%</td>
                        </tr>
                    @empty
                        <tr><td colspan="5" class="text-center text-muted">Tidak ada posisi valas pada tanggal ini.</td></tr>
                    @endforelse
                </tbody>
                @if(count($rows) > 0)
                <tfoot>
                    <tr class="fw-bold">
                        <td>TOTAL</td>
                        <td></td>
                        <td></td>
                        <td class="text-end">{{ number_format($totalValue, 0) }}</td>
                        <td class="text-end">100%</td>
                    </tr>
                </tfoot>
                @endif
            </table>
        </div>
    </div>

    <script src="{{ URL::asset('assets/libs/apexcharts/apexcharts.min.js') }}"></script>
    <script>
        (function () {
            var fmt = function (val) { return 'IDR ' + new Intl.NumberFormat('id-ID').format(Math.round(val)); };
            var labels = @json($labels);
            var values = @json($values);

            new ApexCharts(document.querySelector("#chart-position-donut"), {
                chart: { type: 'donut', height: 340 },
                series: values,
                labels: labels,
                legend: { position: 'bottom' },
                dataLabels: { enabled: true, formatter: function (v) { return v.toFixed(1) + '%'; } },
                tooltip: { y: { formatter: fmt } }
            }).render();

            new ApexCharts(document.querySelector("#chart-position-bar"), {
                chart: { type: 'bar', height: 340, toolbar: { show: false } },
                series: [{ name: 'Nilai Posisi', data: values }],
                plotOptions: { bar: { horizontal: true, borderRadius: 3 } },
                colors: ['#4099ff'],
                xaxis: { categories: labels },
                dataLabels: { enabled: false },
                tooltip: { y: { formatter: fmt } }
            }).render();
        })();
    </script>

@endsection
