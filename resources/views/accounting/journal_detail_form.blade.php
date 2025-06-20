@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-journal-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_JournalDetail" name="IDX_T_JournalDetail" value="{{ $fields->IDX_T_JournalDetail }}"/>
    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>    
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>    

    <!-- PROJECT & DEPARTMENT -->
    <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>
    <x-select-horizontal label="Department" id="IDX_M_Department" :value="$fields->IDX_M_Department" class="" :array="$dd_department"/>    

    <!-- COA & DETAIL DESCRIPTION -->
    <x-textbox-horizontal label="Chart of Account" id="COADesc" :value="$fields->COADesc" placeholder="Select CoA..." class="required" />
    <x-textarea-horizontal label="Detail Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="" class="required" />

    <!-- CURRENCY & EXCHANGE RATE -->
    <x-select-horizontal label="Original Currency" id="OriginalCurrencyID" :value="$fields->OriginalCurrencyID" class="required" :array="$dd_currency"/>
    <x-textbox-horizontal label="Exchange Rate" id="ExchangeRate" :value="$fields->ExchangeRate" placeholder="" class="auto required" />

    <!-- DEBET OR CREDIT AMOUNT -->
    <x-textbox-horizontal label="Debet" id="ODebetAmount" :value="$fields->ODebetAmount" placeholder="" class="auto required" />    
    <x-textbox-horizontal label="Credit" id="OCreditAmount" :value="$fields->OCreditAmount" placeholder="" class="auto required" />    

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
                    url: "{{ url('/ac-search-coa-journal-detail') }}",
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