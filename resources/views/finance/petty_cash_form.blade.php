@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-pc').addClass('mm-active');
@endsection

@section('action')
    @if($state !== 'create')

    <x-btn-action>

        @if($fields->PettyCashStatus == 'O')
        <a id="btn-close" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-lock"></i>
            </div>
            <span class="dropdown-content">Close Petty Cash</span>
        </a>
        @endif

        @if($fields->PettyCashStatus == 'C')
        <a id="btn-reopen" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-lock-open"></i>
            </div>
            <span class="dropdown-content">Reopen Petty Cash</span>
        </a>
        @endif

        <div class="dropdown-divider"></div>

        <a href="{{ url('fm-petty-cash/download-pdf').'/'.$fields->IDX_T_PettyCashHeader }}" id="btn-download-pdf"
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i>
            </div>
            <span class="dropdown-content">Print PDF</span>
        </a>
    </x-btn-action>
    @endif
@endsection

@section('additional_log')
    <div class="card mb-3">
        <div class="card-body">
            <h6>Petty Cash Status</h6>
            <hr>
            @if($fields->PettyCashStatus == 'O')
            <span class="badge badge-pill outline-badge-danger p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @else
            <span class="badge badge-pill outline-badge-info p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @endif
        </div>
    </div>
@endsection

@section('form-remark')
    Transaksi pengeluaran uang kas kecil (petty cash) dengan metode imprest. Saat ditutup (Close), total pengeluaran akan direimburse untuk mengembalikan saldo kas kecil ke jumlah tetap.
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_PettyCashHeader" name="IDX_T_PettyCashHeader" value="{{ $fields->IDX_T_PettyCashHeader }}"/>
    <input type="hidden" id="TransactionType" name="TransactionType" value="{{ $fields->TransactionType }}"/>

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->TransactionID . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="card border">
        <div class="card-header">
            <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
                <a class="nav-item nav-link active" id="card-general-tab" data-bs-toggle="tab" href="#card-general" aria-selected="false" role="tab" tabindex="-1">
                    <i class="fas fa-info"></i> General
                </a>
                @if($fields->IDX_T_PettyCashHeader <> 0)
                <a class="nav-item nav-link" id="card-detail-tab" data-bs-toggle="tab" href="#card-detail" aria-selected="false" role="tab" tabindex="-1">
                    <i class="fas fa-align-justify"></i> Detail Pengeluaran
                </a>
                <a class="nav-item nav-link" id="card-journal-tab" data-bs-toggle="tab" href="#card-journal" aria-selected="false" role="tab" tabindex="-1">
                    <i class="fas fa-coins"></i> Journal
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
                        <x-select-horizontal label="Akun Kas Kecil" id="IDX_M_FinancialAccount" :value="$fields->IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>
                        <x-textbox-horizontal label="Transaction ID (Auto)" id="TransactionID" :value="$fields->TransactionID" placeholder="(Auto)" class="readonly"/>
                        <x-textbox-horizontal label="Opening Date" id="OpeningDate" :value="$fields->OpeningDate" placeholder="Opening Date" class="required datepicker2" />
                        <x-textbox-horizontal label="Description" id="TransactionDesc" :value="$fields->TransactionDesc" placeholder="Description" class="required" />
                        <x-textbox-horizontal label="Total Pengeluaran" id="TotalAmount" :value="number_format($fields->TotalAmount, 0, '.', ',')" placeholder="0" class="readonly" />
                    </div>

                </div>

                @if($fields->IDX_T_PettyCashHeader <> 0)
                <div class="tab-pane fade" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">

                    @if($fields->PettyCashStatus == 'O')
                        <x-btn-add-detail id="btn-add-detail" label="Add Pengeluaran" />
                        <br><br>
                    @endif

                    <div id="table-pettycash-detail" class="table-responsive">
                        @include('finance.petty_cash_detail_list')
                    </div>
                </div>
                <div class="tab-pane fade" id="card-journal" role="tabpanel" aria-labelledby="#card-journal-tab">
                    <div id="table-pettycash-journal" class="table-responsive">
                        @include('finance.petty_cash_journal_list')
                    </div>
                </div>
                @endif
            </div>
        </div>
    </div>

    @if($fields->PettyCashStatus == 'O')
    <div class="row">
        <div class="col-12 mb-2">
            @include('form_helper.btn_save_header')
        </div>
    </div>
    @endif

@endsection

@section('script')

    <script>

        function deleteDetail(idx, item_description)
        {
            var url = "{{ url('fm-petty-cash-detail/delete') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PettyCashHeader": $("#IDX_T_PettyCashHeader").val(),
                "IDX_T_PettyCashDetail": idx,
                "DetailDesc": item_description
            }

            callAjaxModalView(url, data);
        }

        function editDetail(idx)
        {
            var url = "{{ url('fm-petty-cash-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PettyCashDetail": idx
            }

            callAjaxModalView(url, data);
        }

        $(document).ready(function(){

            $('#btn-add-detail').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PettyCashHeader: $("#IDX_T_PettyCashHeader").val(),
                }

                callAjaxModalView('{{ url('fm-petty-cash-detail/create') }}', data);
            });

            $('#btn-close').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PettyCashHeader: $("#IDX_T_PettyCashHeader").val(),
                }

                callAjaxModalView('{{ url('fm-petty-cash/close') }}', data);
            });

            $('#btn-reopen').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PettyCashHeader: $("#IDX_T_PettyCashHeader").val(),
                }

                callAjaxModalView('{{ url('fm-petty-cash/reopen') }}', data);
            });

        });

    </script>

@endsection
