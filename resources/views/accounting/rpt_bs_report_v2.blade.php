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
                <th>NO</th>
                <th>COA</th>
                <th>URAIAN</th>
                <th class="text-center" style="width:20%;">JUMLAH</th>
                <th class="text-center" style="width:20%;">SUBTOTAL / TOTAL</th>
            </tr>
        </thead>
        <tbody>

            {{-- ============================== ASET ============================== --}}
            @include('accounting.partials._bs_section', [
                'section'      => $report['sections']['asset'],
                'totalLabel'   => 'TOTAL ASET',
            ])

            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================== LIABILITAS ============================== --}}
            @include('accounting.partials._bs_section', [
                'section'      => $report['sections']['liability'],
                'totalLabel'   => 'TOTAL LIABILITAS',
            ])

            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================== EKUITAS ============================== --}}
            @include('accounting.partials._bs_section', [
                'section'      => $report['sections']['equity'],
                'totalLabel'   => 'TOTAL EKUITAS',
            ])

            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================== RINGKASAN & BALANCE CHECK ============================== --}}
            <tr style="background:#d9edf7;">
                <th class="text-left" colspan="5">RINGKASAN</th>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>TOTAL ASET</strong></td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['asset'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="text-right">
                    <strong>TOTAL LIABILITAS + EKUITAS</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['totals']['liab_plus_eq'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>SELISIH (Aset - (Liabilitas + Ekuitas))</strong></td>
                <td class="text-right">
                    @if($report['totals']['is_balanced'])
                        <strong style="color:green;">
                            {{ number_format($report['totals']['difference'], 2, '.', ',') }} &nbsp; (Balanced)
                        </strong>
                    @else
                        <strong style="color:red;">
                            {{ number_format($report['totals']['difference'], 2, '.', ',') }} &nbsp; (Tidak Balanced)
                        </strong>
                    @endif
                </td>
            </tr>

        </tbody>
    </table>

@endsection
