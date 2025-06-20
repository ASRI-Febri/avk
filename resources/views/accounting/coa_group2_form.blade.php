@extends('layouts.form')

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_COAGroup2" name="IDX_M_COAGroup2" value="{{ $fields->IDX_M_COAGroup2 }}"/> 

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Group 1" id="IDX_M_COAGroup1" :value="$fields->IDX_M_COAGroup1" class="required" :array="$dd_coa_group1"/>
    <x-textbox-horizontal label="Group 2 - ID" id="COAGroup2ID" :value="$fields->COAGroup2ID" placeholder="ID" class="required" />
    <x-textbox-horizontal label="Group 2 - Name 1" id="COAGroup2Name1" :value="$fields->COAGroup2Name1" placeholder="" class="required" />
    <x-textbox-horizontal label="Group 2 - Name 2" id="COAGroup2Name2" :value="$fields->COAGroup2Name2" placeholder="" class="required" />    

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br><br>
    @include('form_helper.btn_save_header')

@endsection