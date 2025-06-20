@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-detail" label="Void" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_SalesInvoiceHeader" name="IDX_T_SalesInvoiceHeader" value="{{ $fields->IDX_T_SalesInvoiceHeader }}"/>

    <x-textbox-horizontal label="Void By" id="ApprovalBy" :value="$fields->ApprovalBy" placeholder="" class="required readonly" />
        <x-textbox-horizontal label="Void Date" id="ApprovalDate" :value="$fields->ApprovalDate" placeholder="Approval Date" class="required datepicker2" />          
        <x-textbox-horizontal label="Void Notes" id="ApprovalRemark" :value="$fields->ApprovalRemark" placeholder="Keterangan" class="required" />

@endsection 