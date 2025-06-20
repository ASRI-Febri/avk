@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-financialreceive-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialReceiveDetail" name="IDX_T_FinancialReceiveDetail" value="{{ $fields->IDX_T_FinancialReceiveDetail }}"/>
    <input type="hidden" id="IDX_T_FinancialReceiveHeader" name="IDX_T_FinancialReceiveHeader" value="{{ $fields->IDX_T_FinancialReceiveHeader }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>

    <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>
    <x-textbox-horizontal label="Account" id="COADesc" :value="$fields->COADesc1" placeholder="Select CoA..." class="required" />
    <x-textbox-horizontal label="Receive Amount" id="ReceiveAmount" :value="$fields->ReceiveAmount" placeholder="Receive Amount" class="required auto" />
    <x-textbox-horizontal label="Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="Notes" class="required" />

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