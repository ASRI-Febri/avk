@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-order-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_OpenCloseDailyDetail" name="IDX_T_OpenCloseDailyDetail" value="{{ $fields->IDX_T_OpenCloseDailyDetail }}"/>
    <input type="hidden" id="IDX_T_OpenCloseDaily" name="IDX_T_OpenCloseDaily" value="{{ $fields->IDX_T_OpenCloseDaily }}"/>
     
    <input type="hidden" id="InQty" name="InQty" value="{{ $fields->InQty }}"/>
    <input type="hidden" id="OutQty" name="OutQty" value="{{ $fields->OutQty }}"/> 
    <input type="hidden" id="DiffQty" name="DiffQty" value="{{ $fields->DiffQty }}"/> 

    <div class="alert alert-label-info">
        <span class="text-muted">
            Edit jumlah valas sesuai dengan yang ada di brankas
        </span>
    </div>

    <div class="d-grid gap-3">

        @if($state == 'create')
            <x-select-horizontal label="Valas" id="IDX_M_Valas" :value="$fields->IDX_M_Valas" class="required" :array="$dd_valas"/>
        @else 
            <input type="hidden" id="IDX_M_Valas" name="IDX_M_Valas" value="{{ $fields->IDX_M_Valas }}"/> 

            <div class="alert alert-label-info">
                <span class="text-info">
                    {{ $fields->CurrencyName }}
                    <br>
                    {{ $fields->ValasSKU . ' - ' . $fields->ValasName }}
                </span>
            </div>
        @endif 
                
        <x-textbox-horizontal label="Opening Qty (Lembar atau Koin)" id="OpenQty" :value="$fields->OpenQty" placeholder="" class="required auto" />
        <x-textbox-horizontal label="Closing Qty (Lembar atau Koin)" id="CloseQty" :value="$fields->CloseQty" placeholder="" class="required auto" />
        <x-textbox-horizontal label="Catatan" id="DetailNotes" :value="$fields->DetailNotes" placeholder="Keterangan" class="" />

    </div>   

@endsection

@section('script')
    <script>
        $(document).ready(function(){  

            // $("#ItemLabel").autocomplete({                
                
            //     source: function( request, response ){
            //         $.ajax( {
            //         url: "{{ url('/pr-item/search') }}",
            //         dataType: "json",
            //         type: "POST",
            //         data: {
            //             q: request.term,
            //             _token: $('#_token').val()
            //         },
            //         success: function(data){					
            //             response( data );
            //         }
            //         });
            //     },			
            //     minLength: 3,
            //     select: function( event, ui )
            //     {   
            //         $("#IDX_M_Valas").val(ui.item.IDX_M_Valas);
            //         // $("#IDX_M_Valas_type").val(ui.item.IDX_M_Valas_type);
            //         // $("#IDX_M_Valas_category").val(ui.item.IDX_M_Valas_category);
                    
            //         // $("#idx_m_coa").val(ui.item.coa_inventory);
            //         // $("#coa_name").val(ui.item.coa_inventory_name);
            //         // $("#coa_name").text(ui.item.coa_inventory_name);

            //         $("#ItemSKU").text(ui.item.ItemSKU); 
            //         $("#UoMID").text(ui.item.UoMID);
            //         $("#UoMName").text(ui.item.UoMName);

            //         // $("#is_include_tax").val(ui.item.is_include_vat);
            //         // $("#item_description").val(ui.item.item_description);
            //         $("#LastPurchasePrice").text(ui.item.LastPurchasePrice);
                    

            //         //$("#idx_m_uom").prop("selectedIndex", ui.item.idx_m_uom);	
            //         //$('#idx_m_uom').select2().trigger('change');
            //     }
            // });
        });
    </script>
@endsection