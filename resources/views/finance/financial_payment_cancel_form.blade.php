@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Void" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialPaymentHeader" name="IDX_T_FinancialPaymentHeader" value="{{ $fields->IDX_T_FinancialPaymentHeader }}"/>

    <x-textbox-horizontal label="Void By" id="VoidBy" :value="$fields->VoidBy" placeholder="" class="required readonly" />
    <x-textbox-horizontal label="Void Date" id="VoidDate" :value="$fields->VoidDate" placeholder="Void Date" class="required datepicker2" />        
    <x-textbox-horizontal label="Void Reason" id="VoidReason" :value="$fields->VoidReason" placeholder="Notes" class="required" />

@endsection 