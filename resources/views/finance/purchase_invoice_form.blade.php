@extends('layouts.form')

@section('left_header')    
    
@endsection

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')
        
    <x-btn-create-new label="Create New" :url="$url_create" />

    <x-btn-action>
        
        @if($fields->InvoiceStatus == 'D')
        <a id="btn-approval" class="dropdown-item" href="#"><i class="fa fa-check-double"></i> Approval</a>
        @endif

        @if($fields->InvoiceStatus == 'A')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#"><i class="fas fa-undo"></i> Reverse to Draft</a>
        @endif

        {{-- <div class="dropdown-divider"></div>            
        <a href="{{ url('fm-purchase-invoice/download-pdf').'/'.$fields->IDX_T_PurchaseInvoiceHeader }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <i class="fa fa-file-pdf"></i> Print PDF
        </a>         --}}

        <a id="btn-duplicate-header" class="dropdown-item text-primary" href="#" title="Duplicate this data"><i class="fas fa-copy"></i> Duplicate</a>
    </x-btn-action> 
    @endif
@endsection

@section('additional_log')
    <div class="card mb-3">
        <div class="card-body">
            <h6>Invoice Status</h6>
            <hr>
            @if($fields->InvoiceStatus == 'D')
            <span class="badge badge-pill outline-badge-danger p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @else 
            <span class="badge badge-pill outline-badge-info p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @endif
        </div>
    </div>
@endsection

@section('content_form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_PurchaseInvoiceHeader" name="IDX_T_PurchaseInvoiceHeader" value="{{ $fields->IDX_T_PurchaseInvoiceHeader }}"/>
    <input type="hidden" id="IDX_M_LocationInventory" name="IDX_M_LocationInventory" value="{{ $fields->IDX_M_LocationInventory }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_M_DocumentType" name="IDX_M_DocumentType" value="{{ $fields->IDX_M_DocumentType }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->COAHeader }}"/>
    
    <ul class="nav nav-tabs pb-3" role="tablist">    
        <li class="nav-item">
        <a class="nav-link text-muted active" href="#general" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>General</strong></a>
        </li>

        @if($fields->IDX_T_PurchaseInvoiceHeader <> 0)
            <li class="nav-item">
            <a class="nav-link text-muted" href="#invoice-item" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Invoice Item</strong></a>
            </li>
            <li class="nav-item">
            <a class="nav-link text-muted" href="#invoice-payment" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Invoice Payment</strong></a>
            </li>
            <li class="nav-item">
            <a class="nav-link text-muted" href="#journal" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Journal</strong></a>
            </li>
        @endif
    </ul>

    <!-- Tab panes -->
    <div class="tab-content mb-3">
        <div role="tabpanel" class="tab-pane fade in active" id="general">            
            <div class="card">
                <div class="card-body">

                    <legend><h6 class="text-muted font-weight-bold">Invoice Info</h6></legend>
                    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                    <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                    <x-textbox-horizontal label="Invoice No" id="InvoiceNo" :value="$fields->InvoiceNo" placeholder="Invoice No" class="readonly" />
                    {{-- <x-textbox-horizontal label="Purchase Order No" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="Purchase Order Reference No" class="required" /> --}}
                    <x-textbox-horizontal label="Purchase Order No" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="Select Purchase Order..." class="required" />
                    <x-textbox-horizontal label="Invoice Date" id="InvoiceDate" :value="$fields->InvoiceDate" placeholder="Invoice Date" class="required datepicker2" />
                    <x-textbox-horizontal label="Due Date" id="InvoiceDueDate" :value="$fields->InvoiceDueDate" placeholder="Invoice Due Date" class="required datepicker2" />
                    <x-textbox-horizontal label="Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required" />

                    <legend><h6 class="text-muted font-weight-bold">Business Partner</h6></legend>
                    <x-lookup-horizontal label="Vendor" id="PartnerDesc" :value="$fields->PartnerDesc" class="required"  button="btn-find-partner"/>

                    <legend><h6 class="text-muted font-weight-bold">Accounting Info</h6></legend>
                    <x-select-horizontal label="Currency" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>
                    <x-lookup-horizontal label="AP Account" id="COAHeader" :value="$fields->COAHeaderDesc" class="required"  button="btn-find-coa"/>
                    <x-textbox-horizontal label="Vendor Delivery No" id="SupplierDeliveryNo" :value="$fields->SupplierDeliveryNo" placeholder="Supplier Delivery No" class="required" />
                    <x-textbox-horizontal label="Vendor Invoice No" id="VendorInvoiceNo" :value="$fields->VendorInvoiceNo" placeholder="Vendor Invoice No" class="required" />
                    <x-textbox-horizontal label="No Faktur Pajak" id="FakturPajak" :value="$fields->FakturPajak" placeholder="Faktur Pajak" class="required" />
                    @php
                        $IsTaxChecked = '';
                        if($fields->IsTaxChecked == '1'){ $IsTaxChecked = 'checked'; }                              
                    @endphp    
                    <x-checkbox-horizontal id="IsTaxChecked" name="IsTaxChecked" label="Checklist Tax" :value="$IsTaxChecked" :checked="$IsTaxChecked" />

                </div>
                
                <hr>
                
                <div class="form-row m-2"> 
                    <div class="col-12 mb-3"> 
                        @if($fields->InvoiceStatus == 'D' || $fields->InvoiceStatus == '')
                            @include('form_helper.btn_save_header')
                        @endif
                    </div>
                </div>
            </div>

        </div>

        @if($fields->IDX_T_PurchaseInvoiceHeader <> 0)
            <div role="tabpanel" class="tab-pane fade in" id="invoice-item">            
                <div class="card">
                    <div class="card-body">
    
                        
                        @if($fields->InvoiceStatus == 'D')
                            <x-btn-add-detail id="btn-add-detail" label="Add Invoice Item" />
                            {{-- <x-btn-add-detail id="btn-add-tax" label="Add Additional Tax" /> --}}
                            <br><br>
                        @endif
                    
                        <div id="table-purchaseinvoice-detail" class="table-responsive">
                            @include('finance.purchase_invoice_detail_list')            
                        </div>
                                            
                        {{-- <div id="table-purchaseinvoice-tax" class="table-responsive">
                            @include('finance.purchase_invoice_tax_list')            
                        </div> --}}
                    </div>            
                </div>
            </div>
    
            <div role="tabpanel" class="tab-pane fade in" id="invoice-payment">            
                <div class="card">
                    <div class="card-body">
    
                        @if($fields->InvoiceStatus == 'A')
                            <x-btn-add-detail id="btn-add-payment" label="Create Payment For This Invoice" />
                            <br><br>
                        @endif
                        
                        <div id="table-purchaseinvoice-payment" class="table-responsive">
                            @include('finance.purchase_invoice_payment_list')            
                        </div>
    
                    </div>            
                </div>
            </div>
    
            <div role="tabpanel" class="tab-pane fade in" id="journal">            
                <div class="card">
                    <div class="card-body">
                    
                        <div id="table-purchaseinvoice-journal" class="table-responsive">
                            @include('finance.purchase_invoice_journal_list')            
                        </div>
    
                    </div>            
                </div>
            </div>
        @endif

    </div>    

@endsection

@section('script')

    <script>

        function deleteDetail(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-purchase-invoice-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseInvoiceHeader": $("#IDX_T_PurchaseInvoiceHeader").val(),
                "IDX_T_PurchaseInvoiceDetail": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-purchase-invoice-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseInvoiceHeader": $("#IDX_T_PurchaseInvoiceHeader").val(),
                "IDX_T_PurchaseInvoiceDetail": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function deleteTax(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-purchase-invoice-tax/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseInvoiceHeader": $("#IDX_T_PurchaseInvoiceHeader").val(),
                "IDX_T_PurchaseInvoiceTax": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function addTax(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-purchase-invoice-tax/create') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseInvoiceHeader": $("#IDX_T_PurchaseInvoiceHeader").val(),                     
            }
            
            callAjaxModalView(url,data);
        }

        function editTax(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-purchase-invoice-tax/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseInvoiceHeader": $("#IDX_T_PurchaseInvoiceHeader").val(),
                "IDX_T_PurchaseInvoiceTax": idx            
            }
            
            callAjaxModalView(url,data);
        }

        // function editPayment(idx)
        // {
        //     //alert('Delete ' + idx);
        //     var url = "{{ url('fm-financial-payment/update') }}"+'/'+idx;

        //     // GET CURRENT SCROLL TOP POSITION
        //     getScrollPosition();

        //     var data = {
        //         "_token": $('#_token').val(),
        //         "IDX_T_FinancialPaymentHeader": idx            
        //     }
            
        //     callAjaxModalView(url,data);
        // } 

        $(document).ready(function(){

            $('#btn-find-partner').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_Partner',
                    target_name: 'PartnerDesc'                  
                }              

                callAjaxModalView('{{ url('/fm-select-partner-pi') }}',data);                
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
                    IDX_T_PurchaseInvoiceHeader: $("#IDX_T_PurchaseInvoiceHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-purchase-invoice-detail/create') }}',data);            
            });

            $('#btn-add-tax').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseInvoiceHeader: $("#IDX_T_PurchaseInvoiceHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-purchase-invoice-tax/create') }}',data);            
            });
            
            $('#btn-add-payment').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseInvoiceHeader: $("#IDX_T_PurchaseInvoiceHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-purchase-invoice-payment/create') }}',data);            
            });

            $('#btn-approval').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseInvoiceHeader: $("#IDX_T_PurchaseInvoiceHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-purchase-invoice/approve') }}',data);            
            });

            $('#btn-reverse').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseInvoiceHeader: $("#IDX_T_PurchaseInvoiceHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-purchase-invoice/reverse') }}',data);            
            });

            $("#ReferenceNo").autocomplete({                
                
                source: function( request, response ){
                    $.ajax( {
                    url: "{{ url('/fm-purchase-order/search') }}",
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
                    // $("#IDX_T_PurchaseOrder").val(ui.item.IDX_T_PurchaseOrder);

                    $("#ReferenceNo").text(ui.item.ReferenceNo);
                }
            });  

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseInvoiceHeader: $("#IDX_T_PurchaseInvoiceHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-purchase-invoice/duplicate') }}',data);            
            });

        });

    </script>

@endsection