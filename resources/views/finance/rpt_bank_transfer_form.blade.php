@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content_form')

    <div class="row">
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Financial Account</label>
                <div class="form-group">
                    <select id="IDX_M_FinancialAccount" name="IDX_M_FinancialAccount" class="select2 form-control">            
                        @foreach($dd_financial_account as $key => $value)
                            <option value="{{ $key }}">{{ $value }}</option>                            
                        @endforeach
                    </select>
                    <input id="FinancialAccountName" name="FinancialAccountName" type="hidden" />
                </div>                                                 
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Start Date</label>
                <input class="form-control required datepicker2" id="start_date" name="start_date" type="text" placeholder="" value="{{ $start_date }}" />                                                    
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>End Date</label>
                <input class="form-control required datepicker2" id="end_date" name="end_date" type="text" placeholder="" value="{{ $end_date }}" />                                                    
            </div>
        </div>
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function(){
            $( "#IDX_M_FinancialAccount" ).on( "change", function() {
                // The text content of the selected option
                $("#FinancialAccountName").val($("#IDX_M_FinancialAccount :selected").text());
            } );
        });
    </script>
@endsection