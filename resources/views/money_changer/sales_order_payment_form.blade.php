@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-order-payment"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialReceiveHeader" name="IDX_T_FinancialReceiveHeader" value="{{ $fields->IDX_T_FinancialReceiveHeader }}"/>
    <input type="hidden" id="IDX_T_SalesOrder" name="IDX_T_SalesOrder" value="{{ $fields->IDX_T_SalesOrder }}"/>
    <input type="hidden" id="IDX_M_DocumentType" name="IDX_M_DocumentType" value="{{ $fields->IDX_M_DocumentType }}"/>

    <div class="d-grid gap-3">
        <div class="row">
            <div class="col-sm-6"> 
                <div class="row">
                    <div class="col-sm-4"><span>No Nota</span></div>
                    <div class="col-sm-8"><strong>{{ $header->ReferenceNo }}</strong></div>   
                </div>         
            </div>
            <div class="col-sm-6"> 
                <div class="row">
                    <div class="col-sm-4"><span>No System</span></div>
                    <div class="col-sm-8"><strong>{{ $header->SONumber }}</strong></div> 
                </div>           
            </div>        
        </div>
    </div>

    <hr>

    <div class="d-grid gap-3">

        <x-textbox-horizontal label="Tanggal Pembayaran" id="ReceiveDate" :value="$fields->ReceiveDate" placeholder="" class="required datepicker2" />

        <x-select-horizontal label="Kas / Bank" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>

        <x-textbox-horizontal label="Jumlah Pembayaran" id="ReceiveAmount" :value="$fields->ReceiveAmount" placeholder="" class="required auto" />

        <x-textbox-horizontal label="Catatan" id="PaymentNotes" :value="$fields->PaymentNotes" placeholder="Keterangan pembayaran" class="" />

    </div>



@endsection