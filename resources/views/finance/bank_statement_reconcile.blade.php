@extends('layouts.master-without-nav')

@section('title')
    {{ $form_title }}
@endsection

@section('content')
<div id="div-form-modal" class="modal fade" tabindex="-1" role="dialog" data-bs-backdrop="static" data-keyboard="false" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content"></div>
    </div>
</div>
<input type="hidden" id="IDX_T_BankStatementHeader" value="{{ $fields->IDX_T_BankStatementHeader }}"/>
<style>
    .datepicker2 { z-index: 10000 !important; }
    .badge-bank-only { background-color: #f1734f; color: #fff; }
    .badge-ledger-only { background-color: #6f42c1; color: #fff; }
</style>
@php
    $labels = [
        'exact'       => ['Cocok', 'bg-success'],
        'date'        => ['Cocok, beda tanggal', 'bg-success'],
        'link'        => ['Dijurnal dari rekening koran', 'bg-info'],
        'adjusted'    => ['Disesuaikan', 'bg-success'],
        'combo'       => ['Cocok gabungan (periksa)', 'bg-warning text-dark'],
        'link_diff'   => ['Selisih nilai', 'bg-danger'],
        'bank_only'   => ['Hanya di bank', 'badge-bank-only'],
        'ledger_only' => ['Hanya di ledger', 'badge-ledger-only'],
    ];
    $review = ['combo', 'link_diff', 'bank_only', 'ledger_only'];
    $summary = $result['summary'];

    $bankClosing = $fields->OpeningBalance + $summary['bank_in'] - $summary['bank_out'];
    $ledgerClosing = $balance->OpeningBalance + $summary['ledger_in'] - $summary['ledger_out'];
    $rows = [
        'Saldo Awal'  => [$fields->OpeningBalance, $balance->OpeningBalance],
        'Uang Masuk'  => [$summary['bank_in'], $summary['ledger_in']],
        'Uang Keluar' => [$summary['bank_out'], $summary['ledger_out']],
        'Saldo Akhir' => [$bankClosing, $ledgerClosing],
    ];
    $money = function ($value) {
        return $value != 0 ? number_format($value, 2) : '';
    };
@endphp

<div class="container-fluid py-3 px-4 px-lg-5">

    <div class="d-flex justify-content-between align-items-start mb-3">
        <div>
            <h4 class="mb-1">Rekonsiliasi Rekening Koran dengan Ledger Bank</h4>
            <div class="text-muted">
                {{ $fields->StatementNo }} &middot; {{ $fields->FinancialAccount }} &middot; COA {{ $fields->BankCOA }} &middot;
                {{ date('d M Y', strtotime($fields->PeriodStart)) }} - {{ date('d M Y', strtotime($fields->PeriodEnd)) }}
            </div>
        </div>
        <div class="d-print-none">
            <button type="button" class="btn btn-secondary me-1" onclick="window.print()"><i class="fas fa-print me-1"></i> Print</button>
            <button type="button" class="btn btn-danger" onclick="window.close()"><i class="fas fa-times me-1"></i> Tutup</button>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-6 mb-3">
            <div class="card h-100">
                <div class="card-body">
                    <table class="table table-sm mb-0">
                        <thead>
                            <tr>
                                <th></th>
                                <th class="text-end">Rekening Koran</th>
                                <th class="text-end">Ledger</th>
                                <th class="text-end">Selisih</th>
                            </tr>
                        </thead>
                        <tbody>
                        @foreach($rows as $label => $values)
                            @php($difference = round($values[0] - $values[1], 2))
                            <tr class="{{ $label == 'Saldo Akhir' ? 'fw-bold' : '' }}">
                                <td>{{ $label }}</td>
                                <td class="text-end">{{ number_format($values[0], 2) }}</td>
                                <td class="text-end">{{ number_format($values[1], 2) }}</td>
                                <td class="text-end {{ $difference != 0 ? 'text-danger' : 'text-success' }}">{{ number_format($difference, 2) }}</td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                    <small class="text-muted d-block mt-2">
                        Saldo awal ledger dari jurnal Posted. Mutasi ledger mencakup semua jurnal aktif di periode ini
                        @if($balance->UnpostedNet != 0)
                            , termasuk jurnal <b>Unposted</b> bernilai bersih {{ number_format($balance->UnpostedNet, 2) }}
                        @endif
                        .
                    </small>
                </div>
            </div>
        </div>
        <div class="col-lg-6 mb-3">
            <div class="card h-100">
                <div class="card-body">
                    <table class="table table-sm mb-2">
                        <tbody>
                        @foreach($labels as $type => $label)
                            <tr>
                                <td><span class="badge {{ $label[1] }}">{{ $label[0] }}</span></td>
                                <td class="text-end">{{ $summary['counts'][$type] ?? 0 }}</td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                    <small class="text-muted">
                        Pencocokan berdasarkan nominal dan arah (uang masuk = debit COA bank), selisih tanggal maks.
                        {{ \App\Services\BankStatement\LedgerReconciler::MAX_DAYS }} hari. "Cocok gabungan" = satu transaksi
                        sama dengan jumlah 2-3 transaksi di sisi lain pada tanggal yang sama; bisa kebetulan, mohon diperiksa.
                    </small>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header d-print-none d-flex justify-content-between align-items-center">
            <div class="btn-group" role="group">
                <button type="button" class="btn btn-outline-secondary btn-filter" data-filter="all">Semua ({{ count($result['groups']) }})</button>
                <button type="button" class="btn btn-outline-secondary btn-filter active" data-filter="review">
                    Perlu Dicek ({{ count(array_filter($result['groups'], function ($g) use ($review) { return in_array($g['type'], $review); })) }})
                </button>
                <button type="button" class="btn btn-outline-secondary btn-filter" data-filter="match">Cocok</button>
            </div>
            @if($can_journal)
            <button type="button" id="btn-adjustment" class="btn btn-primary">
                <i class="fas fa-coins me-1"></i> Jurnal Penyesuaian (<span id="selected-count">0</span> transaksi)
            </button>
            @endif
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-sm table-bordered mb-0" id="table-reconcile">
                    <thead class="table-light">
                        <tr>
                            @if($can_journal)
                            <th rowspan="2" class="text-center d-print-none"><input type="checkbox" class="form-check-input" id="chk-all"/></th>
                            @endif
                            <th rowspan="2">Status</th>
                            <th colspan="4" class="text-center">Rekening Koran</th>
                            <th colspan="5" class="text-center">Ledger</th>
                            <th rowspan="2" class="text-end">Selisih</th>
                        </tr>
                        <tr>
                            <th>Tanggal</th>
                            <th>Keterangan</th>
                            <th class="text-end">Masuk</th>
                            <th class="text-end">Keluar</th>
                            <th>Tanggal</th>
                            <th>Voucher</th>
                            <th>Keterangan</th>
                            <th class="text-end">Masuk</th>
                            <th class="text-end">Keluar</th>
                        </tr>
                    </thead>
                    <tbody>
                    @foreach($result['groups'] as $group)
                        <tr class="row-{{ in_array($group['type'], $review) ? 'review' : 'match' }}">
                            @if($can_journal)
                            <td class="text-center d-print-none">
                                @if(!$group['adjustment'])
                                <input type="checkbox" class="form-check-input chk-row"
                                       data-bank="{{ implode(',', array_column($group['bank'], 'id')) }}"
                                       data-ledger="{{ implode(',', array_column($group['ledger'], 'id')) }}"/>
                                @endif
                            </td>
                            @endif
                            <td><span class="badge {{ $labels[$group['type']][1] }}">{{ $labels[$group['type']][0] }}</span></td>
                            <td class="text-nowrap">
                                @foreach($group['bank'] as $row)<div>{{ date('d/m H:i', strtotime($row['datetime'])) }}</div>@endforeach
                            </td>
                            <td>
                                @foreach($group['bank'] as $row)<div><small>{{ $row['remark'] }}</small></div>@endforeach
                            </td>
                            <td class="text-end">
                                @foreach($group['bank'] as $row)<div>{{ $money($row['in']) }}&nbsp;</div>@endforeach
                            </td>
                            <td class="text-end">
                                @foreach($group['bank'] as $row)<div>{{ $money($row['out']) }}&nbsp;</div>@endforeach
                            </td>
                            <td class="text-nowrap">
                                @foreach($group['ledger'] as $line)<div>{{ date('d/m', strtotime($line['date'])) }}</div>@endforeach
                            </td>
                            <td class="text-nowrap">
                                @foreach($group['ledger'] as $line)
                                    <div>
                                        <a href="{{ url('ac-journal/update/'.$line['journal_id']) }}" target="_blank">{{ $line['voucher'] }}</a>
                                        @if($line['journal_id'] == $group['adjustment'])<span class="badge bg-success">Penyesuaian</span>@endif
                                        @if(!$line['posted'])<span class="badge bg-secondary">Unposted</span>@endif
                                        @if(!$line['in_period'])<span class="badge bg-secondary">Luar periode</span>@endif
                                    </div>
                                @endforeach
                            </td>
                            <td>
                                @foreach($group['ledger'] as $line)<div><small>{{ $line['remark'] }}</small></div>@endforeach
                            </td>
                            <td class="text-end">
                                @foreach($group['ledger'] as $line)<div>{{ $money($line['in']) }}&nbsp;</div>@endforeach
                            </td>
                            <td class="text-end">
                                @foreach($group['ledger'] as $line)<div>{{ $money($line['out']) }}&nbsp;</div>@endforeach
                            </td>
                            <td class="text-end {{ $group['difference'] != 0 ? 'text-danger fw-bold' : '' }}">{{ $money($group['difference']) }}</td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection

@section('script')
    <script src="{{ URL::asset('public/js/save.js') }}"></script>
    <script src="{{ URL::asset('public/js/router.js') }}"></script>
    <script>
        $(document).ready(function () {
            function selectedIds(side)
            {
                var ids = [];
                $('.chk-row:checked').each(function () {
                    var value = String($(this).data(side));
                    if (value !== '') {
                        ids = ids.concat(value.split(','));
                    }
                });
                return ids;
            }

            function refreshSelected()
            {
                $('#selected-count').text(selectedIds('bank').length + selectedIds('ledger').length);
            }

            function applyFilter(filter)
            {
                $('#table-reconcile tbody tr').each(function () {
                    var show = filter == 'all' || $(this).hasClass('row-' + filter);
                    $(this).toggle(show);
                    if (!show) {
                        $(this).find('.chk-row').prop('checked', false);
                    }
                });
                $('#chk-all').prop('checked', false);
                refreshSelected();
            }

            $('#chk-all').change(function () {
                $('#table-reconcile tbody tr:visible .chk-row').prop('checked', this.checked);
                refreshSelected();
            });

            $('.chk-row').change(refreshSelected);

            $('#btn-adjustment').click(function () {
                var bank = selectedIds('bank'), ledger = selectedIds('ledger');
                if (bank.length + ledger.length == 0) {
                    Swal.fire({ icon: 'warning', title: 'Belum ada transaksi dipilih', text: 'Centang transaksi yang akan dibuatkan jurnal penyesuaian.' });
                    return;
                }
                callAjaxModalView('{{ url('fm-bank-statement/adjustment') }}', {
                    _token: $('#_token').val(),
                    IDX_T_BankStatementHeader: $('#IDX_T_BankStatementHeader').val(),
                    bank: bank,
                    ledger: ledger
                });
            });

            $('.btn-filter').click(function () {
                $('.btn-filter').removeClass('active');
                $(this).addClass('active');
                applyFilter($(this).data('filter'));
            });

            applyFilter('review');
        });
    </script>
@endsection
