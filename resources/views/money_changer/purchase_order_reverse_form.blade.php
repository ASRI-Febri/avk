@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Reverse to Draft" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PurchaseOrder" name="IDX_T_PurchaseOrder" value="{{ $fields->IDX_T_PurchaseOrder }}"/>

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="Reverse Date" id="ApprovalDate" :value="$fields->ApprovalDate" placeholder="Approval Date" class="required datepicker2" />          
        <x-textbox-horizontal label="Reverse Reason" id="ApprovalRemark" :value="$fields->ApprovalRemark" placeholder="Alasan" class="required" />
    </div>

@endsection 