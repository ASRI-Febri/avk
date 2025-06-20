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
                    <td class="param-key">COMPANY</td>
                    <td class="param-value">: {{ strtoupper($fields['CompanyDesc']) }}</td>
                </tr> 
                <tr>
                    <td class="param-key">BRANCH</td>
                    <td class="param-value">: {{ strtoupper($fields['BranchDesc']) }}</td>
                </tr> 
                <tr>
                    <td class="param-key">Ledger Period</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
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
                $group_a1 = $row->COA . ' - ' . $row->COADesc;           
                                
                $total_debet += $row->BDebetAmount;
                $total_credit += $row->BCreditAmount;
                $total_balance += $row->BBalanceAmount;
            @endphp 

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    <tr>
                        <td></td>
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
                    <tr class="bg-info">   
                        <th class="text-left" colspan="10">{{ strtoupper($group_a1) }}</th>
                    </tr> 
                    <tr>
                        <th>#</th>                                    
                        <th>COA</th>
                        <th>COA DESCRIPTION</th> 
                        <th>PROJECT</th>                      
                        <th>VOUCHER</th>
                        <th>JOURNAL DATE</th>
                        <th>JOURNAL DESCRIPTION</th>                        
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
                    $group_balance = 0;
                    $group_a2 = $group_a1;
                @endphp 

            @endif

            @php 
                $group_number += 1;

                $group_debet += $row->BDebetAmount;
                $group_credit += $row->BCreditAmount;

                if($group_number == 1) {
                    $group_balance += $row->BBalanceAmount;
                }
                else {
                    $group_balance += ($row->BDebetAmount - $row->BCreditAmount); 
                }
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td class="text-center">{{ $row->COA }}</td>
                <td>{{ $row->COADesc }}</td>     
                <td>{{ $row->ProjectDesc }}</td>                     
                
                {{-- <td>{{ $row->ReferenceNo }}</td> --}}
                <td><a href="{{ $row->URLTransaction }}" target="_blank">{{ $row->ReferenceNo }}</a></td>

                @if((date('Y',strtotime($row->JournalDate)) == '1900') || (date('Y',strtotime($row->JournalDate)) == '1970'))
                <td></td>
                @else 
                <td>{{ date('d M Y',strtotime($row->JournalDate)) }}</td>
                @endif
                
                <td>{{ $row->JournalDesc }}</td>
                <td class="text-right">{{ number_format($row->BDebetAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BCreditAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($group_balance,2,'.',',') }}</td>
                {{-- <td class="text-right">{{ number_format($row->BBalanceAmount,2,'.',',') }}</td> --}}
            </tr>           

        @endforeach
        <tr>            
            <td></td>
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
            <td class="text-right" colspan="7"><strong>TOTAL</strong></td>            
            <td class="text-right"><strong>{{ number_format($total_debet,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total_credit,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total_balance,2,'.',',') }}</strong></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection