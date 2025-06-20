@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Approve" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialPaymentHeader" name="IDX_T_FinancialPaymentHeader" value="{{ $fields->IDX_T_FinancialPaymentHeader }}"/>
    <input type="hidden" id="PDCNo" name="PDCNo" value="{{ $fields->PDCNo }}"/>

    <x-textbox-horizontal label="Handover By" id="ApprovalBy" :value="$fields->ApprovalBy" placeholder="" class="required readonly" />
    <x-textbox-horizontal label="Validate Date" id="ValidationDate" :value="$fields->ApprovalDate" placeholder="Validate Date" class="required datepicker2" />
    <x-textbox-horizontal label="No Cheque / Giro" id="VoucherNoManual" :value="$fields->PDCNo" placeholder="Received By" class="required" />          
    <x-textbox-horizontal label="Validate Notes" id="ValidateRemark" :value="$fields->ValidateRemark" placeholder="Notes" class="required" />

@endsection 