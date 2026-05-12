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

            $group_sales_amount = 0;
            $group_cash_amount = 0;
            $group_transfer_amount = 0;
            $group_outstanding_amount = 0;

            $qty = 0;
            $sales_amount = 0;
            $cash_amount = 0;
            $transfer_amount = 0;
            $outstanding_amount = 0;
        @endphp
        @if($records)
        @foreach ($records as $row)

            @php
                $row_number += 1;
                $group_a1 = $row->TransactionNo;

                if($fields['GroupReport'] == 'NOTA')
                {
                    $group_a1 = $row->BranchName;
                }
                elseif($fields['GroupReport'] == 'PARTNER')
                {
                    $group_a1 = $row->PartnerName;
                }

                $sales_amount += $row->TotalSalesAmount;
                $cash_amount += $row->PaymentCashAmount;
                $transfer_amount += $row->PaymentTransferAmount;
                $outstanding_amount += $row->OutstandingAmount;
            @endphp 

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    <tr>
                        <td class="text-right" colspan="6"><strong>SUB TOTAL</strong></td>
                        <td class="text-right"><strong></strong></td>
                        <td class="text-right"><strong>{{ number_format($group_sales_amount,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_cash_amount,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_transfer_amount,2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_outstanding_amount,2,'.',',') }}</strong></td>
                    </tr>
                @endif              
                 
                <thead>
                    <tr class="bg-info">   
                        <th class="text-start" colspan="10">{{ strtoupper($group_a1) }}</th>
                    </tr> 
                    <tr>
                        <th>#</th>      
                        <th>TANGGAL</th>    
                        <th>NO SYSTEM</th>  
                        <th>NO NOTA</th>
                        <th>KONSUMEN</th>
                        <th>KETERANGAN</th>
                        <th class="text-center">TOTAL PENJUALAN</th>
                        <th class="text-center">BAYAR CASH</th>
                        <th class="text-center">BAYAR TRANSFER</th>    
                        <th class="text-center">SELISIH</th>         
                    </tr>
                </thead>
                <tbody>            

                @php
                    $group_number = 0;
                    $group_sales_amount = 0;
                    $group_cash_amount = 0;
                    $group_transfer_amount = 0;
                    $group_nett_amount = 0;

                    $group_a2 = $group_a1;
                @endphp 

            @endif

            @php 
                $group_number += 1;

                $group_sales_amount += $row->TotalSalesAmount;
                $group_cash_amount += $row->PaymentCashAmount;
                $group_transfer_amount += $row->PaymentTransferAmount;
                $group_outstanding_amount += $row->OutstandingAmount;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td>{{ date('d M Y',strtotime($row->TransactionDate)) }}</td>
                <td>
                    <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_T_SalesOrder }}" target="_blank">{{ $row->TransactionNo }}</a>
                </td>
                <td>{{ $row->ReferenceNo }}</td>
                <td class="text-center">{{ $row->PartnerName }}</td>
                <td>{{ $row->RemarkHeader }}</td>
                <td class="text-right">{{ number_format($row->TotalSalesAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->PaymentCashAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->PaymentTransferAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->OutstandingAmount,2,'.',',') }}</td>
            </tr>           

        @endforeach
        @endif

        <tr>
            <td class="text-right" colspan="6"><strong>SUB TOTAL</strong></td>
            <td class="text-right"><strong>{{ number_format($group_sales_amount,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_cash_amount,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_transfer_amount,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($group_outstanding_amount,2,'.',',') }}</strong></td>
        </tr>

        <tr>
            <td class="text-right" colspan="6"><strong>TOTAL</strong></td> 
            <td class="text-right"><strong>{{ number_format($sales_amount,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($cash_amount,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($transfer_amount,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($outstanding_amount,2,'.',',') }}</strong></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection