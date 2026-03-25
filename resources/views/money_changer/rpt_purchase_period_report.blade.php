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
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr>  
                <tr>
                    <td class="param-key">DIURUTKAN BERDASARKAN</td>
                    <td class="param-value">: {{ $fields['GroupReport'] }}</td>
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

            $group_qty = 0;
            $group_foreign_amount = 0;
            $group_exchange_rate = 0;
            $group_base_amount = 0;
            $group_nett_amount = 0;

            $qty = 0;
            $foreign_amount = 0;
            $exchange_rate = 0;
            $base_amount = 0;
            $nett_amount = 0;
        @endphp
        @if($records)
        @foreach ($records as $row)

            @php
                $row_number += 1;

                if($fields['GroupReport'] == 'VALAS')
                {
                    $group_a1 = $row->ValasSKU;
                }
                elseif($fields['GroupReport'] == 'NOTA')
                {
                    $group_a1 = $row->TransactionNo;
                }
                elseif($fields['GroupReport'] == 'PARTNER')
                {
                    $group_a1 = $row->PartnerName;
                }

                $qty += $row->Quantity;
                $foreign_amount += $row->ForeignAmount;
                $exchange_rate += $row->ExchangeRate;
                $base_amount += $row->BaseAmount;
                $nett_amount += $row->BaseAmount - $row->AverageAmount;
            @endphp 

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    <tr>
                        <td class="text-right" colspan="9"><strong>SUB TOTAL</strong></td>
                        
                        @if($fields['GroupReport'] == 'VALAS')                        
                            <td class="text-right"><strong>{{ number_format($group_qty,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($group_foreign_amount,2,'.',',') }}</strong></td>
                        @else
                            <td class="text-right"></td>
                            <td class="text-right"></td>
                        @endif

                        <td class="text-right"></td>
                        <td class="text-right"><strong>{{ number_format($group_base_amount,2,'.',',') }}</strong></td>                        
                    </tr>
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
                        <th>KETERANGAN</th>
                        <th>NO NOTA</th>
                        <th>NO SYSTEM</th>
                        <th>TANGGAL</th>                        
                        <th class="text-center">QTY</th>
                        <th class="text-center">NILAI VALAS</th>
                        <th class="text-center">RATE</th>
                        <th class="text-center">NILAI RUPIAH</th> 
                    </tr>
                </thead>
                <tbody>            

                @php
                    $group_number = 0;
                    $group_qty = 0;
                    $group_foreign_amount = 0;
                    $group_exchange_rate = 0;
                    $group_base_amount = 0;
                    $group_nett_amount = 0;

                    $group_a2 = $group_a1;
                @endphp 

            @endif

            @php 
                $group_number += 1;

                $group_qty += $row->Quantity;
                $group_foreign_amount += $row->ForeignAmount;
                $group_exchange_rate += $row->ExchangeRate;
                $group_base_amount += $row->BaseAmount;
                $group_nett_amount += $row->BaseAmount - $row->AverageAmount;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td class="text-center">{{ $row->PartnerName }}</td>
                <td>{{ $row->CurrencyName }}</td>
                <td>{{ $row->ValasSKU }}</td>
                <td>{{ $row->ValasName }}</td>
                <td>{{ $row->TransactionTypeName }}</td>
                <td>{{ $row->ReferenceNo }}</td>
                <td>
                    @if($row->IDX_M_TransactionType == 3) <!-- Purchase Order Valas -->
                        <a href="{{ url('mc-purchase-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                    @else
                        <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                    @endif 
                </td>
                <td>{{ date('d M Y',strtotime($row->TransactionDate)) }}</td>
                
                <td class="text-right">{{ number_format($row->Quantity,2,'.',',') }}</td>
                <td class="text-right">{{ $row->CurrencyID . ' ' . number_format($row->ForeignAmount,2,'.',',') }}</td>
                
                <td class="text-right">{{ number_format($row->ExchangeRate,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BaseAmount,2,'.',',') }}</td>               
            </tr>           

        @endforeach
        @endif

        <tr>
            <td class="text-right" colspan="9"><strong>SUB TOTAL</strong></td>
            
            @if($fields['GroupReport'] == 'VALAS')                        
                <td class="text-right"><strong>{{ number_format($group_qty,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_foreign_amount,2,'.',',') }}</strong></td>
            @else
                <td class="text-right"></td>
                <td class="text-right"></td>
            @endif            
            
            <td class="text-right"><strong></strong></td>
            <td class="text-right"><strong>{{ number_format($group_base_amount,2,'.',',') }}</strong></td>            
        </tr>

        <tr>
            <td class="text-right" colspan="12"><strong>TOTAL</strong></td>             
            <td class="text-right"><strong>{{ number_format($base_amount,2,'.',',') }}</strong></td>            
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection