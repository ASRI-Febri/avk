@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Update" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_SalesInvoiceHeader" name="IDX_T_SalesInvoiceHeader" value="{{ $fields->IDX_T_SalesInvoiceHeader }}"/>
       
    <x-textbox-horizontal label="Audit Notes" id="AuditNotes" :value="$fields->AuditNotes" placeholder="AuditNotes" class="required" />

@endsection 