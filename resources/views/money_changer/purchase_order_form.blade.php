@extends('layouts.master-form-transaction')

@section('form-remark')
    Purchase order untuk melakukan pembelian valuta asing dari supplier. 
    <br> 
    Contoh nomor PO <code>PO-100-2506-001</code> untuk kode cabang 100, bulan 05 tahun 2025.
@endsection

@section('action')

    <x-btn-action>
        
        @if($fields->POStatus == 'D')
        <a id="btn-approval" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i> 
            </div>
            <span class="dropdown-content">Approval</span>            
        </a>
        @endif

        @if($fields->POStatus == 'A')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i> 
            </div>
            <span class="dropdown-content">Reverse to Draft</span> 
        </a>
        @endif

        <div class="dropdown-divider"></div>   

        <a href="{{ url('pr-purchase-order/download-pdf').'/'.$fields->IDX_T_PurchaseOrder }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i>
            </div> 
            <span class="dropdown-content">Print PO</span>            
        </a>        
    </x-btn-action>

@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_PurchaseOrder" name="IDX_T_PurchaseOrder" value="{{ $fields->IDX_T_PurchaseOrder }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="POStatus" name="POStatus" value="{{ $fields->POStatus }}"/>

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->PONumber . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="row">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">General</h3>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-3">
                        <x-select-horizontal label="Perusahaan" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                        <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                        <x-textbox-horizontal label="No Referensi" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="(No Quotation atau Penawaran)" class="" />
                    </div>
                </div>
            </div>            
        </div>
        <div class="col-md-6">

            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Informasi PO</h3>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-3">
                        <x-textbox-horizontal label="No PO" id="PONumber" :value="$fields->PONumber" placeholder="(Auto)" class="readonly" />
                        <x-textbox-horizontal label="Tanggal PO" id="PODate" :value="$fields->PODate" placeholder="" class="required datepicker2" />
                        <x-lookup-horizontal label="Supplier" id="PartnerDesc" :value="$fields->PartnerDesc" class="required"  button="btn-find-partner"/>                        
                        <x-textbox-horizontal label="Keterangan PO" id="PONotes" :value="$fields->PONotes" placeholder="" class="required" />
                    </div>
                </div>
            </div> 
            
        </div>
    </div>

    @if($fields->POStatus == 'D')
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
                        <i class="fas fa-align-justify"></i> Detail Pembelian
                    </a>    
                    <a class="nav-item nav-link" id="card-log-tab" data-bs-toggle="tab" href="#card-log" aria-selected="true" role="tab">
                            <i class="fas fa-coins"></i> Log</a>        
                </div>
            </div>
            <div class="card-body">
                <div class="tab-content">
                    <div class="tab-pane fade active show" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">                        
                        @if($fields->POStatus == 'D')                
                            <x-btn-add-detail id="btn-add-detail" label="Add New Valas" />                        
                        @endif
            
                        <div id="table-order-detail" class="table-responsive">
                            @include('money_changer.purchase_order_detail_list')            
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

        function deleteDetail(idx,item_description)
        {
            alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseOrderDetail": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Edit ' + idx);
            var url = "{{ url('mc-purchase-order-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseOrderDetail": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function deleteTax(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-tax/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseInvoiceTax": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function addTax(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-tax/create') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),                     
            }
            
            callAjaxModalView(url,data);
        }

        function editTax(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-tax/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseInvoiceTax": idx            
            }
            
            callAjaxModalView(url,data);
        }

        $(document).ready(function(){

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
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order-detail/create') }}',data);            
            });

            $('#btn-add-tax').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order-tax/create') }}',data);            
            });
            
            $('#btn-add-payment').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order-payment/create') }}',data);            
            });

            $('#btn-approval').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order/approve') }}',data);            
            });

            $('#btn-reverse').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order/reverse') }}',data);            
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
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order/duplicate') }}',data);            
            });

        });

    </script>

@endsection