@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-financialpayment-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PaymentAllocation" name="IDX_T_PaymentAllocation" value="{{ $fields->IDX_T_PaymentAllocation }}"/>
    <input type="hidden" id="IDX_T_FinancialPaymentDetail" name="IDX_T_FinancialPaymentDetail" value="{{ $fields_detail->IDX_T_FinancialPaymentDetail }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="DocumentNo" name="DocumentNo" value="{{ $fields->IDX_DocumentNo }}"/>
    <input type="hidden" id="COAAllocation" name="COAAllocation" value="{{ $fields->COAAllocation }}"/>
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $fields_detail->IDX_M_Branch }}"/>

    <x-textbox-horizontal label="Partner" id="PartnerDesc" :value="$fields->PartnerDesc" placeholder="Select Partner..." class="required" />
    {{-- <x-select-horizontal label="Document No" id="IDX_DocumentNo" :value="$fields->IDX_DocumentNo" class="required" :array="$dd_document_no"/> --}}

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Document No</label>
        <div class="col-sm-9">
            <select id="IDX_DocumentNo" name="IDX_DocumentNo" class="select2 form-control required">
                @if($state == 'create')
                <option value=''>--SELECT--</option>
                @else
                <option value="{{ $fields->IDX_DocumentNo }}" selected>
                    {{ $fields->DocumentNo }}
                </option>
                @endif 
                {{-- @foreach($array as $key => $value_component)
                    <option value="{{ $key }}" {{ trim($value) == $key ? 'selected=' : '' }}>
                        {{ $value_component }}
                    </option>                            
                @endforeach --}}
            </select>
        </div>
    </div>

    {{-- <x-textbox-horizontal label="Document Date" id="DocumentDate" :value="" placeholder="(Auto)" class="auto" /> --}}
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Document Date</label>
        <div class="col-sm-9">
            <input type="text" id="DocumentDate" name="DocumentDate" 
                class="form-control" readonly placeholder="(YYYY-MM-DD)">
        </div>
    </div>
    {{-- <x-textbox-horizontal label="Due Date" id="DueDate" :value="" placeholder="(Auto)" class="auto" /> --}}
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Due Date</label>
        <div class="col-sm-9">
            <input type="text" id="DueDate" name="DueDate" 
                class="form-control" readonly placeholder="(YYYY-MM-DD)">
        </div>
    </div>
    {{-- <x-textbox-horizontal label="Outstanding Amount" id="OutstandingAmount" :value="" placeholder="(Auto)" class="auto" /> --}}
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Outstanding Amount</label>
        <div class="col-sm-9">
            <input type="text" id="OutstandingAmount" name="OutstandingAmount" 
                class="form-control auto" readonly placeholder="(Auto)">
        </div>
    </div>
    <hr>
    <x-textbox-horizontal label="Account" id="COADesc" :value="$fields->COADesc1" placeholder="Select CoA..." class="required" />
    <x-textbox-horizontal label="Allocation Date" id="AllocationDate" :value="$fields->AllocationDate" placeholder="Allocation Date" class="required datepicker2" />
    <x-textbox-horizontal label="Allocation Amount" id="AllocationAmount" :value="$fields->AllocationAmount" placeholder="Payment Amount" class="required auto" />
    <x-textbox-horizontal label="Notes" id="RemarkAllocation" :value="$fields->RemarkAllocation" placeholder="Notes" class="required" />

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

            $("#PartnerDesc").autocomplete({                
                
                source: function( request, response ){
                    $.ajax( {
                    url: "{{ url('/fm-partner/search') }}",
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
                    $("#IDX_M_Partner").val(ui.item.IDX_M_Partner);

                    $("#PartnerDesc").text(ui.item.PartnerDesc);
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
                    $("#COAAllocation").val(ui.item.IDX_M_COA);

                    $("#COADesc").text(ui.item.COADesc);
                }
            });

            $('#IDX_DocumentNo').change(function(){
                // var documentno = $('#IDX_DocumentNo option:selected').text().trim();
                var documentno = $('#IDX_DocumentNo').val();
                $('#DocumentNo').val(documentno);
            });

            // Partner Change
            $('#PartnerDesc').change(function(){

                // Partner id
                var id = $('#IDX_M_Partner').val();

                // Empty the dropdown
                $('#IDX_DocumentNo').find('option').not(':first').remove();

                // AJAX request 
                $.ajax({
                url: 'getDocumentNo/'+id,
                type: 'get',
                dataType: 'json',
                data: {                                           
                        IDX_M_Branch: $('#IDX_M_Branch').val(),
                        IDX_M_Partner: $('#IDX_M_Partner').val(),
                        _token: $('#_token').val()
                    },
                success: function(response){

                    var len = 0;
                    if(response['data'] != null){
                    len = response['data'].length;
                    }

                    if(len > 0){
                    // Read data and create <option >
                        for(var i=0; i<len; i++){

                            var id = response['data'][i].IDX_DocumentNo;
                            var name = response['data'][i].DocumentNo2;

                            var option = "<option value='"+id+"'>"+name+"</option>"; 

                            $("#IDX_DocumentNo").append(option); 
                        }
                    }

                    }
                });
            });

            if($('#IDX_M_Partner').val()) {
                // Partner id
                var id = $('#IDX_M_Partner').val();

                // Empty the dropdown
                $('#IDX_DocumentNo').find('option').not(':first').remove();

                // AJAX request 
                $.ajax({
                url: 'getDocumentNo/'+id,
                type: 'get',
                dataType: 'json',
                success: function(response){

                    var len = 0;
                    if(response['data'] != null){
                    len = response['data'].length;
                    }

                    if(len > 0){
                    // Read data and create <option >
                        for(var i=0; i<len; i++){

                            var id = response['data'][i].IDX_DocumentNo;
                            var name = response['data'][i].DocumentNo2;

                            if($('#DocumentNo').val() == response['data'][i].IDX_DocumentNo ) {
                                var option = "<option value='"+id+"' selected>"+name+"</option>"; 
                            } else {
                                var option = "<option value='"+id+"'>"+name+"</option>"; 
                            }

                            $("#IDX_DocumentNo").append(option); 
                        }
                    }

                    }
                });

                // Partner id
                var id1 = $('#DocumentNo').val();



                // AJAX request 
                $.ajax({
                url: 'getDocumentInfo/'+id1,
                type: 'get',
                dataType: 'json',
                success: function(response){

                    var len = 0;
                    if(response['data'] != null){
                        len = response['data'].length;
                    }

                    if(len > 0){
                    // Read data and create <option >
                        for(var i=0; i<len; i++){

                            //document date, due date, outstanding amount
                            var date = response['data'][i].InvoiceDate;
                            var dueDate = response['data'][i].InvoiceDueDate;
                            var outstandingAmount = response['data'][i].OutstandingAmount;

                            $("#DocumentDate").val(date); 
                            $("#DueDate").val(dueDate); 
                            $("#OutstandingAmount").val(outstandingAmount); 
                        }
                    }

                    }
                });
            }

            // Partner Change
            $('#IDX_DocumentNo').change(function(){

                // Partner id
                // var id = $('#IDX_DocumentNo option:selected').text();
                var id = $('#IDX_DocumentNo').val();

                // AJAX request 
                $.ajax({
                url: 'getDocumentInfo/'+id,
                type: 'get',
                dataType: 'json',
                success: function(response){

                    var len = 0;
                    if(response['data'] != null){
                        len = response['data'].length;
                    }

                    if(len > 0){
                    // Read data and create <option >
                        for(var i=0; i<len; i++){

                            //document date, due date, outstanding amount
                            var date = response['data'][i].InvoiceDate;
                            var dueDate = response['data'][i].InvoiceDueDate;
                            var outstandingAmount = response['data'][i].OutstandingAmount;

                            $("#DocumentDate").val(date); 
                            $("#DueDate").val(dueDate); 
                            $("#OutstandingAmount").val(outstandingAmount); 
                        }
                    }

                    }
                });
            });

            // if($('#IDX_DocumentNo').val()) {
            //     // Partner id
            //     var id = $('#DocumentNo').val();

            //     // AJAX request 
            //     $.ajax({
            //     url: 'getDocumentInfo/'+id,
            //     type: 'get',
            //     dataType: 'json',
            //     success: function(response){

            //         var len = 0;
            //         if(response['data'] != null){
            //             len = response['data'].length;
            //         }

            //         if(len > 0){
            //         // Read data and create <option >
            //             for(var i=0; i<len; i++){

            //                 //document date, due date, outstanding amount
            //                 var date = response['data'][i].InvoiceDate;
            //                 var dueDate = response['data'][i].InvoiceDueDate;
            //                 var outstandingAmount = response['data'][i].OutstandingAmount;

            //                 $("#DocumentDate").val(date); 
            //                 $("#DueDate").val(dueDate); 
            //                 $("#OutstandingAmount").val(outstandingAmount); 
            //             }
            //         }

            //         }
            //     });
            // }

        });
    </script>
@endsection