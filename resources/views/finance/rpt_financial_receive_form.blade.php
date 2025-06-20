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
                <label>Company</label>
                <div class="form-group">
                    <select id="IDX_M_Company" name="IDX_M_Company" class="select2 form-control">            
                        @foreach($dd_company as $key => $value)
                            <option value="{{ $key }}">{{ $value }}</option>                            
                        @endforeach
                    </select>
                </div>                                                 
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Branch</label>
                <div class="form-group">
                    <select id="IDX_M_Branch" name="IDX_M_Branch" class="select2 form-control">            
                        @foreach($dd_branch as $key => $value)
                            <option value="{{ $key }}">{{ $value }}</option>                            
                        @endforeach
                    </select>
                </div>                                                 
            </div>
        </div>
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