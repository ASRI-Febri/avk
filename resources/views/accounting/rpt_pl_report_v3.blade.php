@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    {{-- $report comes pre-built from ProfitLossReportBuilder — view has zero business logic --}}

    <!-- REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">Profit &amp; Loss Period</td>
                    <td class="param-value">
                        : {{ DateTime::createFromFormat('Ym', $report['period'])->format('M Y') }}
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <br/><hr><br/>

    <!-- REPORT DATA -->
    <table id="table-report" class="minimalistBlack" style="width:100%;">
        <thead>
            <tr>
                <th rowspan="2" style="width:4%;">#</th>
                <th rowspan="2" style="width:12%;">COA</th>
                <th rowspan="2">COA DESCRIPTION</th>
                <th colspan="3" class="text-center" style="width:48%;">AMOUNT</th>
            </tr>
            <tr>
                <th class="text-center" style="width:16%;">{{ $report['labels']['prior'] }}</th>
                <th class="text-center" style="width:16%;">{{ $report['labels']['current'] }}</th>
                <th class="text-center" style="width:16%;">{{ $report['labels']['ytd'] }}</th>
            </tr>
        </thead>
        <tbody>

            @foreach($report['sections'] as $section)

                {{-- Section header --}}
                <tr class="bg-secondary">
                    <th class="text-left" colspan="6" style="background:#d9edf7;">
                        {{ $section['title'] }}
                    </th>
                </tr>

                {{-- Render every top-level node via the recursive partial --}}
                @foreach($section['nodes'] as $node)
                    @include('accounting.partials._pl_node', ['node' => $node])
                @endforeach

                {{-- Section result --}}
                <tr>
                    <td colspan="3" class="text-right">
                        <strong>{{ $section['result']['label'] }}</strong>
                    </td>
                    <td class="text-right">
                        <strong>{{ number_format($section['result']['amount_prior'], 2, '.', ',') }}</strong>
                    </td>
                    <td class="text-right">
                        <strong>{{ number_format($section['result']['amount_current'], 2, '.', ',') }}</strong>
                    </td>
                    <td class="text-right">
                        <strong>{{ number_format($section['result']['amount'], 2, '.', ',') }}</strong>
                    </td>
                </tr>

                {{-- spacer --}}
                <tr><td colspan="6">&nbsp;</td></tr>

            @endforeach

            {{-- Grand total --}}
            <tr class="bg-info">
                <th class="text-left" colspan="3">RINGKASAN</th>
                <th class="text-center">{{ $report['labels']['prior'] }}</th>
                <th class="text-center">{{ $report['labels']['current'] }}</th>
                <th class="text-center">{{ $report['labels']['ytd'] }}</th>
            </tr>
            <tr>
                <td colspan="3" class="text-right"><strong>TOTAL PENDAPATAN</strong></td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_pendapatan_prior'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_pendapatan_current'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_pendapatan'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="text-right"><strong>TOTAL BIAYA</strong></td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_biaya_prior'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_biaya_current'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_biaya'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="text-right">
                    <strong>LABA / (RUGI) BERSIH (Total Pendapatan - Total Biaya)</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['laba_bersih_prior'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['laba_bersih_current'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['laba_bersih'], 2, '.', ',') }}</strong>
                </td>
            </tr>

        </tbody>
    </table>

@endsection
