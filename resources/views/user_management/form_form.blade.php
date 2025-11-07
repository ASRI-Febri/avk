@extends('layouts.master-form-with-log')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    @include('form_helper.btn_back_to_list')
@endsection

@section('right_header')    
    @include('form_helper.btn_save_header')
@endsection

@section('content_form')

    <form id="form-entry" name="form-entry" autocomplete="off" enctype="multipart/form-data" action="{{ $url_save_header ?? '#' }}" role="form" method="post">        

        <!-- HIDDEN FIELDS -->
        <input type="hidden" id="IDX_M_Form" name="IDX_M_Form" value="{{ $fields->IDX_M_Form }}"/>

        <div class="form-row">
            <div class="col-6 mb-3"> 
                <label for="IDX_M_Application">Application</label>                                               
                <select id="IDX_M_Application" name="IDX_M_Application" class="select2 form-control">
                    <option label="Choose on thing">Select</option>
                    @foreach($dd_asbs_application as $key => $value)
                        <option value="{{ $key }}" {{ $fields->IDX_M_Application == $key ? 'selected=' : '' }}>{{ $value }}</option>                            
                    @endforeach
                </select>
            </div>
            <div class="col-6 mb-3"> 
                <label for="email">Module</label>                                               
                <select id="IDX_M_Module" name="IDX_M_Module" class="select2 form-control">
                    <option label="Choose on thing">Select</option>
                    <option>Master</option>
                    <option>Transaction</option>
                    <option>Report</option>                    
                </select>
            </div>
            <div class="col-6 mb-3">
                <label for="username">Form ID</label>
                <input type="text" id="FormID" name="FormID" class="form-control" placeholder="Form ID" value="{{ $fields->FormID }}">
            </div>
            <div class="col-6 mb-3"> 
                <label for="email">Form Name</label>                                               
                <input type="text" class="form-control" placeholder="" value="{{ $fields->FormName }}">
            </div>
            <div class="col-6 mb-3"> 
                <label for="email">Form URL</label>                                               
                <input type="text" class="form-control" placeholder="URL" value="{{ $fields->FormURL }}">
            </div>
            <div class="col-6 mb-3"> 
                <label for="email">Icon Class 1</label>                                               
                <input type="text" id="IconClass1" name="IconClass1" class="form-control" placeholder="URL" value="{{ $fields->IconClass1 }}">
            </div>
            <div class="col-6 mb-3"> 
                <label for="email">Icon Class 2</label>                                               
                <input type="text" id="IconClass2" name="IconClass2" class="form-control" placeholder="URL" value="{{ $fields->IconClass2 }}">
            </div>
            <div class="col-6 mb-3"> 
                <label for="email">Icon Class 3</label>                                               
                <input type="text" id="IconClass3" name="IconClass3" class="form-control" placeholder="URL" value="{{ $fields->IconClass3 }}">
            </div>
            
        </div>
    </form>
    
@endsection 