@extends('layouts.form')

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_COAGroup1" name="IDX_M_COAGroup1" value="{{ $fields->IDX_M_COAGroup1 }}"/> 

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="COA Type" id="IDX_M_COAType" :value="$fields->IDX_M_COAType" class="required" :array="$dd_coa_type"/>
    <x-textbox-horizontal label="Group 1 - ID" id="COAGroup1ID" :value="$fields->COAGroup1ID" placeholder="ID" class="required" />
    <x-textbox-horizontal label="Group 1 - Name 1" id="COAGroup1Name1" :value="$fields->COAGroup1Name1" placeholder="" class="required" />
    <x-textbox-horizontal label="Group 1 - Name 2" id="COAGroup1Name2" :value="$fields->COAGroup1Name2" placeholder="" class="required" />    

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br><br>
    @include('form_helper.btn_save_header')

@endsection