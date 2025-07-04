@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-purchaseinvoice-tax"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PurchaseInvoiceDetail" name="IDX_T_PurchaseInvoiceDetail" value="{{ $fields->IDX_T_PurchaseInvoiceDetail }}"/>
    <input type="hidden" id="IDX_T_PurchaseInvoiceHeader" name="IDX_T_PurchaseInvoiceHeader" value="{{ $fields->IDX_T_PurchaseInvoiceHeader }}"/>
    <input type="hidden" id="IDX_T_PurchaseInvoiceTax" name="IDX_T_PurchaseInvoiceTax" value="{{ $fields->IDX_T_PurchaseInvoiceTax }}"/>
    <input type="hidden" id="IDX_M_Tax" name="IDX_M_Tax" value="{{ $fields->IDX_M_Tax }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>

    {{-- <x-select-horizontal label="Detail Item" id="ItemDetail" :value="$fields->IDX_M_Item" class="required" :array="$dd_item_tax"/> --}}
    <x-select-horizontal label="Detail Item" id="IDX_T_PurchaseInvoiceDetail" :value="$fields->IDX_T_PurchaseInvoiceDetail" class="required" :array="$dd_item_tax"/>
    <x-select-horizontal label="Tax" id="IDX_M_Tax" :value="$fields->IDX_M_Tax" class="required" :array="$dd_tax"/>
    <x-textbox-horizontal label="Chart of Account" id="COADesc" :value="$fields->COADesc1" placeholder="Select CoA..." class="" />

@endsection

@section('script')
    <script>
        $(document).ready(function(){
            $("#COADesc").autocomplete({                
                
                source: function( request, response ){
                    $.ajax( {
                    url: "{{ url('/fm-account/search') }}",
                    dataType: "json",
                    type: "POST",
                    data: {
                        q: request.term,
                        _token: $('#_token').val()
                    },
                    success: function(data){					
                        response( data );
                    }
                    });
                },			
                minLength: 3,
                select: function( event, ui )
                {   
                    $("#IDX_M_COA").val(ui.item.IDX_M_COA);

                    $("#COADesc").text(ui.item.COADesc);
                }
            });
        });
    </script>
@endsection