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
                    <td class="param-key">MATA UANG</td>
                    <td class="param-value">: {{ $CurrencyName }}</td>
                </tr>  
                <tr>
                    <td class="param-key">VALUTA ASING</td>
                    <td class="param-value">: {{ $ValasName }}</td>
                </tr>    
                <tr>
                    <td class="param-key">KONSUMEN</td>
                    <td class="param-value">: {{ $PartnerName }}</td>
                </tr>     
                <tr>
                    <td class="param-key">TANGGAL TRANSAKSI</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['TransactionDate'])) }}</td>
                </tr>  
            </table>
        </div>
        {{-- <div style="float:left;width:30%; text-align: right;">
            <button id="export_xls" name="export_xls" type="button" class="btn btn-xs btn-success btn-icon heading-btn"><i class="icon-file-excel"></i> Export Excel</button>
        </div> --}}
        
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

            $group_bb_qty = 0;
            $group_in_qty = 0;
            $group_out_qty = 0;
            $group_eb_qty = 0;

            $bb_qty = 0;
            $in_qty = 0;
            $out_qty = 0;
            $eb_qty = 0;
        @endphp
        @foreach ($records as $row)

            @php
                $row_number += 1;
                $group_a1 = $row->CurrencyName;           
                
                $bb_qty += $row->OpeningQuantity;
                $in_qty += $row->BuyQuantity;
                $out_qty += $row->SellQuantity;
                $eb_qty += $row->ClosingQuantity;
            @endphp 

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    {{-- <tr>
                        <td class="text-right" colspan="8"><strong>TOTAL</strong></td>
                        
                        <td class="text-right"><strong>{{ number_format($group_bb_qty,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_in_qty,2,'.',',') }}</strong></td>
                        
                        <td class="text-right"><strong>{{ number_format($group_out_qty,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_eb_qty,2,'.',',') }}</strong></td>
                    </tr> --}}
                @endif              
                 
                <thead>
                    <tr class="bg-info">   
                        <th class="text-start" colspan="15">{{ strtoupper($group_a1) }}</th>
                    </tr> 
                    <tr>
                        <th>#</th>            
                        <th>KONSUMEN</th>
                        <th>CURRENCY</th>
                        <th>SKU</th>
                        <th>NAMA BARANG</th>
                        <th>NO TRANSAKSI</th>
                        <th>TANGGAL</th>
                        <th class="text-center">QTY AWAL</th>
                        <th class="text-center">QTY BELI</th>
                        <th class="text-center">RATE BELI</th>
                        <th class="text-center">QTY JUAL</th>
                        <th class="text-center">RATE JUAL</th>   
                        <th class="text-center">QTY AKHIR SYSTEM</th>  
                        <th class="text-center">QTY AKHIR TELLER</th> 
                        <th class="text-center">SELISIH</th>        
                    </tr>
                </thead>
                <tbody>            

                @php
                    $group_number = 0;
                    $group_bb_qty = 0;
                    $group_in_qty = 0;
                    $group_out_qty = 0;
                    $group_eb_qty = 0;

                    $group_a2 = $group_a1;
                @endphp 

            @endif

            @php 
                $group_number += 1;

                $group_bb_qty += $row->OpeningQuantity;
                $group_in_qty += $row->BuyQuantity;
                $group_out_qty += $row->SellQuantity;
                $group_eb_qty += $row->ClosingQuantity;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td class="text-left">{{ $row->PartnerName }}</td>
                <td>{{ $row->CurrencyName }}</td>
                <td>{{ $row->ValasSKU }}</td>
                <td>{{ $row->ValasName }}</td>
               
                <td>
                    @if($row->IDX_M_TransactionType == 3) <!-- Purchase Order Valas -->
                        <a href="{{ url('mc-purchase-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                    @else
                        <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                    @endif 
                </td>
                <td>
                    {{ date('d M Y',strtotime($fields['TransactionDate'])) }}
                </td>
                
                <td class="text-right">{{ number_format($row->OpeningQuantity,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BuyQuantity,2,'.',',') }}</td>
                <td class="text-right">{{ 'IDR '. number_format($row->BuyRate,2,'.',',') }}</td>
                
                <td class="text-right">{{ number_format($row->SellQuantity,2,'.',',') }}</td>
                <td class="text-right">{{ 'IDR '. number_format($row->SellRate,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->ClosingQuantity,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->ClosingQuantityManual,2,'.',',') }}</td>

                @if($row->DiffQuantity <> 0)
                    <td class="text-right">
                        <span style="color:brown">{{ number_format($row->DiffQuantity,2,'.',',') }}</span>
                    </td>
                @else
                    <td class="text-right">
                        {{ number_format($row->DiffQuantity,2,'.',',') }}
                    </td>
                @endif 
                
            </tr>           

        @endforeach
        {{-- <tr>
            <td class="text-right" colspan="8"><strong>TOTAL</strong></td>
            
            <td class="text-right"><strong>{{ number_format($group_bb_qty,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_in_qty,2,'.',',') }}</strong></td>
            
            <td class="text-right"><strong>{{ number_format($group_out_qty,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_eb_qty,2,'.',',') }}</strong></td>
        </tr> --}}

        {{-- <tr>
            <td class="text-right" colspan="5"><strong>TOTAL</strong></td> --}}
            {{-- <td class="text-right"><strong>{{ number_format($bb_qty,2,'.',',') }}</strong></td> --}}
            {{-- <td class="text-right"><strong>{{ number_format($in_qty,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($out_qty,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($eb_qty,2,'.',',') }}</strong></td>
        </tr> --}}
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection