@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Approve" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PurchaseOrder" name="IDX_T_PurchaseOrder" value="{{ $fields->IDX_T_PurchaseOrder }}"/>

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="Approval Date" id="ApprovalDate" :value="$fields->ApprovalDate" placeholder="Approval Date" class="required datepicker2" />          
        <x-textbox-horizontal label="Approval Notes" id="ApprovalRemark" :value="$fields->ApprovalRemark" placeholder="Keterangan" class="required" />
    </div>

@endsection 