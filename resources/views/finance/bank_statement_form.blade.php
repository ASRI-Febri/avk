@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-bs').addClass('mm-active');
@endsection

@section('content')

    <input type="hidden" id="IDX_T_BankStatementHeader" value="{{ $fields->IDX_T_BankStatementHeader }}"/>

    @if($message)
    <div class="alert alert-success">{{ $message }}</div>
    @endif

    <div class="card">
        <div class="card-header card-header-bordered">
            <h3 class="card-title">{{ $fields->StatementNo }}</h3>
            <div class="card-addon">
                <a href="{{ url('fm-bank-statement/download/'.$fields->IDX_T_BankStatementHeader) }}" target="_blank" class="btn btn-info me-1">
                    <i class="fa fa-file-pdf me-1"></i> PDF Asli
                </a>
                @if($can_delete)
                <button type="button" id="btn-delete" class="btn btn-danger me-1">
                    <i class="fas fa-trash me-1"></i> Hapus
                </button>
                @endif
                <a href="{{ $url_cancel }}" class="btn btn-secondary">
                    <i class="fas fa-arrow-left me-1"></i> Kembali
                </a>
            </div>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <table class="table table-sm table-borderless mb-0">
                        <tr><td class="text-secondary" width="40%">Financial Account</td><td>{{ $fields->FinancialAccount }}</td></tr>
                        <tr><td class="text-secondary">COA Bank</td><td>{{ $fields->BankCOA }}</td></tr>
                        <tr><td class="text-secondary">No / Nama Rekening</td><td>{{ $fields->AccountNo }} / {{ $fields->AccountName }}</td></tr>
                        <tr><td class="text-secondary">Periode</td>
                            <td>{{ date('d M Y', strtotime($fields->PeriodStart)) }} - {{ date('d M Y', strtotime($fields->PeriodEnd)) }}</td></tr>
                        @if($fields->Notes)
                        <tr><td class="text-secondary">Catatan</td><td>{{ $fields->Notes }}</td></tr>
                        @endif
                    </table>
                </div>
                <div class="col-md-6">
                    <table class="table table-sm table-borderless mb-0">
                        <tr><td class="text-secondary" width="40%">Saldo Awal</td><td class="text-end">{{ number_format($fields->OpeningBalance, 2) }}</td></tr>
                        <tr><td class="text-secondary">Total Debit</td><td class="text-end">{{ number_format($fields->TotalDebit, 2) }}</td></tr>
                        <tr><td class="text-secondary">Total Kredit</td><td class="text-end">{{ number_format($fields->TotalCredit, 2) }}</td></tr>
                        <tr><td class="text-secondary">Saldo Akhir</td><td class="text-end">{{ number_format($fields->ClosingBalance, 2) }}</td></tr>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header card-header-bordered">
            <div class="btn-group" role="group">
                <button type="button" class="btn btn-outline-secondary btn-filter active" data-filter="all">Semua</button>
                <button type="button" class="btn btn-outline-secondary btn-filter" data-filter="open">Belum Dijurnal</button>
                <button type="button" class="btn btn-outline-secondary btn-filter" data-filter="admin">Biaya Admin</button>
            </div>
            @if($can_journal)
            <div class="card-addon">
                <button type="button" id="btn-journal" class="btn btn-primary me-1">
                    <i class="fas fa-coins me-1"></i> Buat Jurnal (<span id="selected-count">0</span> baris)
                </button>
                <button type="button" id="btn-admin-fee" class="btn btn-success me-1" {{ $fields->AdminFeeCount > 0 ? '' : 'disabled' }}>
                    <i class="fas fa-calculator me-1"></i> Jurnal Biaya Admin
                    ({{ $fields->AdminFeeCount }} baris, {{ number_format($fields->AdminFeeAmount, 0) }})
                </button>
                <button type="button" id="btn-month-end" class="btn btn-info" {{ $month_end_count > 0 ? '' : 'disabled' }}>
                    <i class="fas fa-calendar-check me-1"></i> Jurnal Akhir Bulan ({{ $month_end_count }} baris)
                </button>
            </div>
            @endif
        </div>
        <div class="card-body">
            <div class="table-responsive" style="max-height: 700px;">
                <table class="table table-sm table-bordered table-hover" id="table-statement">
                    <thead class="table-light" style="position: sticky; top: 0; z-index: 1;">
                        <tr>
                            <th class="text-center">
                                @if($can_journal)<input type="checkbox" class="form-check-input" id="chk-all"/>@endif
                            </th>
                            <th>No</th>
                            <th>Tanggal</th>
                            <th>Keterangan</th>
                            <th>Reference No</th>
                            <th class="text-end">Debit</th>
                            <th class="text-end">Kredit</th>
                            <th class="text-end">Saldo</th>
                            <th class="text-center">Biaya Admin</th>
                            <th>Jurnal</th>
                        </tr>
                    </thead>
                    <tbody>
                    @foreach($records_detail as $row)
                        <tr data-journal="{{ $row->IDX_T_JournalHeader ? 1 : 0 }}" data-admin="{{ $row->IsAdminFee ? 1 : 0 }}">
                            <td class="text-center">
                                @if($can_journal && !$row->IDX_T_JournalHeader)
                                <input type="checkbox" class="form-check-input chk-row" value="{{ $row->IDX_T_BankStatementDetail }}"/>
                                @endif
                            </td>
                            <td>{{ $row->SeqNo }}</td>
                            <td class="text-nowrap">{{ date('d/m/Y H:i', strtotime($row->PostingDate)) }}</td>
                            <td><small>{{ $row->Remark }}</small></td>
                            <td><small>{{ $row->ReferenceNo }}</small></td>
                            <td class="text-end">{{ $row->DebitAmount > 0 ? number_format($row->DebitAmount, 2) : '' }}</td>
                            <td class="text-end">{{ $row->CreditAmount > 0 ? number_format($row->CreditAmount, 2) : '' }}</td>
                            <td class="text-end">{{ number_format($row->Balance, 2) }}</td>
                            <td class="text-center">
                                @if($row->DebitAmount > 0)
                                <input type="checkbox" class="form-check-input chk-admin-fee" value="{{ $row->IDX_T_BankStatementDetail }}"
                                       {{ $row->IsAdminFee ? 'checked' : '' }} {{ $can_journal && !$row->IDX_T_JournalHeader ? '' : 'disabled' }}/>
                                @endif
                            </td>
                            <td class="text-nowrap">
                                @if($row->IDX_T_JournalHeader)
                                <a href="{{ url('ac-journal/update/'.$row->IDX_T_JournalHeader) }}" target="_blank">{{ $row->VoucherNo }}</a>
                                @if($row->PostingStatus == 'P')
                                    <span class="badge bg-success">Posted</span>
                                @else
                                    <span class="badge bg-secondary">Unposted</span>
                                @endif
                                @endif
                            </td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function () {

            var scroll = sessionStorage.getItem('bank-statement-scroll');
            if (scroll !== null) {
                sessionStorage.removeItem('bank-statement-scroll');
                window.scrollTo(0, parseInt(scroll));
            }

            var header = { _token: $('#_token').val(), IDX_T_BankStatementHeader: $('#IDX_T_BankStatementHeader').val() };

            function selectedRows()
            {
                return $('.chk-row:checked').map(function () { return $(this).val(); }).get();
            }

            function refreshSelected()
            {
                $('#selected-count').text(selectedRows().length);
            }

            $('.btn-filter').click(function () {
                var filter = $(this).data('filter');
                $('.btn-filter').removeClass('active');
                $(this).addClass('active');

                $('#table-statement tbody tr').each(function () {
                    var row = $(this);
                    var show = filter == 'all'
                        || (filter == 'open' && row.data('journal') == 0)
                        || (filter == 'admin' && row.data('admin') == 1);
                    row.toggle(show);
                    if (!show) {
                        row.find('.chk-row').prop('checked', false);
                    }
                });
                refreshSelected();
            });

            $('#chk-all').change(function () {
                $('#table-statement tbody tr:visible .chk-row').prop('checked', this.checked);
                refreshSelected();
            });

            $('.chk-row').change(refreshSelected);

            $('#btn-journal').click(function () {
                var rows = selectedRows();
                if (rows.length == 0) {
                    Swal.fire({ icon: 'warning', title: 'Belum ada baris dipilih', text: 'Centang baris rekening koran yang akan dijurnal.' });
                    return;
                }
                callAjaxModalView('{{ url('fm-bank-statement/journal') }}', $.extend({ IDX_T_BankStatementDetail: rows }, header));
            });

            $('#btn-admin-fee').click(function () {
                callAjaxModalView('{{ url('fm-bank-statement/admin-fee') }}', header);
            });

            $('#btn-month-end').click(function () {
                callAjaxModalView('{{ url('fm-bank-statement/month-end') }}', header);
            });

            $('.chk-admin-fee').change(function () {
                var checkbox = $(this);
                $.post('{{ url('fm-bank-statement/set-admin-fee') }}', {
                    _token: header._token,
                    IDX_T_BankStatementDetail: checkbox.val(),
                    IsAdminFee: checkbox.is(':checked') ? 1 : 0
                }, function (data) {
                    if (data.flag == 'success') {
                        sessionStorage.setItem('bank-statement-scroll', window.scrollY);
                        window.location.reload();
                    } else {
                        checkbox.prop('checked', !checkbox.is(':checked'));
                        Swal.fire({ icon: 'error', title: 'Gagal', html: data.message });
                    }
                }, 'json');
            });

            $('#btn-delete').click(function () {
                Swal.fire({
                    icon: 'warning',
                    title: 'Hapus rekening koran?',
                    text: 'Rekening koran {{ $fields->StatementNo }} beserta seluruh barisnya akan dihapus.',
                    showCancelButton: true,
                    confirmButtonText: 'Hapus',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (!result.value) {
                        return;
                    }
                    $.post('{{ url('fm-bank-statement/delete') }}', header, function (data) {
                        if (data.flag == 'success') {
                            window.location.href = data.url;
                        } else {
                            Swal.fire({ icon: 'error', title: 'Gagal', html: data.message });
                        }
                    }, 'json');
                });
            });
        });
    </script>
@endsection
