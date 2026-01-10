@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-journal-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_JournalDetail" name="IDX_T_JournalDetail" value="{{ $fields->IDX_T_JournalDetail }}"/>
    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>    
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>  
    <input type="hidden" id="COADesc" name="COADesc" value="{{ $fields->COADesc }}"/>    

    <!-- PROJECT & DEPARTMENT -->
    <div class="mb-2">
        <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>
    </div>

    <div class="mb-2">
        <x-select-horizontal label="Department" id="IDX_M_Department" :value="$fields->IDX_M_Department" class="" :array="$dd_department"/>
    </div>

    <!-- COA & DETAIL DESCRIPTION -->
    {{-- <x-textbox-horizontal label="Chart of Account" id="COADesc" :value="$fields->COADesc" placeholder="Select CoA..." class="required mb-2" /> --}}
    
    <div class="form-group row mb-2">
        <label class="col-sm-3 col-form-label text-secondary">Chart of Account</label>
        <div class="col-sm-9">
            <select id="COASelect" name="COASelect" class="">            
                
            </select>
        </div>
    </div>
    
    <x-textarea-horizontal label="Detail Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="" class="required mb-2" />

    <!-- CURRENCY & EXCHANGE RATE -->
    <div class="mb-2">
        <x-select-horizontal label="Original Currency" id="OriginalCurrencyID" :value="$fields->OriginalCurrencyID" class="required" :array="$dd_currency"/>
    </div>
    
    <x-textbox-horizontal label="Exchange Rate" id="ExchangeRate" :value="$fields->ExchangeRate" placeholder="" class="auto required mb-2" />

    <!-- DEBET OR CREDIT AMOUNT -->
    <x-textbox-horizontal label="Debet" id="ODebetAmount" :value="$fields->ODebetAmount" placeholder="" class="auto required mb-2" />    
    <x-textbox-horizontal label="Credit" id="OCreditAmount" :value="$fields->OCreditAmount" placeholder="" class="auto required mb-2" />    

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

            $("#ODebetAmount").change(function() {

                var debet = $("#ODebetAmount").val();
                if(debet !== '0.00'){
                    $('#OCreditAmount').prop('readonly', true);
                } else {
                    $('#OCreditAmount').prop('readonly', false);
                }

            });

            $("#OCreditAmount").change(function() {

                var credit = $("#OCreditAmount").val();
                if(credit !== '0.00'){
                    $('#ODebetAmount').prop('readonly', true);
                } else {
                    $('#ODebetAmount').prop('readonly', false);
                }

            });	

            $("#COASelect").select2({
                ajax: {
                    url: "{{ url('/ac-search-coa-journal-detail') }}",
                    dataType: 'json',
                    type: 'post',
                    delay: 250,
                    data: function (params) {
                        return {
                            q: params.term, // search term
                            //page: params.page,
                            _token: $('#_token').val()
                        };
                    },
                    // processResults: function (data, params) {
                    //     // parse the results into the format expected by Select2
                    //     // since we are using custom formatting functions we do not need to
                    //     // alter the remote JSON data, except to indicate that infinite
                    //     // scrolling can be used
                    //     params.page = params.page || 1;

                    //     return {
                    //         results: data.items,
                    //         pagination: {
                    //         more: (params.page * 30) < data.total_count
                    //         }
                    //     };
                    // },
                    processResults: function (data) {
                        return {
                            results: data
                        };
                    },
                    cache: true
                },
                placeholder: "{{ $fields->COADesc }}",
                minimumInputLength: 3,
                //templateResult: formatRepo,
                //templateSelection: formatRepoSelection,
                dropdownParent: $("#div-form-modal") 
            });

            $('#COASelect').on('select2:select', function (e) {
                var data = e.params.data;

                console.log(data);

                $("#IDX_M_COA").val(data.IDX_M_COA);
                //$("#IDX_M_PostalCode").text(data.IDX_M_PostalCode);
                //$("#Zip").val(data.Zip);
                $("#COADesc").text(data.COADesc);
            });

            // $("#COADesc").autocomplete({                
                
            //     source: function( request, response ){
            //         $.ajax( {
            //         url: "{{ url('/ac-search-coa-journal-detail') }}",
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
            //         $("#IDX_M_COA").val(ui.item.IDX_M_COA);
            //         $("#COADesc").text(ui.item.COADesc);
            //     }
            // });
        });
    </script>
@endsection