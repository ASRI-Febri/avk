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
                    <td class="param-key">Profit & Loss Period</td>
                    <td class="param-value">: {{ DateTime::createFromFormat('Ym', $fields['Period'])->format('M Y') }}</td>
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
            $init = 0;

            $group_a1 = '';    
            $group_a2 = '';
            $group_project1 = '';    
            $group_project2 = '';

            $group_begin = 0;
            $group_debet = 0;
            $group_credit = 0;
            $group_balance = 0;

            $total_begin = 0;
            $total_debet = 0;
            $total_credit = 0;
            $total_balance = 0;

            $total_beginsingle = 0;
            $total_debetsingle = 0;
            $total_creditsingle = 0;
            $total_balancesingle = 0;
        @endphp
        @foreach ($records as $row)

            @php
                $row_number += 1;
                $group_a1 = $row->AccountType;         
                $group_project1 = $row->ProjectID;  
                
                $total_begin += $row->BBBalanceAmount;
                $total_debet += $row->BDebetAmount;
                $total_credit += $row->BCreditAmount;
                $total_balance += $row->BEBalanceAmount;

                $total_beginsingle += $row->BBBalanceAmount;
                $total_debetsingle += $row->BDebetAmount;
                $total_creditsingle += $row->BCreditAmount;
                $total_balancesingle += $row->BEBalanceAmount;
            @endphp 

            @if($group_a1 <> $group_a2)
                @if($row_number > 1)
                <tr>                      
                    <td></td>    
                    <td></td>    
                    <td></td>              
                    <td></td>
                    <td class="text-right"><span class="total">SUB TOTAL</span></td>    
                    <td class="text-right"><span class="total">{{ number_format($group_begin,2,'.',',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($group_debet,2,'.',',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($group_credit,2,'.',',') }}</span></td>   
                    <td class="text-right"><span class="total">{{ number_format($group_balance,2,'.',',') }}</span></td>    
                </tr>

                    @if($group_project1 <> $group_project2)
                         @if($row_number > 1 && $init > 1)
                        <tr>
                            <td class="text-right" colspan="5"><strong>TOTAL</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_begin,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_debet,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_credit,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_balance,2,'.',',') }}</strong></td>
                        </tr>
                        @endif
                        @if($row_number > 1 && $init == 1)
                        <tr>
                            <td class="text-right" colspan="5"><strong>TOTAL</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_beginsingle,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_debetsingle,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_creditsingle,2,'.',',') }}</strong></td>
                            <td class="text-right"><strong>{{ number_format($total_balancesingle,2,'.',',') }}</strong></td>
                        </tr>
                        @endif
                        @php
                            $init += 1;
                            $total_begin = 0;
                            $total_debet = 0;
                            $total_credit = 0;
                            $total_balance = 0;
                            $group_project2 = $group_project1;
                        @endphp 
                    @endif
                @endif                
                 
                <thead>
                    <tr class="bg-info">   
                        <th class="text-left" colspan="9">{{ strtoupper($group_a1) }}</th>
                    </tr> 
                    <tr>
                        <th>#</th>                                    
                        <th>COMPANY</th>
                        <th>PROJECT</th>
                        <th>COA</th>
                        <th>COA DESCRIPTION</th>                                               
                        <th class="text-center">BEGIN</th>
                        <th class="text-center">DEBET</th>
                        <th class="text-center">CREDIT</th>
                        <th class="text-center">ENDING</th>              
                    </tr>
                </thead>
                <tbody>            

                @php
                    $group_number = 0;
                    $group_begin = 0;
                    $group_debet = 0;
                    $group_credit = 0;
                    $group_balance = 0;
                    $group_a2 = $group_a1;
                @endphp 

            @endif

            @php 
                $group_number += 1;
                $group_begin += $row->BBBalanceAmount;
                $group_debet += $row->BDebetAmount;
                $group_credit += $row->BCreditAmount;
                $group_balance += $row->BEBalanceAmount;
                // if($group_number == 1) {
                //     $group_balance += $row->BBBalanceAmount;
                // }
                // else {
                //     $group_balance += ($row->BDebetAmount - $row->BCreditAmount); 
                // }
            @endphp

            <tr>
                <td class="text-center">{{ $group_number }}</td>
                <td>{{ $row->CompanyID }}</td>       
                <td>{{ $row->ProjectID }}</td>           
                <td class="text-center">{{ $row->COA }}</td>
                <td>{{ $row->COADesc }}</td>                
                
                <td class="text-right">{{ number_format($row->BBBalanceAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BDebetAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BCreditAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BEBalanceAmount,2,'.',',') }}</td>
            </tr>           

        @endforeach
        <tr>               
            <td></td>    
            <td></td>  
            <td></td>              
            <td></td>
            <td class="text-right"><span class="total">SUB TOTAL</span></td>    
            <td class="text-right"><span class="total">{{ number_format($group_begin,2,'.',',') }}</span></td>
            <td class="text-right"><span class="total">{{ number_format($group_debet,2,'.',',') }}</span></td>
            <td class="text-right"><span class="total">{{ number_format($group_credit,2,'.',',') }}</span></td>   
            <td class="text-right"><span class="total">{{ number_format($group_balance,2,'.',',') }}</span></td>    
        </tr>
        {{-- @if($init == 1)
            <tr>
                <td class="text-right" colspan="5"><strong>TOTAL</strong></td>
                <td class="text-right"><strong>{{ number_format($total_beginsingle,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_debetsingle,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_creditsingle,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_balancesingle,2,'.',',') }}</strong></td>
            </tr>
        @else --}}
            <tr>
                <td class="text-right" colspan="5"><strong>GRAND TOTAL</strong></td>
                <td class="text-right"><strong>{{ number_format($total_begin,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_debet,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_credit,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_balance,2,'.',',') }}</strong></td>
            </tr>
        {{-- @endif --}}
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection