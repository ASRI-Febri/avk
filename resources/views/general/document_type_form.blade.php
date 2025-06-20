@extends('layouts.form')

@section('right_header')    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $fields->IDX_M_Branch }}"/>
    <input type="hidden" id="IDX_M_Parent" name="IDX_M_Parent" value="{{ $fields->IDX_M_Parent }}"/>  

    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>    
    <x-textbox-horizontal label="Branch ID" id="BranchID" :value="$fields->BranchID" placeholder="Branch ID" class="required" />
    <x-textbox-horizontal label="Branch Name" id="BranchName" :value="$fields->BranchName" placeholder="" class="required" />
    <x-textbox-horizontal label="Branch Alias" id="BranchAlias" :value="$fields->BranchAlias" placeholder="" class="required" />  
    <x-select-horizontal label="Inventory Location" id="IDX_M_LocationInventory" :value="$fields->IDX_M_LocationInventory" class="required" :array="$dd_inventory_location"/>

    <x-textbox-horizontal label="Branch Address" id="BranchAddress" :value="$fields->BranchAddress" placeholder="" class="required" />   

    @include('form_helper.btn_save_header')

@endsection