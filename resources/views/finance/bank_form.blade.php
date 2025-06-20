@extends('layouts.master-form-with-log')

@section('right_header')    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('content_form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Bank" name="IDX_M_Bank" value="{{ $fields->IDX_M_Bank }}"/>    
    
    <x-textbox-horizontal label="Bank ID" id="BankCode" :value="$fields->BankCode" placeholder="Bank ID" class="required" />
    <x-textbox-horizontal label="Bank Name" id="BankName" :value="$fields->BankName" placeholder="" class="required" />
    <x-textbox-horizontal label="Bank Alias" id="BankAlias" :value="$fields->BankAlias" placeholder="" class="required" />  

    @include('form_helper.btn_save_header')

@endsection