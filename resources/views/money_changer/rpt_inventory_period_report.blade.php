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
                    <td class="param-key">Tanggal Transaksi</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
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
                $group_a1 = $row->ValasSKU;           
                
                $bb_qty += $row->BB_Quantity;
                $in_qty += $row->IN_Quantity;
                $out_qty += $row->OUT_Quantity;
                $eb_qty += $row->EB_Quantity;
            @endphp 

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    <tr>
                        <td class="text-right" colspan="7"><strong>TOTAL</strong></td>
                        {{-- <td class="text-right"><strong>{{ number_format($group_bb_qty,2,'.',',') }}</strong></td> --}}
                        <td class="text-right"><strong>{{ number_format($group_in_qty,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_out_qty,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_eb_qty,2,'.',',') }}</strong></td>
                    </tr>
                @endif              
                 
                <thead>
                    <tr class="bg-info">   
                        <th class="text-start" colspan="11">{{ strtoupper($group_a1) }}</th>
                    </tr> 
                    <tr>
                        <th>#</th>            
                        <th>CABANG</th>
                        <th>CURRENCY</th>
                        <th>SKU</th>
                        <th>NAMA BARANG</th>
                        <th>KETERANGAN</th>
                        <th>NO TRANSAKSI</th>
                        {{-- <th class="text-center">AWAL</th> --}}
                        <th class="text-center">MASUK</th>
                        <th class="text-center">KELUAR</th>
                        <th class="text-center">SALDO</th>              
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

                $group_bb_qty += $row->BB_Quantity;
                $group_in_qty += $row->IN_Quantity;
                $group_out_qty += $row->OUT_Quantity;
                $group_eb_qty += $row->EB_Quantity;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td class="text-center">{{ $row->BranchName }}</td>
                <td>{{ $row->CurrencyName }}</td>
                <td>{{ $row->ValasSKU }}</td>
                <td>{{ $row->ValasName }}</td>
                <td>{{ $row->TransactionTypeName }}</td>
                <td>{{ $row->TransactionNo }}</td>
                
                {{-- <td class="text-right">{{ number_format($row->BB_Quantity,2,'.',',') }}</td> --}}
                <td class="text-right">{{ number_format($row->IN_Quantity,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->OUT_Quantity,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->EB_Quantity,2,'.',',') }}</td>
            </tr>           

        @endforeach
        <tr>
            <td class="text-right" colspan="7"><strong>TOTAL</strong></td>
            {{-- <td class="text-right"><strong>{{ number_format($group_bb_qty,2,'.',',') }}</strong></td> --}}
            <td class="text-right"><strong>{{ number_format($group_in_qty,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_out_qty,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_eb_qty,2,'.',',') }}</strong></td>
        </tr>

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