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
                {{-- <tr>
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
                </tr>      --}}
                <tr>
                    <td class="param-key">PERIODE</td>
                    <td class="param-value">: {{ $fields['Period'] }}</td>
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
                
                $bb_qty += $row->OpeningQty;
                $in_qty += $row->InQty;
                $out_qty += $row->OutQty;
                $eb_qty += $row->ClosingQty;
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
                        <th>CURRENCY</th>
                        <th>SKU</th>
                        <th>NAMA BARANG</th>
                        <th class="text-center">QTY AWAL</th>
                        <th class="text-center">QTY BELI</th>
                        <th class="text-center">NILAI PEROLEHAN</th>
                        <th class="text-center">QTY JUAL</th>
                        <th class="text-center">HARGA JUAL</th>   
                        <th class="text-center">QTY AKHIR</th>  
                        <th class="text-center">AVERAGE</th> 
                        <th class="text-center">COGS</th> 
                        <th class="text-center">INVENTORY</th>        
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

                $group_bb_qty += $row->OpeningQty;
                $group_in_qty += $row->InQty;
                $group_out_qty += $row->OutQty;
                $group_eb_qty += $row->ClosingQty;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td>{{ $row->CurrencyName }}</td>
                <td>{{ $row->ValasSKU }}</td>
                <td>{{ $row->ValasName }}</td>
                
                <td class="text-right">{{ number_format($row->OpeningQty,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->InQty,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->InValue,2,'.',',') }}</td>
                
                <td class="text-right">{{ number_format($row->OutQty,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->OutValue,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->ClosingQty,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->AverageValue,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->COGSValue,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->InventoryValue,2,'.',',') }}</td>
                
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