@extends('layouts.form')

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_COAGroup3" name="IDX_M_COAGroup3" value="{{ $fields->IDX_M_COAGroup3 }}"/> 

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Group 2" id="IDX_M_COAGroup2" :value="$fields->IDX_M_COAGroup2" class="required" :array="$dd_coa_group2"/>
    <x-textbox-horizontal label="Group 3 - ID" id="COAGroup3ID" :value="$fields->COAGroup3ID" placeholder="ID" class="required" />
    <x-textbox-horizontal label="Group 3 - Name 1" id="COAGroup3Name1" :value="$fields->COAGroup3Name1" placeholder="" class="required" />
    <x-textbox-horizontal label="Group 3 - Name 2" id="COAGroup3Name2" :value="$fields->COAGroup3Name2" placeholder="" class="required" />    

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br><br>
    @include('form_helper.btn_save_header')

@endsection