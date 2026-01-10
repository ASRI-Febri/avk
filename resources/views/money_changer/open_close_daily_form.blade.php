@extends('layouts.master-form-transaction')

@section('form-remark')
    Transaki untuk melakukan perhitungan persiapan dan penutupan harian     
@endsection

@section('action')

    <x-btn-action>
        
        @if($fields->TransactionStatus == 'O')
        <a id="btn-approval" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i> 
            </div>
            <span class="dropdown-content">Closing</span>            
        </a>
        @endif

        @if($fields->TransactionStatus == 'C')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i> 
            </div>
            <span class="dropdown-content">Reverse to Open</span> 
        </a>
        @endif

        <div class="dropdown-divider"></div>   

        <a href="{{ url('mc-open-close/download-pdf').'/'.$fields->IDX_T_OpenCloseDaily }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i>
            </div> 
            <span class="dropdown-content">Print Document</span>            
        </a>        
    </x-btn-action>

@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_OpenCloseDaily" name="IDX_T_OpenCloseDaily" value="{{ $fields->IDX_T_OpenCloseDaily }}"/>    
    <input type="hidden" id="TransactionStatus" name="TransactionStatus" value="{{ $fields->TransactionStatus }}"/>    

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->TransactionDate . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="row">        
        <div class="col-md-6">

            <div class="card">
                
                <div class="card-body">
                    <div class="d-grid gap-3">                        
                        <x-textbox-horizontal label="Tanggal Transaksi" id="TransactionDate" :value="$fields->TransactionDate" placeholder="" class="required datepicker2" />
                    </div>
                </div>

            </div> 
            
        </div>
        <div class="col-md-6">
            <div class="card">
                
                <div class="card-body">
                    <div class="d-grid gap-3">                        
                        <x-textbox-horizontal label="Teller" id="TellerID" :value="$fields->TellerID" placeholder="" class="required" />
                    </div>
                </div>

            </div>

            <div class="d-grid gap-3">
                            </div>            
        </div>
    </div>

    @if($fields->TransactionStatus == 'O')
    <div class="row"> 
        <div class="col-12 mb-2">           
            @include('form_helper.btn_save_header')
        </div>
    </div>
    @endif

    @if($state != 'create')          
        <div class="card border">
            <div class="card-header">      
                <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
                    <a class="nav-item nav-link active" id="card-detail-tab" data-bs-toggle="tab" href="#card-detail" aria-selected="false" role="tab" tabindex="-1">
                        <i class="fas fa-align-justify"></i> Detail Transaksi
                    </a>    
                    <a class="nav-item nav-link" id="card-log-tab" data-bs-toggle="tab" href="#card-log" aria-selected="true" role="tab">
                            <i class="fas fa-coins"></i> Log</a>        
                </div>
            </div>
            <div class="card-body">
                <div class="tab-content">
                    <div class="tab-pane fade active show" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">                        
                        @if($fields->TransactionStatus == 'O')                
                            <x-btn-add-detail id="btn-add-detail" label="Input Valas" />                        
                        @endif
            
                        <div id="table-order-detail" class="table-responsive">
                            @include('money_changer.open_close_detail_list')            
                        </div>
                    </div>
                    <div class="tab-pane fade" id="card-log" role="tabpanel" aria-labelledby="#card-log-tab">

                    </div>
                </div>
            </div>
        </div>
    @endif                 

@endsection

@section('script')

    <script>

        function deleteDetailValas(idx,item_description)
        {
            //alert('Delete data' + idx);
            var url = "{{ url('mc-open-close-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_OpenCloseDaily": $("#IDX_T_OpenCloseDaily").val(),
                "IDX_T_OpenCloseDailyDetail": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url, data);
        }

        function editDetail(idx)
        {
            //alert('Edit data ' + idx);
            var url = "{{ url('mc-open-close-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_OpenCloseDaily": $("#IDX_T_OpenCloseDaily").val(),
                "IDX_T_OpenCloseDailyDetail": idx            
            }
            
            callAjaxModalView(url, data);
        }

        $(document).ready(function()
        {
            $('#btn-find-partner').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_Partner',
                    target_name: 'PartnerDesc'                  
                }              

                callAjaxModalView('{{ url('/gn-select-partner') }}',data);                
            });

            $('#btn-find-coa').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_COA',
                    target_name: 'COAHeader'                  
                }              

                callAjaxModalView('{{ url('/fm-select-coa') }}',data);                
            });

            // $( "#InvoiceDate, #InvoiceDueDate" ).datepicker({ dateFormat: 'yy-mm-dd' });

            $('#btn-add-detail').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_OpenCloseDaily: $("#IDX_T_OpenCloseDaily").val(),
                }                

                callAjaxModalView('{{ url('mc-open-close-detail/create') }}',data);            
            });

            $('#btn-approval').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_OpenCloseDaily: $("#IDX_T_OpenCloseDaily").val(),
                }                

                callAjaxModalView('{{ url('mc-open-close/approve') }}',data);            
            });

            $('#btn-reverse').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_OpenCloseDaily: $("#IDX_T_OpenCloseDaily").val(),
                }                

                callAjaxModalView('{{ url('mc-open-close/reverse') }}',data);            
            });

            // $("#ReferenceNo").autocomplete({                
                
            //     source: function( request, response ){
            //         $.ajax( {
            //         url: "{{ url('/fm-purchase-order/search') }}",
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
            //         $("#ReferenceNo").text(ui.item.ReferenceNo);
            //     }
            // });  

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_OpenCloseDaily: $("#IDX_T_OpenCloseDaily").val(),
                }                

                callAjaxModalView('{{ url('mc-open-close/duplicate') }}',data);            
            });

        });

    </script>

@endsection