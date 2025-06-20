@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-salesinvoice-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_SalesInvoiceDetail" name="IDX_T_SalesInvoiceDetail" value="{{ $fields->IDX_T_SalesInvoiceDetail }}"/>
    <input type="hidden" id="IDX_T_SalesInvoiceHeader" name="IDX_T_SalesInvoiceHeader" value="{{ $fields->IDX_T_SalesInvoiceHeader }}"/>
    <input type="hidden" id="IDX_M_Item" name="IDX_M_Item" value="{{ $fields->IDX_M_Item }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>
    <input type="hidden" id="IDX_M_UoM" name="IDX_M_UoM" value="{{ $fields->IDX_M_UoM }}"/>

    <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>
    <x-textbox-horizontal label="Item Description" id="ItemDesc" :value="$fields->ItemDesc" placeholder="Select Item..." class="required" />
    <x-select-horizontal label="Harga Termasuk Pajak ?" id="IncludeTax" :value="$fields->IncludeTax" class="required" :array="$dd_include_tax"/>
    <x-textbox-horizontal label="Qty" id="Quantity" :value="$fields->Quantity" placeholder="" class="required auto" />
    <x-textbox-horizontal label="Discount" id="DiscountAmount" :value="$fields->DiscountAmount" placeholder="" class="required auto" />
    <x-textbox-horizontal label="Account" id="COADesc" :value="$fields->COADesc1" placeholder="Select CoA..." class="required" />
    <x-textbox-horizontal label="Unit Price" id="UnitPrice" :value="$fields->UnitPrice" placeholder="" class="required auto" />
    <x-select-horizontal label="Tax" id="IDX_M_Tax" :value="$fields->IDX_M_Tax" class="required" :array="$dd_tax"/>
    <x-textbox-horizontal label="Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="" class="required" />

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

            $("#ItemDesc").autocomplete({                
                
                source: function( request, response ){
                    $.ajax( {
                    url: "{{ url('/pr-item/search') }}",
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
                    $("#IDX_M_Item").val(ui.item.IDX_M_Item);
                    $("#IDX_M_UoM").val(ui.item.IDX_M_UoM);

                    $("#ItemDesc").text(ui.item.ItemName);
                }
            });  

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

            $("#IDX_M_Project").select2({
                dropdownParent: $("#div-form-modal")
            });            

        });
    </script>
@endsection