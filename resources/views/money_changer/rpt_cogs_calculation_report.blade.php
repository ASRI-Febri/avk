@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">PERIODE HPP</td>
                    <td class="param-value">: {{ $fields['COGSPeriod'] }}</td>
                </tr>
            </table>
        </div>
    </div>
    <br/>
    <hr>
    <br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        @php
            $row_number = 0;
            $group_number = 0;
            $group_a1 = '';
            $group_a2 = '';

            $prev_currency_id = '';

            $total_bb_foreign = 0;
            $total_bb_base = 0;
            $total_in_foreign = 0;
            $total_in_base = 0;
            $total_out_foreign = 0;
            $total_out_base = 0;
            $total_eb_foreign = 0;
            $total_eb_base = 0;
            $total_cogs = 0;
            $total_gross_profit = 0;

            $group_bb_foreign = 0;
            $group_bb_base = 0;
            $group_in_foreign = 0;
            $group_in_base = 0;
            $group_out_foreign = 0;
            $group_out_base = 0;
            $group_eb_foreign = 0;
            $group_eb_base = 0;
            $group_cogs = 0;
            $group_gross_profit = 0;
        @endphp
        @if($records)
        @foreach ($records as $row)

            @php
                $row_number += 1;
                $group_a1 = $row->CurrencyID . ' - ' . $row->CurrencyName;
                //$prev_currency_id = $row->CurrencyID;

                $total_bb_foreign += $row->BB_ForeignAmount;
                $total_bb_base    += $row->BB_BaseAmount;
                $total_in_foreign += $row->IN_ForeignAmount;
                $total_in_base    += $row->IN_BaseAmount;
                $total_out_foreign += $row->Sold_ForeignAmount;
                $total_out_base    += $row->Sold_BaseAmount;
                $total_eb_foreign += $row->EB_ForeignAmount;
                $total_eb_base    += $row->EB_BaseAmount;
                $total_gross_profit += $row->GrossProfitAmount;
                $total_cogs += $row->COGSAmount;
            @endphp

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    <tr>
                        <td class="text-right" colspan="3"><strong>SUB TOTAL</strong></td>

                        <td></td>
                        <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_bb_foreign,0,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_bb_base,0,'.',',') }}</strong></td>

                        <td></td>
                        <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_in_foreign,0,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_in_base,0,'.',',') }}</strong></td>
                        <td></td>
                        <td></td>
                        <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_out_foreign,0,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_out_base,0,'.',',') }}</strong></td>
                        
                        <td></td>
                        <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_eb_foreign,0,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_eb_base,0,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_cogs,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_gross_profit,2,'.',',') }}</strong></td>
                    </tr>
                    <tr>
                        <td colspan="18">&nbsp;</td>
                    </tr>
                @endif

                <thead>
                    <tr class="bg-info">
                        <th class="text-start" colspan="18">{{ strtoupper($group_a1) }}</th>
                    </tr>
                    <tr>
                        <th rowspan="2">#</th>
                        <th rowspan="2">CURRENCY</th>
                        <th rowspan="2">VALAS</th>
                        <th colspan="3" class="text-center">AWAL</th>
                        <th colspan="3" class="text-center">PEMBELIAN</th>
                        <th rowspan="2" class="text-center">RATA-RATA</th>
                        <th colspan="3" class="text-center">PENJUALAN</th>
                        <th colspan="3" class="text-center">AKHIR</th>
                        <th rowspan="2" class="text-center">HPP</th>
                        <th rowspan="2" class="text-center">GROSS PROFIT</th>
                    </tr>
                    <tr>
                        <th class="text-center">QTY</th>
                        <th class="text-center">VALAS</th>
                        <th class="text-center">RUPIAH</th>
                        <th class="text-center">QTY</th>
                        <th class="text-center">VALAS</th>
                        <th class="text-center">RUPIAH</th>
                        <th class="text-center">QTY</th>
                        <th class="text-center">VALAS</th>
                        <th class="text-center">RUPIAH</th>
                        <th class="text-center">QTY</th>
                        <th class="text-center">VALAS</th>
                        <th class="text-center">RUPIAH</th>
                    </tr>
                </thead>
                <tbody>

                @php
                    $group_number = 0;
                    $group_bb_foreign = 0;
                    $group_bb_base = 0;
                    $group_in_foreign = 0;
                    $group_in_base = 0;
                    $group_out_foreign = 0;
                    $group_out_base = 0;
                    $group_eb_foreign = 0;
                    $group_eb_base = 0;
                    $group_gross_profit = 0;
                    $group_cogs = 0;

                    $group_a2 = $group_a1;
                    $prev_currency_id = $row->CurrencyID;
                @endphp

            @endif

            @php
                $group_number += 1;

                $group_bb_foreign += $row->BB_ForeignAmount;
                $group_bb_base    += $row->BB_BaseAmount;
                $group_in_foreign += $row->IN_ForeignAmount;
                $group_in_base    += $row->IN_BaseAmount;
                $group_out_foreign += $row->Sold_ForeignAmount;
                $group_out_base    += $row->Sold_BaseAmount;
                $group_eb_foreign += $row->EB_ForeignAmount;
                $group_eb_base    += $row->EB_BaseAmount;
                $group_gross_profit += $row->GrossProfitAmount;
                $group_cogs += $row->COGSAmount;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td>{{ $row->CurrencyID }}</td>
                <td>{{ $row->ValasName }}</td>

                <td class="text-right">{{ number_format($row->BB_Qty,0,'.',',') }}</td>
                <td class="text-right">{{ $row->CurrencyID. ' ' . number_format($row->BB_ForeignAmount,0,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BB_BaseAmount,0,'.',',') }}</td>

                <td class="text-right">{{ number_format($row->IN_Qty,0,'.',',') }}</td>
                <td class="text-right">{{ $row->CurrencyID. ' ' .  number_format($row->IN_ForeignAmount,0,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->IN_BaseAmount,0,'.',',') }}</td>

                <td class="text-right">{{ number_format($row->AverageAmount,4,'.',',') }}</td>

                <td class="text-right">{{ number_format($row->Sold_Qty,0,'.',',') }}</td>
                <td class="text-right">{{ $row->CurrencyID. ' ' . number_format($row->Sold_ForeignAmount,0,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->Sold_BaseAmount,0,'.',',') }}</td>

                <td class="text-right">{{ number_format($row->EB_Qty,0,'.',',') }}</td>
                <td class="text-right">{{ $row->CurrencyID. ' ' . number_format($row->EB_ForeignAmount,0,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->EB_BaseAmount,0,'.',',') }}</td>
                
                <td class="text-right">{{ number_format($row->COGSAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->GrossProfitAmount,2,'.',',') }}</td>
            </tr>

        @endforeach
        @endif

        <tr>
            <td class="text-right" colspan="3"><strong>SUB TOTAL</strong></td>

            <td></td>
            <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_bb_foreign,0,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_bb_base,0,'.',',') }}</strong></td>

            <td></td>
            <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_in_foreign,0,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_in_base,0,'.',',') }}</strong></td>
            <td></td>
            <td></td>
            <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_out_foreign,0,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_out_base,0,'.',',') }}</strong></td>
            
            <td></td>
            <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_eb_foreign,0,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_eb_base,0,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_cogs,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_gross_profit,2,'.',',') }}</strong></td>
        </tr>

        <tr>
            <td class="text-right" colspan="3"><strong>TOTAL</strong></td>

            <td></td>
            <td class="text-right"><strong></strong></td>
            <td class="text-right"><strong></strong></td>

            <td></td>
            <td class="text-right"><strong></strong></td>
            <td class="text-right"><strong></strong></td>
            <td></td>
            <td></td>
            <td class="text-right"><strong></strong></td>
            <td class="text-right"><strong>{{ number_format($total_out_base,0,'.',',') }}</strong></td>
            
            <td></td>
            <td class="text-right"><strong></strong></td>
            <td class="text-right"><strong></td>
            <td class="text-right"><strong></td>
            <td class="text-right"><strong>{{ number_format($total_gross_profit,2,'.',',') }}</strong></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
