@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-form').addClass('mm-active');
@endsection

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Form" name="IDX_M_Form" value="{{ $fields->IDX_M_Form }}"/>

    <x-select-horizontal label="Application" id="IDX_M_Application" :value="$fields->IDX_M_Application" class="required" :array="$dd_asbs_application"/>
    <x-select-horizontal label="Module" id="IDX_M_Module" :value="$fields->IDX_M_Module" class="required" :array="$dd_module"/>
 
    <x-textbox-horizontal label="Form ID" id="FormID" :value="$fields->FormID" placeholder="" class="required" />
    <x-textbox-horizontal label="Form Name" id="FormName" :value="$fields->FormName" placeholder="" class="required" />
    <x-textbox-horizontal label="Form Description" id="FormDescription" :value="$fields->FormDescription" placeholder="" class="" />
    <x-textbox-horizontal label="Form URL" id="FormURL" :value="$fields->FormURL" placeholder="" class="" />
    <x-textbox-horizontal label="Icon Class 1" id="IconClass1" :value="$fields->IconClass1" placeholder="" class="" />
    <x-textbox-horizontal label="Icon Class 2" id="IconClass2" :value="$fields->IconClass2" placeholder="" class="" />
    <x-textbox-horizontal label="Icon Class 3" id="IconClass3" :value="$fields->IconClass3" placeholder="" class="" />

    <div class="row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div> 
    
@endsection 