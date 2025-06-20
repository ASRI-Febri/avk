@extends('layouts.form')

@section('right_header')    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Company" name="IDX_M_Company" value="{{ $fields->IDX_M_Company }}"/>
    <input type="hidden" id="IDX_M_Parent" name="IDX_M_Parent" value="{{ $fields->IDX_M_Parent }}"/>  

    <x-textbox-horizontal label="Company ID" id="CompanyID" :value="$fields->CompanyID" placeholder="Company ID" class="required" />
    <x-textbox-horizontal label="Company Name" id="CompanyName" :value="$fields->CompanyName" placeholder="" class="required" />
    <x-textbox-horizontal label="Company Alias" id="CompanyAlias" :value="$fields->CompanyAlias" placeholder="" class="required" />
    <x-select-horizontal label="Base Currency" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>

    <x-textbox-horizontal label="NPWP" id="NPWP" :value="$fields->NPWP" placeholder="" class="required" />
    <x-textbox-horizontal label="SIUP" id="SIUP" :value="$fields->SIUP" placeholder="" class="required" />

    <fieldset>
        <legend><h6 class="text-muted font-weight-bold">Address & Contact</h6></legend>

        <x-textbox-horizontal label="Legal Address" id="LegalAddress" :value="$fields->LegalAddress" placeholder="" class="required" />
        <x-textbox-horizontal label="Kelurahan" id="Subdistrict" :value="$fields->Subdistrict" placeholder="" class="" />
        <x-textbox-horizontal label="Kecamatan" id="District" :value="$fields->District" placeholder="" class="" />
        <x-textbox-horizontal label="Kota" id="City" :value="$fields->City" placeholder="" class="" />
        <x-textbox-horizontal label="Province" id="Province" :value="$fields->Province" placeholder="" class="" />
        <x-textbox-horizontal label="Kode Pos" id="Zip" :value="$fields->Zip" placeholder="" class="" />

        <x-textbox-horizontal label="Email" id="Email" :value="$fields->Email" placeholder="" class="" />
        <x-textbox-horizontal label="Phone" id="Phone" :value="$fields->CompanyAlias" placeholder="" class="" />
    </fieldset>

    <x-textbox-horizontal label="Website" id="Website" :value="$fields->Website" placeholder="" class="" />
    <x-textbox-horizontal label="Remarks" id="Remarks" :value="$fields->Remarks" placeholder="" class="" />

    @include('form_helper.btn_save_header')

@endsection