@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-financialreceive-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialReceiveDetail" name="IDX_T_FinancialReceiveDetail" value="{{ $fields->IDX_T_FinancialReceiveDetail }}"/>
    <input type="hidden" id="IDX_T_FinancialReceiveHeader" name="IDX_T_FinancialReceiveHeader" value="{{ $fields->IDX_T_FinancialReceiveHeader }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>
    <input type="hidden" id="IDX_DocumentNo" name="IDX_DocumentNo" value="{{ $fields->IDX_DocumentNo ?? 0 }}"/>
    <input type="hidden" id="DocumentNo" name="DocumentNo" value="{{ $fields->DocumentNo ?? '' }}"/>
    <input type="hidden" id="COADesc" name="COADesc" value="{{ $fields->COADesc }}"/>  

    <div class="mb-2">
        <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>
    </div>
    
        {{-- <x-textbox-horizontal label="Account" id="COADesc" :value="$fields->COADesc1" placeholder="Select CoA..." class="required" /> --}}
    
    <div class="form-group row mb-2">
        <label class="col-sm-3 col-form-label text-secondary">Chart of Account</label>
        <div class="col-sm-9">
            <select id="COASelect" name="COASelect" class="">            
                
            </select>
        </div>
    </div>
    
    <div class="mb-2">
        <x-textbox-horizontal label="Receive Amount" id="ReceiveAmount" :value="$fields->ReceiveAmount" placeholder="Receive Amount" class="required auto" />
    </div>

    <div class="mb-2">
        <x-textbox-horizontal label="Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="Notes" class="required" />
    </div>

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
            //         url: "{{ url('/fm-account/search') }}",
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