@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-financialpayment-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialPaymentDetail" name="IDX_T_FinancialPaymentDetail" value="{{ $fields->IDX_T_FinancialPaymentDetail }}"/>
    <input type="hidden" id="IDX_T_FinancialPaymentHeader" name="IDX_T_FinancialPaymentHeader" value="{{ $fields->IDX_T_FinancialPaymentHeader }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>

    <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>
    <x-textbox-horizontal label="Account" id="COADesc" :value="$fields->COADesc1" placeholder="Select CoA..." class="required" />
    <x-textbox-horizontal label="Payment Amount" id="PaymentAmount" :value="$fields->PaymentAmount" placeholder="Payment Amount" class="required auto" />
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