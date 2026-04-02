@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-fp').addClass('mm-active');
@endsection

@section('action')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')
        
    {{-- <x-btn-create-new label="Create New" :url="$url_create" /> --}}

    <x-btn-action>
        
        @if($fields->PaymentStatus == 'D')
        <a id="btn-approval" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i> 
            </div>
            <span class="dropdown-content">Approval</span>            
        </a>
        @endif

        @if($fields->PaymentStatus == 'A')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i> 
            </div>
            <span class="dropdown-content">Reverse to Draft</span> 
        </a>
        @endif

        {{-- @if($fields->PaymentStatus == 'F')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#"><i class="fas fa-undo"></i> Reverse Approval</a>
        <a id="btn-void" class="dropdown-item" href="#"><i class="fas fa-undo"></i> Void Transaction</a>
        @endif --}}

        <div class="dropdown-divider"></div>   

        <a href="{{ url('fm-financial-payment/download-pdf').'/'.$fields->IDX_T_FinancialPaymentHeader }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i> 
            </div>
            <span class="dropdown-content">Print PDF</span>
        </a>       
        
        <a id="btn-duplicate-header" class="dropdown-item text-primary" href="#" title="Duplicate this data">
            <div class="dropdown-icon">
                <i class="fas fa-copy"></i> 
            </div>
            <span class="dropdown-content">Duplicate</span>
        </a>
    </x-btn-action> 
    @endif
@endsection

@section('additional_log')
    <div class="card mb-3">
        <div class="card-body">
            <h6>Payment Status</h6>
            <hr>
            @if($fields->PaymentStatus == 'D' || $fields->PaymentStatus == 'A')
            <span class="badge badge-pill outline-badge-danger p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @else 
            <span class="badge badge-pill outline-badge-info p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @endif
        </div>
    </div>
@endsection

@section('form-remark')
    Transaki pengeluaran uang untuk pembayaran kepada vendor atau pihak lain. Transaksi ini akan menghasilkan jurnal pengeluaran uang dan mengurangi saldo kas/bank.
@endsection

@section('content-form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_FinancialPaymentHeader" name="IDX_T_FinancialPaymentHeader" value="{{ $fields->IDX_T_FinancialPaymentHeader }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_M_Currency" name="IDX_M_Currency" value="{{ $fields->IDX_M_Currency }}"/>
    <input type="hidden" id="IDX_M_PaymentType" name="IDX_M_PaymentType" value="{{ $fields->IDX_M_PaymentType }}"/>
    <input type="hidden" id="PDCNo" name="PDCNo" value="{{ $fields->PDCNo }}"/>

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->PaymentID . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="card border">
        <div class="card-header">      
            <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
                <a class="nav-item nav-link active" id="card-general-tab" data-bs-toggle="tab" href="#card-general" aria-selected="false" role="tab" tabindex="-1">
                    <i class="fas fa-info"></i> General
                </a>
                @if($fields->IDX_T_FinancialPaymentHeader <> 0)
                <a class="nav-item nav-link" id="card-detail-tab" data-bs-toggle="tab" href="#card-detail" aria-selected="false" role="tab" tabindex="-1">
                    <i class="fas fa-align-justify"></i> Detail Pembayaran
                </a>    
                <a class="nav-item nav-link" id="card-journal-payment-tab" data-bs-toggle="tab" href="#card-journal-payment" aria-selected="true" role="tab">
                    <i class="fas fa-coins"></i> Journal Payment
                </a> 
                <a class="nav-item nav-link" id="card-journal-allocation-tab" data-bs-toggle="tab" href="#card-journal-allocation" aria-selected="true" role="tab">
                    <i class="fas fa-file"></i> Journal Allocation
                </a>
                <a class="nav-item nav-link" id="card-log-tab" data-bs-toggle="tab" href="#card-log" aria-selected="true" role="tab">
                    <i class="fas fa-list"></i> Log
                </a>    
                @endif     
            </div>
        </div>
        <div class="card-body">
            <div class="tab-content">
                <div class="tab-pane fade active show" id="card-general" role="tabpanel" aria-labelledby="#card-general-tab">                        
                    
                    <div class="d-grid gap-3">
                        
                        <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                        <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                        <x-select-horizontal label="Document Type" id="IDX_M_DocumentType" :value="$fields->IDX_M_DocumentType" class="required" :array="$dd_document_type"/>
                        <x-textbox-horizontal label="Payment ID (Auto)" id="PaymentID" :value="$fields->PaymentID" placeholder="(Auto)" class="readonly"/>
                        <x-select-horizontal label="Financial Account" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>

                        <x-textbox-horizontal label="Voucher No Manual" id="VoucherNoManual" :value="$fields->VoucherNoManual" placeholder="Voucher No Manual" class="required" />
                        <x-textbox-horizontal label="Payment Date" id="PaymentDate" :value="$fields->PaymentDate" placeholder="Payment Date" class="required datepicker2" />
                        <x-textbox-horizontal label="Payment Amount" id="PaymentAmount" :value="$fields->PaymentAmount" placeholder="Payment Amount" class="required auto" />
                        <x-textbox-horizontal label="Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required" />
                        
                        <x-lookup-horizontal label="Dibayarkan ke" id="PartnerDesc" :value="$fields->PartnerName" class="required" button="btn-find-partner"/>
                        <x-textbox-horizontal label="Destination Account Name" id="DestinationAccountName" :value="$fields->DestinationAccountName" placeholder="Destination Account Name" class="required" />
                        <x-textbox-horizontal label="Destination Bank" id="DestinationBank" :value="$fields->DestinationBank" placeholder="Destination Bank" class="required" />
                        <x-textbox-horizontal label="Destination Account No" id="DestinationAccountNo" :value="$fields->DestinationAccountNo" placeholder="Destination Account No" class="required" />


                        {{-- <legend><h6 class="text-muted font-weight-bold">Financial Info</h6></legend>
                        <x-select-horizontal label="Currency" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>
                        <x-select-horizontal label="Payment Method" id="IDX_M_PaymentType" :value="$fields->IDX_M_PaymentType" class="required" :array="$dd_payment_method"/>
                        <x-textbox-horizontal label="No Giro" id="PDCNo" :value="$fields->PDCNo" placeholder="No Giro" class="required" /> --}}
                    </div>

                </div>

                @if($fields->IDX_T_FinancialPaymentHeader <> 0)
                <div class="tab-pane fade" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">
                    
                    @if($fields->PaymentStatus == 'D')
                        <x-btn-add-detail id="btn-add-detail" label="Add Detail COA" />
                        <br><br>
                    @endif
                
                    <div id="table-financialpayment-detail" class="table-responsive">
                        @include('finance.financial_payment_detail_list')            
                    </div>
                </div>
                <div class="tab-pane fade" id="card-journal-payment" role="tabpanel" aria-labelledby="#card-journal-payment-tab">
                    <div id="table-financialpayment-payment" class="table-responsive">
                        @include('finance.financial_payment_payment_list')            
                    </div>
                </div>
                <div class="tab-pane fade" id="card-journal-allocation" role="tabpanel" aria-labelledby="#card-journal-allocation-tab">
                    <div id="table-financialpayment-journal" class="table-responsive">
                        @include('finance.financial_payment_journal_list')            
                    </div>
                </div>
                <div class="tab-pane fade" id="card-log" role="tabpanel" aria-labelledby="#card-log-tab">
                    <div id="table-financialpayment-log" class="table-responsive">
                        {{-- @include('finance.financial_payment_log_list')             --}}
                    </div>
                </div>
                @endif
            </div>
        </div>
    </div>
    
    @if($fields->PaymentStatus == 'D')
    <div class="row"> 
        <div class="col-12 mb-2">           
            @include('form_helper.btn_save_header')
        </div>
    </div>
    @endif

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