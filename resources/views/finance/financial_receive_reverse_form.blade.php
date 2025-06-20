@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-detail" label="Reverse" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialReceiveHeader" name="IDX_T_FinancialReceiveHeader" value="{{ $fields->IDX_T_FinancialReceiveHeader }}"/>

    <x-textbox-horizontal label="Reverse By" id="ApprovalBy" :value="$fields->ApprovalBy" placeholder="" class="required readonly" />
        <x-textbox-horizontal label="Reverse Date" id="ApprovalDate" :value="$fields->ApprovalDate" placeholder="Approval Date" class="required datepicker2" />          
        <x-textbox-horizontal label="Reverse Notes" id="ApprovalRemark" :value="$fields->ApprovalRemark" placeholder="Keterangan" class="required" />

@endsection 