@extends('layouts.form')

@section('right_header')    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Department" name="IDX_M_Department" value="{{ $fields->IDX_M_Department }}"/>    
     
    <x-textbox-horizontal label="Department ID" id="DepartmentID" :value="$fields->DepartmentID" placeholder="Department ID" class="required" />
    <x-textbox-horizontal label="Department Name" id="DepartmentName" :value="$fields->DepartmentName" placeholder="" class="required" />   

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br><br>
    
    @include('form_helper.btn_save_header')

@endsection