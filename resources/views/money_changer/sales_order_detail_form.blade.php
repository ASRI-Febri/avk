@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-order-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_SalesOrderDetail" name="IDX_T_SalesOrderDetail" value="{{ $fields->IDX_T_SalesOrderDetail }}"/>
    <input type="hidden" id="IDX_T_SalesOrder" name="IDX_T_SalesOrder" value="{{ $fields->IDX_T_SalesOrder }}"/>
    <input type="hidden" id="IDX_M_Valas" name="IDX_M_Valas" value="{{ $fields->IDX_M_Valas }}"/>
    <input type="hidden" id="IDX_M_TransactionType" name="IDX_M_TransactionType" value="{{ $fields->IDX_M_TransactionType }}"/>
    <input type="hidden" id="ForeignAmount" name="ForeignAmount" value="{{ $fields->ForeignAmount }}"/>

    <div class="alert alert-label-info">
        <span class="text-muted">
            <span class="text-info">Transaksi Jual</span> : Money changer menjual valuta asing, customer membeli valuta asing.
            <br>
            <span class="text-danger">Transaksi Beli</span> : Money changer membeli valuta asing, customer menjual valuta asing.
        </span>
    </div>

    <div class="d-grid gap-3">

        <x-select-horizontal label="Valas" id="IDX_M_Valas" :value="$fields->IDX_M_Valas" class="required" :array="$dd_valas"/>

        <x-textbox-horizontal label="Qty (Lembar atau Koin)" id="Quantity" :value="$fields->Quantity" placeholder="" class="required auto" />

        {{-- <x-textbox-horizontal label="Nilai Pembelian" id="ForeignAmount" :value="$fields->ForeignAmount" placeholder="" class="required auto" /> --}}

        <x-textbox-horizontal label="Nilai Tukar" id="ExchangeRate" :value="$fields->ExchangeRate" placeholder="" class="required auto" />

        <x-textbox-horizontal label="Catatan" id="DetailNotes" :value="$fields->DetailNotes" placeholder="Keterangan tambahan" class="" />

    </div>


    {{-- <x-textbox-horizontal label="Valas" id="ItemLabel" :value="$fields->ItemLabel" placeholder="Search Item..." class="required" />   --}}

    {{-- <hr>
        <table width="100%">
            <tr>
                <td width="25%" class="text-muted">Valas SKU</td>
                <td><strong><span id="ItemSKU">{{ $fields->ValasSKU }}</span></strong></td>
            </tr>
            <tr>
                <td width="25%" class="text-muted">UoM</td>
                <td><strong><span id="UoMName">{{ $fields->ValasChangeName }}</span></strong></td>
            </tr>                           
        </table>           
    <hr> --}}

    {{-- <x-select-horizontal label="Include PPN ?" id="IncludeTax" :value="$fields->IncludeTax" class="required" :array="$dd_include_tax"/>
    <x-select-horizontal label="PPN" id="IDX_M_Tax" :value="$fields->IDX_M_Tax" class="required" :array="$dd_tax"/>

    <x-textbox-horizontal label="Quantity" id="Quantity" :value="$fields->Quantity" placeholder="" class="required auto" />
    <x-textbox-horizontal label="Unit Price" id="UnitPrice" :value="$fields->UnitPrice" placeholder="" class="required auto" />
    <x-textbox-horizontal label="Discount (Rp)" id="DiscountAmount" :value="$fields->DiscountAmount" placeholder="" class="required auto" />

    <x-textbox-horizontal label="Remark" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="Keterangan tambahan" class="" /> --}}

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