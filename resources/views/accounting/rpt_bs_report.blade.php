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
                    <td class="param-key">PROFIT CENTER</td>
                    <td class="param-value">: {{ strtoupper($fields['BranchDesc']) }}</td>
                </tr>         
                <tr>
                    <td class="param-key">AS OF</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr>  
            </table>
        </div>       
        
    </div>
    <br/> 
    <hr>
    <br/>        
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    @php
        $total_asset = 0;
        $total_liabilities = 0;
        $total_equity = 0;
    @endphp
    <table id="table-report" class="minimalistBlack">
        <thead>
            <tr>                               
                <th>ASSET</th>
                <th>LIABILITIES & EQUITY</th> 
            </tr>
        </thead>
        <tbody> 
            <tr>
                <td>
                    <!-- ASSET -->
                    <table style="border:0;width:100%;">
                    @foreach ($records as $row)
                        @if($row->AccountType == 'AS')
                            @php
                                $total_asset += $row->Amount;
                            @endphp
                            <tr>
                                <td class="width-300" style="border:0">{{ $row->COAGroup1Name1 }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($row->Amount,2,'.',',') }}</td>
                            </tr>
                        @endif
                    @endforeach
                    <tr>
                        <td class="text-right"><strong>TOTAL ASSET</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_asset,2,'.',',') }}</strong></td>
                    </tr>
                    </table>
                </td>
                <td>
                    <!-- LIBILITY -->
                    <table style="border:0; width:100%;">
                    @foreach ($records as $row)
                        @if($row->AccountType == 'LI')
                            @php
                                $total_liabilities += $row->Amount;
                            @endphp
                            <tr>
                                <td class="width-300" style="border:0">{{ $row->COAGroup1Name1 }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($row->Amount,2,'.',',') }}</td>
                            </tr>
                        @endif
                    @endforeach
                    <tr>
                        <td class="text-right"><strong>TOTAL LIABILITIES</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities,2,'.',',') }}</strong></td>
                    </tr>
                    </table>

                    <!-- EQUITY -->
                    <table style="border:0;width:100%;">
                    @foreach ($records as $row)
                        @if($row->AccountType == 'EQ')
                            @php
                                $total_equity += $row->Amount;
                            @endphp
                            <tr>
                                <td class="width-300" style="border:0">{{ $row->COAGroup1Name1 }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($row->Amount,2,'.',',') }}</td>
                            </tr>
                        @endif
                    @endforeach
                    <tr>
                        <td class="text-right"><strong>TOTAL EQUITY</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_equity,2,'.',',') }}</strong></td>
                    </tr>
                    <tr>
                        <td class="text-right"><strong>TOTAL LIABILITIES & EQUITY</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities + $total_equity,2,'.',',') }}</strong></td>
                    </tr>
                    </table>
                </td>
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