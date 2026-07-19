@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-it').addClass('mm-active');
@endsection

@section('form-remark')
    Transfer dana antar financial account (setoran tunai / tarik tunai)
@endsection

@section('action')

    @if($state !== 'create')
    <x-btn-action>

        @if($fields->TransferStatus == 'D')
        <a id="btn-approval" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i>
            </div>
            <span class="dropdown-content">Approval</span>
        </a>
        @endif

        @if($fields->TransferStatus == 'A')
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
        <a href="{{ url('fm-internal-transfer/download-pdf').'/'.$fields->IDX_T_InternalTransferHeader }}" id="btn-download2-pdf"
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i>
            </div>
            <span class="dropdown-content">Print PDF</span>
        </a>
    </x-btn-action>
    @endif
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_InternalTransferHeader" name="IDX_T_InternalTransferHeader" value="{{ $fields->IDX_T_InternalTransferHeader }}"/>

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->TransferID . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
        <a class="nav-item nav-link active" id="card-general-tab" data-bs-toggle="tab" href="#card-general" aria-selected="false" role="tab" tabindex="-1">
            <i class="fas fa-align-justify"></i> General
        </a>
        @if($state <> 'create')
        <a class="nav-item nav-link" id="card-journal-tab" data-bs-toggle="tab" href="#card-journal" aria-selected="false" role="tab" tabindex="-1">
            <i class="fas fa-list"></i> Journal
        </a>
        @endif
    </div>
    <div class="tab-content">

        <div class="tab-pane fade active show" id="card-general" role="tabpanel" aria-labelledby="#card-general-tab">
            <div class="d-grid gap-3">
                <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                <x-select-horizontal label="Profit Center" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                <x-select-horizontal label="Document Type" id="IDX_M_DocumentType" :value="$fields->IDX_M_DocumentType" class="required" :array="$dd_document_type"/>
                <x-select-horizontal label="Dari Financial Account" id="IDX_M_FromFinancialAccount" :value="$fields->IDX_M_FromFinancialAccount" class="required" :array="$dd_financial_account"/>
                <x-select-horizontal label="Ke Financial Account" id="IDX_M_ToFinancialAccount" :value="$fields->IDX_M_ToFinancialAccount" class="required" :array="$dd_financial_account"/>
                <x-textbox-horizontal label="Transfer ID (Auto)" id="TransferID" :value="$fields->TransferID" placeholder="(Auto)" class="readonly" />
                <x-textbox-horizontal label="Voucher No Manual" id="VoucherNoManual" :value="$fields->VoucherNoManual" placeholder="Voucher No Manual" class="required" />
                <x-textbox-horizontal label="Tgl Transfer" id="TransferDate" :value="$fields->TransferDate" placeholder="Transfer Date" class="required datepicker2" />
                <x-textbox-horizontal label="Jumlah Transfer" id="TransferAmount" :value="$fields->TransferAmount" placeholder="Transfer Amount" class="required auto" />
                <x-textbox-horizontal label="Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required" />
            </div>
        </div>
        @if($state <> 'create')
        <div class="tab-pane fade" id="card-journal" role="tabpanel" aria-labelledby="#card-journal-tab">
            <div id="table-internaltransfer-journal" class="table-responsive">
                @include('finance.internal_transfer_journal_list')
            </div>
        </div>
        @endif
    </div>

    @if($fields->TransferStatus == 'D')
    <div class="row">
        <div class="col-12 mb-2">
            @include('form_helper.btn_save_header')
        </div>
    </div>
    @endif

@endsection

@section('script')

    <script>

        $(document).ready(function(){

            $('#btn-approval').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_InternalTransferHeader: $("#IDX_T_InternalTransferHeader").val(),
                }

                callAjaxModalView('{{ url('fm-internal-transfer/approve') }}',data);
            });

            $('#btn-reverse').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_InternalTransferHeader: $("#IDX_T_InternalTransferHeader").val(),
                }

                callAjaxModalView('{{ url('fm-internal-transfer/reverse') }}',data);
            });

            $('#btn-void').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_InternalTransferHeader: $("#IDX_T_InternalTransferHeader").val(),
                }

                callAjaxModalView('{{ url('fm-internal-transfer/void') }}',data);
            });
        });

    </script>

@endsection
