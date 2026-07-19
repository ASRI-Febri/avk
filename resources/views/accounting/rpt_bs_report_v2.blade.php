@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    {{-- $report built by BalanceSheetReportBuilder — view is presentational only --}}

    <!-- REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">COMPANY</td>
                    <td class="param-value">: {{ strtoupper($fields['CompanyDesc'] ?? '') }}</td>
                </tr>
                <tr>
                    <td class="param-key">PROFIT CENTER</td>
                    <td class="param-value">: {{ strtoupper($fields['BranchDesc'] ?? '') }}</td>
                </tr>
                <tr>
                    <td class="param-key">PER TANGGAL</td>
                    <td class="param-value">: {{ date('d F Y', strtotime($report['period_end'])) }}</td>
                </tr>
            </table>
        </div>
    </div>
    <br/><hr><br/>

    <!-- REPORT DATA -->
    <table id="table-report" class="minimalistBlack" style="width:100%;">
        <thead>
            <tr>
                <th rowspan="2" style="width:4%;">NO</th>
                <th rowspan="2" style="width:12%;">COA</th>
                <th rowspan="2">URAIAN</th>
                <th colspan="3" class="text-center" style="width:48%;">JUMLAH</th>
            </tr>
            <tr>
                <th class="text-center" style="width:16%;">{{ $report['labels']['prior'] }}</th>
                <th class="text-center" style="width:16%;">{{ $report['labels']['current'] }}</th>
                <th class="text-center" style="width:16%;">{{ $report['labels']['ending'] }}</th>
            </tr>
        </thead>
        <tbody>

            {{-- ============================== ASET ============================== --}}
            @include('accounting.partials._bs_section', [
                'section'      => $report['sections']['asset'],
                'totalLabel'   => 'TOTAL ASET',
            ])

            <tr><td colspan="6">&nbsp;</td></tr>

            {{-- ============================== LIABILITAS ============================== --}}
            @include('accounting.partials._bs_section', [
                'section'      => $report['sections']['liability'],
                'totalLabel'   => 'TOTAL LIABILITAS',
            ])

            <tr><td colspan="6">&nbsp;</td></tr>

            {{-- ============================== EKUITAS ============================== --}}
            @include('accounting.partials._bs_section', [
                'section'      => $report['sections']['equity'],
                'totalLabel'   => 'TOTAL EKUITAS',
            ])

            <tr><td colspan="6">&nbsp;</td></tr>

            {{-- ============================== RINGKASAN & BALANCE CHECK ============================== --}}
            <tr style="background:#d9edf7;">
                <th class="text-left" colspan="3">RINGKASAN</th>
                <th class="text-center">{{ $report['labels']['prior'] }}</th>
                <th class="text-center">{{ $report['labels']['current'] }}</th>
                <th class="text-center">{{ $report['labels']['ending'] }}</th>
            </tr>
            <tr>
                <td colspan="3" class="text-right"><strong>TOTAL ASET</strong></td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['asset']['prior'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['asset']['current'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['asset']['ending'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="text-right">
                    <strong>TOTAL LIABILITAS + EKUITAS</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['liab_plus_eq']['prior'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['liab_plus_eq']['current'], 2, '.', ',') }}</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['liab_plus_eq']['ending'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="text-right"><strong>SELISIH (Aset - (Liabilitas + Ekuitas))</strong></td>
                @foreach(['prior','current','ending'] as $col)
                    <td class="text-right">
                        @if($report['totals']['is_balanced'][$col])
                            <strong style="color:green;">
                                {{ number_format($report['totals']['difference'][$col], 2, '.', ',') }} &nbsp; (Balanced)
                            </strong>
                        @else
                            <strong style="color:red;">
                                {{ number_format($report['totals']['difference'][$col], 2, '.', ',') }} &nbsp; (Tidak Balanced)
                            </strong>
                        @endif
                    </td>
                @endforeach
            </tr>

        </tbody>
    </table>

@endsection
