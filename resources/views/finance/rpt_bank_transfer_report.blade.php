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
                    <td class="param-key">Financial Account</td>
                    <td class="param-value">: {{ $fields['FinancialAccountName'] }}</td>
                </tr> 
                <tr>
                    <td class="param-key">Report Date</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr>  
            </table>
        </div>
        {{-- <div style="float:left;width:30%; text-align: right;">
            <button id="export_xls" name="export_xls" type="button" class="btn btn-xs btn-success btn-icon heading-btn"><i class="icon-file-excel"></i> Export Excel</button>
        </div> --}}
        
    </div>
    <br/>        
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <?php
        if (!$records)
        {
            echo "<div class=\"text-danger text-bold\">Data Not Found!</div>";
        }
    ?>

    <table id="table-report" class="minimalistBlack">
        @php
            // $row_number = 0; 
            // $group_number = 0;

            // $group_dailytransdatenow = '';    
            // $group_dailytransdateprev = ''; 

            // $group_debet = 0;
            // $group_credit = 0;
            // $group_balance = 0;
            
            // $daily_debet = 0;
            // $daily_credit = 0;
            $row_number = 0; 
            $group_number = 0;

            $group_a1 = '';    
            $group_a2 = '';

            $group_debet = 0;
            $group_credit = 0;
            $group_balance = 0;
            
            $total_debet = 0;
            $total_credit = 0;
            $total_balance = 0;
        @endphp

        @foreach ($records as $row)

        @php
            $row_number += 1;
            $group_a1 = $row->TransDate;           
                            
            $total_debet += $row->Debet;
            $total_credit += $row->Credit;
            $total_balance += $row->Debet-$row->Credit;
        @endphp 

        @if($group_a1 <> $group_a2)

            @if($row_number > 1)
                <tr>
                    <td></td>
                    <td></td>    
                    <td></td>    
                    <td></td>              
                    <td></td>
                    <td class="text-right"><span class="total">SUB TOTAL</span></td>    
                    <td class="text-right"><span class="total">{{ number_format($group_debet,2,'.',',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($group_credit,2,'.',',') }}</span></td>   
                    <td class="text-right"><span class="total">{{ number_format($group_balance,2,'.',',') }}</span></td>    
                </tr>
            @endif               
            
            <thead>
                <tr>
                    <th>TYPE</th>
                    <th>TRANS DATE</th>                                               
                    <th>VALIDATE DATE</th>
                    <th>VOUCHER NO</th>
                    <th>TRANS STATUS</th>                        
                    <th>REMARKS</th>       
                    <th class="text-center">DEBET</th>
                    <th class="text-center">CREDIT</th>
                    <th class="text-center">BALANCE</th>                
                </tr>
            </thead>
            <tbody>            

            @php
                $group_number = 0;
                $group_debet = 0;
                $group_credit = 0;
                // $group_balance = 0;
                $group_a2 = $group_a1;
            @endphp 

        @endif

        @php 
            $group_number += 1;

            $group_debet += $row->Debet;
            $group_credit += $row->Credit;

            if($group_number == 1) {
                $group_balance += $row->Balance;
            }
            else {
                $group_balance += ($row->Debet - $row->Credit); 
            }
        @endphp

        <tr>
            <td class="text-center">{{ $row->TransType }}</td>

            @if(date('Y',strtotime($row->TransDate)) == '1900' || date('Y',strtotime($row->TransDate)) == '1970')
                <td></td>
            @else 
                <td>{{ date('d M Y',strtotime($row->TransDate)) }}</td>
            @endif

            @if(date('Y',strtotime($row->PostedDate)) == '1900' || date('Y',strtotime($row->PostedDate)) == '1970')
                <td></td>
            @else 
                <td>{{ date('d M Y',strtotime($row->PostedDate)) }}</td>
            @endif

            {{-- <td>{{ $row->VoucherNo }}</td> --}}
            <td><a href="{{ $row->URLTransaction }}" target="_blank">{{ $row->VoucherNo }}</a></td>

            <td>{{ $row->TransStatus }}</td>
            <td>{{ $row->Remarks }}</td>
            <td class="text-right">{{ number_format($row->Debet,2,'.',',') }}</td>
            <td class="text-right">{{ number_format($row->Credit,2,'.',',') }}</td>

            @if($row_number == 1)
                <td class="text-right">{{ number_format($row->Balance,2,'.',',') }}</td>
            @else 
                <td class="text-right">{{ number_format($group_balance,2,'.',',') }}</td>
            @endif
        </tr>           

        @endforeach

        <tr>            
        <td></td>
        <td></td>    
        <td></td>    
        <td></td>              
        <td></td>
        <td class="text-right"><span class="total">SUB TOTAL</span></td>    
        <td class="text-right"><span class="total">{{ number_format($group_debet,2,'.',',') }}</span></td>
        <td class="text-right"><span class="total">{{ number_format($group_credit,2,'.',',') }}</span></td>   
        <td class="text-right"><span class="total">{{ number_format($group_balance,2,'.',',') }}</span></td>    
        </tr>
        <tr>
        <td class="text-right" colspan="6"><strong>TOTAL</strong></td>            
        <td class="text-right"><strong>{{ number_format($total_debet,2,'.',',') }}</strong></td>
        <td class="text-right"><strong>{{ number_format($total_credit,2,'.',',') }}</strong></td>
        <td class="text-right"><strong>{{ number_format($group_balance,2,'.',',') }}</strong></td>
        </tr>
        
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection