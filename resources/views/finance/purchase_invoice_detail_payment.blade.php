@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-purchaseinvoice-payment"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PurchaseInvoiceHeader" name="IDX_T_PurchaseInvoiceHeader" value="{{ $fields->IDX_T_PurchaseInvoiceHeader }}"/>

    <x-select-horizontal label="Payment Method" id="IDX_M_PaymentType" :value="$fields->IDX_M_PaymentType" class="required" :array="$dd_payment_method"/>
    <x-select-horizontal label="Financial Account" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>
    {{-- <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Outstanding Amount</label>
        <div class="col-sm-9">
            <input type="text" id="OutstandingAmount" name="OutstandingAmount" 
                class="form-control auto" placeholder="(Auto)">
        </div>
    </div> --}}
    <x-textbox-horizontal label="Payment Amount" id="PaymentAmount" :value="$fields->PaymentAmount" placeholder="Payment Amount" class="required auto" />
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
            // // Partner id
            // var id = $('#IDX_T_PurchaseInvoiceHeader').val();

            // // AJAX request 
            // $.ajax({
            // url: 'getInvoiceInfo/'+id,
            // type: 'get',
            // dataType: 'json',
            // success: function(response){

            //     var len = 0;
            //     if(response['data'] != null){
            //         len = response['data'].length;
            //     }

            //     if(len > 0){
            //     // Read data and create <option >
            //         for(var i=0; i<len; i++){

            //             //document date, due date, outstanding amount
            //             var outstandingAmount = response['data'][i].OutstandingAmount;
 
            //             $("#OutstandingAmount").val(outstandingAmount); 
            //         }
            //     }

            //     }
            // });
        });
    </script>
@endsection