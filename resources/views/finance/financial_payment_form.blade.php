@extends('layouts.form')

@section('left_header')    
    
@endsection

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')
        
    <x-btn-create-new label="Create New" :url="$url_create" />

    <x-btn-action>
        
        @if($fields->PaymentStatus == 'D')
        <a id="btn-validate" class="dropdown-item" href="#"><i class="fa fa-check-double"></i> Approval</a>
        @endif

        @if($fields->PaymentStatus == 'A')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#"><i class="fas fa-undo"></i> Reverse Approval</a>
        <a id="btn-validate" class="dropdown-item" href="#"><i class="fa fa-check-double"></i> Handover Payment</a>
        @endif

        @if($fields->PaymentStatus == 'F')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#"><i class="fas fa-undo"></i> Reverse Approval</a>
        <a id="btn-void" class="dropdown-item" href="#"><i class="fas fa-undo"></i> Void Transaction</a>
        @endif

        <div class="dropdown-divider"></div>            
        <a href="{{ url('fm-financial-payment/download-pdf').'/'.$fields->IDX_T_FinancialPaymentHeader }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <i class="fa fa-file-pdf"></i> Print PDF
        </a>       
        
        <a id="btn-duplicate-header" class="dropdown-item text-primary" href="#" title="Duplicate this data"><i class="fas fa-copy"></i> Duplicate</a>
    </x-btn-action> 
    @endif
@endsection

@section('additional_log')
    <div class="card mb-3">
        <div class="card-body">
            <h6>Payment Status</h6>
            <hr>
            @if($fields->PaymentStatus == 'D' || $fields->PaymentStatus == 'V')
            <span class="badge badge-pill outline-badge-danger p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @else 
            <span class="badge badge-pill outline-badge-info p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @endif
        </div>
    </div>
@endsection

@section('content_form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_FinancialPaymentHeader" name="IDX_T_FinancialPaymentHeader" value="{{ $fields->IDX_T_FinancialPaymentHeader }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>

    <ul class="nav nav-tabs pb-3" role="tablist">    
        <li class="nav-item">
        <a class="nav-link text-muted active" href="#general" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>General</strong></a>
        </li>

        @if($fields->IDX_T_FinancialPaymentHeader <> 0)
            <li class="nav-item">
            <a class="nav-link text-muted" href="#detail-payment" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Detail Payment</strong></a>
            </li>
            <li class="nav-item">
            <a class="nav-link text-muted" href="#journal-payment" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Journal Payment</strong></a>
            </li>
            <li class="nav-item">
            <a class="nav-link text-muted" href="#journal-allocation" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Journal Allocation</strong></a>
            </li>
        @endif
    </ul>

    <!-- Tab panes -->
    <div class="tab-content mb-3">
        <div role="tabpanel" class="tab-pane fade in active" id="general">            
            <div class="card">
                <div class="card-body">

                    <legend><h6 class="text-muted font-weight-bold">General Info</h6></legend>
                    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                    <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                    <x-select-horizontal label="Document Type" id="IDX_M_DocumentType" :value="$fields->IDX_M_DocumentType" class="required" :array="$dd_document_type"/>
                    <x-textbox-horizontal label="Payment ID (Auto)" id="PaymentID" :value="$fields->PaymentID" placeholder="(Auto)" class="" />
                    <x-textbox-horizontal label="Voucher No Manual" id="VoucherNoManual" :value="$fields->VoucherNoManual" placeholder="Voucher No Manual" class="required" />
                    <x-textbox-horizontal label="Payment Date" id="PaymentDate" :value="$fields->PaymentDate" placeholder="Payment Date" class="required datepicker2" />
                    <x-textbox-horizontal label="Payment Amount" id="PaymentAmount" :value="$fields->PaymentAmount" placeholder="Payment Amount" class="required auto" />
                    <x-textbox-horizontal label="Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required" />
                    <x-textbox-horizontal label="Destination Account Name" id="DestinationAccountName" :value="$fields->DestinationAccountName" placeholder="Destination Account Name" class="required" />
                    <x-textbox-horizontal label="Destination Bank" id="DestinationBank" :value="$fields->DestinationBank" placeholder="Destination Bank" class="required" />
                    <x-textbox-horizontal label="Destination Account No" id="DestinationAccountNo" :value="$fields->DestinationAccountNo" placeholder="Destination Account No" class="required" />
                        

                    <legend><h6 class="text-muted font-weight-bold">Business Partner</h6></legend>
                    <x-lookup-horizontal label="Paid To" id="PartnerDesc" :value="$fields->PartnerName" class="required" button="btn-find-partner"/>

                    <legend><h6 class="text-muted font-weight-bold">Financial Info</h6></legend>
                    <x-select-horizontal label="Currency" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>
                    <x-select-horizontal label="Payment Method" id="IDX_M_PaymentType" :value="$fields->IDX_M_PaymentType" class="required" :array="$dd_payment_method"/>
                    <x-textbox-horizontal label="No Giro" id="PDCNo" :value="$fields->PDCNo" placeholder="No Giro" class="required" />
                    <x-select-horizontal label="Financial Account" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>

                </div>
                
                <hr>
                
                <div class="form-row m-2"> 
                    <div class="col-12 mb-3">           
                        @if($fields->PaymentStatus == 'D' || $fields->PaymentStatus == '')
                            @include('form_helper.btn_save_header')
                        @endif
                    </div>
                </div>
            </div>

        </div>

        @if($fields->IDX_T_FinancialPaymentHeader <> 0)

            <div role="tabpanel" class="tab-pane fade in" id="detail-payment">            
                <div class="card">
                    <div class="card-body">

                        @if($fields->PaymentStatus == 'D')
                            <x-btn-add-detail id="btn-add-detail" label="Add Detail COA" />
                            <br><br>
                        @endif
                    
                        <div id="table-financialpayment-detail" class="table-responsive">
                            @include('finance.financial_payment_detail_list')            
                        </div>

                    </div>            
                </div>
            </div>

            <div role="tabpanel" class="tab-pane fade in" id="journal-payment">            
                <div class="card">
                    <div class="card-body">
                    
                        <div id="table-financialpayment-payment" class="table-responsive">
                            @include('finance.financial_payment_payment_list')            
                        </div>

                    </div>            
                </div>
            </div>

            <div role="tabpanel" class="tab-pane fade in" id="journal-allocation">            
                <div class="card">
                    <div class="card-body">
                    
                        <div id="table-financialpayment-journal" class="table-responsive">
                            @include('finance.financial_payment_journal_list')            
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
            var url = "{{ url('fm-financial-payment-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_FinancialPaymentHeader": $("#IDX_T_FinancialPaymentHeader").val(),
                "IDX_T_FinancialPaymentDetail": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-payment-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_FinancialPaymentHeader": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function allocateDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-payment-detail/create-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_FinancialPaymentDetail": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function editAllocation(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-payment-detail/update-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PaymentAllocation": idx            
            }
            
            callAjaxModalView(url,data);
        } 

        function deleteAllocation(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-payment-detail/delete-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PaymentAllocation": idx            
            }
            
            callAjaxModalView(url,data);
        }
        
        function approveAllocation(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-payment-detail/approve-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PaymentAllocation": idx            
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

                callAjaxModalView('{{ url('/fm-select-partner-fp') }}',data);                
            });

            // $( "#PaymentDate" ).datepicker({ dateFormat: 'yy-mm-dd' });

            $('#btn-add-detail').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialPaymentHeader: $("#IDX_T_FinancialPaymentHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-payment-detail/create') }}',data);            
            });

            $('#btn-approval').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialPaymentHeader: $("#IDX_T_FinancialPaymentHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-payment/approve') }}',data);            
            });

            $('#btn-reverse').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialPaymentHeader: $("#IDX_T_FinancialPaymentHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-payment/reverse') }}',data);            
            });

            $('#btn-validate').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialPaymentHeader: $("#IDX_T_FinancialPaymentHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-payment/validate') }}',data);            
            });

            $('#btn-void').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialPaymentHeader: $("#IDX_T_FinancialPaymentHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-payment/cancel') }}',data);            
            });

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialPaymentHeader: $("#IDX_T_FinancialPaymentHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-payment/duplicate') }}',data);            
            });

        });

    </script>

@endsection