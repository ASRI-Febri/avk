@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-so').addClass('mm-active');
@endsection

@section('form-remark')
    Transaksi penerimaan uang dengan metode pembayaran tunai atau non tunai
@endsection

@section('action')    
    
    @if($state !== 'create')
    <x-btn-action>
        
        @if($fields->ReceiveStatus == 'D')
        <a id="btn-approval" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i>
            </div>
            <span class="dropdown-content">Approval</span> 
        </a>
        @endif

        @if($fields->ReceiveStatus == 'A')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i>
            </div>
            <span class="dropdown-content">Reverse to Draft</span>
        </a>
        <a id="btn-void" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i>
            </div>
            <span class="dropdown-content">Void Transaction</span>
        </a>
        @endif

        <div class="dropdown-divider"></div>            
        <a href="{{ url('fm-financial-receive/download-pdf').'/'.$fields->IDX_T_FinancialReceiveHeader }}" id="btn-download2-pdf" 
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

@section('content-form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_FinancialReceiveHeader" name="IDX_T_FinancialReceiveHeader" value="{{ $fields->IDX_T_FinancialReceiveHeader }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_M_Currency" name="IDX_M_Currency" value="{{ $fields->IDX_M_Currency }}"/>
    <input type="hidden" id="IDX_M_PaymentType" name="IDX_M_PaymentType" value="{{ $fields->IDX_M_PaymentType }}"/>

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->ReceiveID . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
        <a class="nav-item nav-link active" id="card-general-tab" data-bs-toggle="tab" href="#card-general" aria-selected="false" role="tab" tabindex="-1">
            <i class="fas fa-align-justify"></i> General
        </a>
        @if($state <> 'create')
        <a class="nav-item nav-link" id="card-detail-tab" data-bs-toggle="tab" href="#card-detail" aria-selected="false" role="tab" tabindex="-1">
            <i class="fas fa-list"></i> Detail
        </a>
        <a class="nav-item nav-link" id="card-receive-tab" data-bs-toggle="tab" href="#card-receive" aria-selected="false" role="tab" tabindex="-1">
            <i class="fas fa-list"></i> Journal Receive
        </a>
        <a class="nav-item nav-link" id="card-allocation-tab" data-bs-toggle="tab" href="#card-allocation" aria-selected="false" role="tab" tabindex="-1">
            <i class="fas fa-list"></i> Journal Allocation
        </a>
        @endif
    </div>
    <div class="tab-content">
        
        <div class="tab-pane fade active show" id="card-general" role="tabpanel" aria-labelledby="#card-general-tab">
            <div class="d-grid gap-3">
                <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                <x-select-horizontal label="Profit Center" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                <x-select-horizontal label="Document Type" id="IDX_M_DocumentType" :value="$fields->IDX_M_DocumentType" class="required" :array="$dd_document_type"/>
                <x-select-horizontal label="Financial Account" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>
                <x-textbox-horizontal label="Receive ID (Auto)" id="ReceiveID" :value="$fields->ReceiveID" placeholder="(Auto)" class="readonly" />
                <x-textbox-horizontal label="Voucher No Manual" id="VoucherNoManual" :value="$fields->VoucherNoManual" placeholder="Voucher No Manual" class="required" />
                <x-textbox-horizontal label="Tgl Penerimaan" id="ReceiveDate" :value="$fields->ReceiveDate" placeholder="Receive Date" class="required datepicker2" />
                <x-textbox-horizontal label="Jumlah Penerimaan" id="ReceiveAmount" :value="$fields->ReceiveAmount" placeholder="Receive Amount" class="required auto" />
                <x-textbox-horizontal label="Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required" />
                    
                
                <x-lookup-horizontal label="Diterima Dari" id="PartnerDesc" :value="$fields->PartnerName" class="required" button="btn-find-partner"/>

                
                {{-- <x-select-horizontal label="Currency" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>
                <x-select-horizontal label="Payment Method" id="IDX_M_PaymentType" :value="$fields->IDX_M_PaymentType" class="required" :array="$dd_payment_method"/> --}}
                
            </div>
        </div>
        @if($state <> 'create')
        <div class="tab-pane fade" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">
            @if($fields->ReceiveStatus == 'D')
                <x-btn-add-detail id="btn-add-detail" label="Add New" />
                <br><br>
            @endif 

            <div id="table-receive-detail" class="table-responsive">
                @include('finance.financial_receive_detail_list')         
            </div>  
        </div>
        <div class="tab-pane fade" id="card-receive" role="tabpanel" aria-labelledby="#card-receive-tab">
            <div id="table-financialreceive-payment" class="table-responsive">
                @include('finance.financial_receive_payment_list')            
            </div>
        </div>
        <div class="tab-pane fade" id="card-allocation" role="tabpanel" aria-labelledby="#card-allocation-tab">
            <div id="table-salesinvoice-journal" class="table-responsive">
                @include('finance.financial_receive_journal_list')            
            </div>
        </div>
        @endif
    </div>

    @if($fields->ReceiveStatus == 'D')
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
            var url = "{{ url('fm-financial-receive-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_FinancialReceiveHeader": $("#IDX_T_FinancialReceiveHeader").val(),
                "IDX_T_FinancialReceiveDetail": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-receive-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_FinancialReceiveHeader": $("#IDX_T_FinancialReceiveHeader").val(),
                "IDX_T_FinancialReceiveDetail": idx            
            }
            
            callAjaxModalView(url,data);
        }
        
        function allocateDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-receive-detail/create-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_FinancialReceiveDetail": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function editAllocation(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-receive-detail/update-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_ReceiveAllocation": idx            
            }
            
            callAjaxModalView(url,data);
        } 

        function deleteAllocation(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-receive-detail/delete-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_ReceiveAllocation": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function approveAllocation(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('fm-financial-receive-detail/approve-allocation') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_ReceiveAllocation": idx            
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

                callAjaxModalView('{{ url('/fm-select-partner-fr') }}',data);                
            });

            // $( "#ReceiveDate" ).datepicker({ dateFormat: 'yy-mm-dd' });

            $('#btn-add-detail').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialReceiveHeader: $("#IDX_T_FinancialReceiveHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-receive-detail/create') }}',data);            
            });

            $('#btn-approval').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialReceiveHeader: $("#IDX_T_FinancialReceiveHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-receive/approve') }}',data);            
            });

            $('#btn-reverse').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialReceiveHeader: $("#IDX_T_FinancialReceiveHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-receive/reverse') }}',data);            
            });
            
            $('#btn-void').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialReceiveHeader: $("#IDX_T_FinancialReceiveHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-receive/cancel') }}',data);            
            });

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_FinancialReceiveHeader: $("#IDX_T_FinancialReceiveHeader").val(),
                }                

                callAjaxModalView('{{ url('fm-financial-receive/duplicate') }}',data);            
            });
        });

    </script>

@endsection