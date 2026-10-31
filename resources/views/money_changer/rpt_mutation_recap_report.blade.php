@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    <style>
        .report-subtitle { text-align: center; font-size: 13px; line-height: 1.6; margin-bottom: 15px; }
        .report-subtitle .company { font-weight: bold; font-size: 14px; }
        table.minimalistBlack tr.row-total td.cell-blank { background: #8c8c8c; }
        table.minimalistBlack tr.row-total td { font-weight: bold; background: #CFCFCF; }
    </style>

    @php
        $money = function ($value, $decimals = 0) {
            return round($value, $decimals) != 0 ? number_format($value, $decimals, '.', ',') : '-';
        };
        $total = ['bb' => 0, 'in' => 0, 'sold' => 0, 'eb' => 0];
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div class="report-subtitle">
        TRANSAKSI JUAL BELI UKA<br/>
        PERIODE {{ $period_desc }}<br/>
        <span class="company">{{ $company_name }}</span>
    </div>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        <thead>
            <tr>
                <th rowspan="2">NO</th>
                <th rowspan="2">UKA</th>
                <th colspan="2">SALDO AWAL UKA (A)</th>
                <th colspan="2">PEMBELIAN (B)</th>
                <th colspan="2">PENJUALAN (C)</th>
                <th colspan="3">SALDO AKHIR UKA (D)</th>
            </tr>
            <tr>
                <th>UKA</th>
                <th>RP</th>
                <th>UKA</th>
                <th>RP</th>
                <th>UKA</th>
                <th>RP</th>
                <th>UKA</th>
                <th>KURS RATA-RATA</th>
                <th>RP</th>
            </tr>
        </thead>
        <tbody>
        @forelse($records as $i => $row)
            @php
                $total['bb'] += $row->BB_BaseAmount;
                $total['in'] += $row->IN_BaseAmount;
                $total['sold'] += $row->Sold_BaseAmount;
                $total['eb'] += $row->EB_BaseAmount;
            @endphp
            <tr>
                <td class="text-center">{{ $i + 1 }}</td>
                <td class="text-center">{{ $row->CurrencyID }}</td>
                <td class="text-right">{{ $money($row->BB_ForeignAmount) }}</td>
                <td class="text-right">{{ $money($row->BB_BaseAmount, 2) }}</td>
                <td class="text-right">{{ $money($row->IN_ForeignAmount) }}</td>
                <td class="text-right">{{ $money($row->IN_BaseAmount) }}</td>
                <td class="text-right">{{ $money($row->Sold_ForeignAmount) }}</td>
                <td class="text-right">{{ $money($row->Sold_BaseAmount) }}</td>
                <td class="text-right">{{ $money($row->EB_ForeignAmount) }}</td>
                <td class="text-right">{{ $money($row->EB_AverageRate, 2) }}</td>
                <td class="text-right">{{ $money($row->EB_BaseAmount, 2) }}</td>
            </tr>
        @empty
            <tr>
                <td colspan="11" class="text-center">
                    Belum ada data untuk periode ini. Jalankan Perhitungan HPP periode {{ $period_desc }} terlebih dahulu.
                </td>
            </tr>
        @endforelse
            <tr class="row-total">
                <td colspan="2" class="text-center">TOTAL</td>
                <td class="cell-blank"></td>
                <td class="text-right">{{ $money($total['bb'], 2) }}</td>
                <td class="cell-blank"></td>
                <td class="text-right">{{ $money($total['in']) }}</td>
                <td class="cell-blank"></td>
                <td class="text-right">{{ $money($total['sold']) }}</td>
                <td class="cell-blank"></td>
                <td class="cell-blank"></td>
                <td class="text-right">{{ $money($total['eb'], 2) }}</td>
            </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
