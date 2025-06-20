@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content') 

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Company" name="IDX_M_Company" value="{{ $fields['IDX_M_Company'] }}"/>  
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $fields['IDX_M_Branch'] }}"/>  

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
                    <td class="param-key">TB PERIOD</td>
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
            
            $row_number = 0;

            $group_number = 0;
            $group_a1 = '';    
            $group_a2 = '';

            $total_begin = 0;
            $total_debet = 0;
            $total_credit = 0;
            $total_ending = 0;
        @endphp
        @foreach ($records as $row)

            @php
                $row_number += 1;
                $group_a1 = $row->CompanyID;           
                
                $total_begin += $row->BBBalanceAmount;
                $total_debet += $row->BDebetAmount;
                $total_credit += $row->BCreditAmount;
                $total_ending += $row->BEBalanceAmount;
            @endphp 

            @if($group_a1 <> $group_a2)
                {{-- @if($row_number > 1)
                    @include('accounting.report.rpt_journal_report_sub_total')
                @endif --}}                
                 
                <thead>
                    <tr class="bg-info">   
                        <th class="text-left" colspan="7">{{ strtoupper($group_a1) }}</th>
                    </tr> 
                    <tr>
                        <th>#</th>                                    
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
                    $group_a2 = $group_a1;
                @endphp 

            @endif

            @php 
                $group_number += 1;
            @endphp

            <tr>
                <td>{{ $group_number }}</td>
                {{-- <td class="text-center">{{ $row->COA }}</td> --}}
                
                <td class="text-center">
                    <a href="#" onclick="getDetail('{{ $fields['IDX_M_Company'] }}','{{ $fields['IDX_M_Branch'] }}','{{ $fields['start_date'] }}',
                        '{{ $fields['end_date'] }}','{{ $row->IDX_M_COA }}')">
                        {{ $row->COA }}
                    </a>
                </td>
                
                <td>{{ $row->COADesc }}</td>                
                
                <td class="text-right">{{ number_format($row->BBBalanceAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BDebetAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BCreditAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BEBalanceAmount,2,'.',',') }}</td>
            </tr>           

        @endforeach
        <tr>
            <td class="text-right" colspan="3"><strong>TOTAL</strong></td>
            <td class="text-right"><strong>{{ number_format($total_begin,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total_debet,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total_credit,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total_ending,2,'.',',') }}</strong></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->   

@endsection

<script src="{{ URL::asset('public/js/router.js') }}"></script>

<script>    

    function getScrollPosition()
    {
        var scroll = $(window).scrollTop();
        $("#scroll-position").val(scroll);
    }

    function getDetail(IDX_M_Company, IDX_M_Branch, start_date, end_date, IDX_M_COA)
    {
        // alert('get detail ' + IDX_M_Company + ' '  + IDX_M_Branch + ' ' + start_date + ' ' + end_date + ' ' + IDX_M_COA);
        
        // Redirect
        // window.open('{{ url('ac-rpt-analytic-project') }}');

        url = "{{ url('ac-rpt-tb/get-detail') }}";

        var data = {
            "_token": "{{ csrf_token() }}",            
            "IDX_M_Company": IDX_M_Company,
            "IDX_M_Branch": IDX_M_Branch,
            "start_date": start_date,
            "end_date": end_date,     
            "IDX_M_COA": IDX_M_COA,   
            "CompanyDesc": "{{ strtoupper($fields['CompanyDesc']) }}",   
            "BranchDesc": "{{ strtoupper($fields['BranchDesc']) }}",                  
        }
        
        $.ajax({
            url: url,
            type: 'post',
            data: data,
            success: function(response){ 

                //window.open(html(response), '_blank');

                //$('body').css('overflow', 'hidden');

                //var scroll = $(window).scrollTop();
                //alert(scroll);			

                // Add response in Modal body
                var w = window.open();
                $(w.document.body).html(response);
               
            }
        });

    }
</script>