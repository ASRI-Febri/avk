@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-salesinvoice-payment"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_SalesInvoiceHeader" name="IDX_T_SalesInvoiceHeader" value="{{ $fields->IDX_T_SalesInvoiceHeader }}"/>

    <x-select-horizontal label="Receive Detail COA" id="IDX_M_COA" :value="$fields->IDX_M_COA" class="required" :array="$dd_coa_transactionsi"/>
    <x-select-horizontal label="Payment Method" id="IDX_M_PaymentType" :value="$fields->IDX_M_PaymentType" class="required" :array="$dd_payment_method"/>
    <x-select-horizontal label="Financial Account" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>
    <x-textbox-horizontal label="Receive Amount" id="ReceiveAmount" :value="$fields->ReceiveAmount" placeholder="Receive Amount" class="required auto" />
    <x-textbox-horizontal label="Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="Keterangan" class="required" />

@endsection

@section('script')
    <script>
        $(document).ready(function(){
            $('.select2').select2({		
                theme: 'bootstrap4',
                width: "100%",            
                placeholder: $(this).attr('placeholder'),
                dropdownParent: $('#div-form-modal')	
            });	
            
        });
    </script>
@endsection