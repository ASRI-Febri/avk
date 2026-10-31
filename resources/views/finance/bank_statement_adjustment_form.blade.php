@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Buat Jurnal Penyesuaian" :url="$url_save_modal"/>
@endsection

@section('modal-content')

    <input type="hidden" name="IDX_T_BankStatementHeader" value="{{ $fields->IDX_T_BankStatementHeader }}"/>

    @if(count($records_bank) + count($records_ledger) == 0)
        <div class="alert alert-label-warning text-dark mb-0">Transaksi yang dipilih tidak ditemukan.</div>
    @else
        @foreach($records_bank as $row)
            <input type="hidden" name="bank[]" value="{{ $row->IDX_T_BankStatementDetail }}"/>
        @endforeach
        @foreach($records_ledger as $row)
            <input type="hidden" name="ledger[]" value="{{ $row->IDX_T_JournalDetail }}"/>
        @endforeach

        <div class="alert alert-label-info">
            Journal Memorial berstatus Unposted. Baris COA bank <b>{{ $fields->BankCOA }}</b> dihitung otomatis
            sebagai penyeimbang baris lawan yang diisi di bawah. Setelah dibuat, transaksi terpilih dan jurnal ini
            tampil sebagai satu kelompok <b>Disesuaikan</b> di halaman rekonsiliasi.
        </div>

        <table class="table table-sm table-bordered mb-3">
            <thead class="table-light">
                <tr>
                    <th>Sumber</th>
                    <th>Tanggal</th>
                    <th>Keterangan</th>
                    <th class="text-end">Masuk</th>
                    <th class="text-end">Keluar</th>
                </tr>
            </thead>
            <tbody>
            @foreach($records_bank as $row)
                <tr>
                    <td><span class="badge" style="background-color: #f1734f; color: #fff;">Bank</span></td>
                    <td class="text-nowrap">{{ date('d/m/Y H:i', strtotime($row->PostingDate)) }}</td>
                    <td><small>{{ $row->Remark }}</small></td>
                    <td class="text-end">{{ $row->CreditAmount > 0 ? number_format($row->CreditAmount, 2) : '' }}</td>
                    <td class="text-end">{{ $row->DebitAmount > 0 ? number_format($row->DebitAmount, 2) : '' }}</td>
                </tr>
            @endforeach
            @foreach($records_ledger as $row)
                <tr>
                    <td><span class="badge" style="background-color: #6f42c1; color: #fff;">Ledger</span></td>
                    <td class="text-nowrap">{{ date('d/m/Y', strtotime($row->JournalDate)) }}</td>
                    <td><small><b>{{ $row->VoucherNo }}</b> {{ $row->Remark }}</small></td>
                    <td class="text-end">{{ $row->BDebetAmount > 0 ? number_format($row->BDebetAmount, 2) : '' }}</td>
                    <td class="text-end">{{ $row->BCreditAmount > 0 ? number_format($row->BCreditAmount, 2) : '' }}</td>
                </tr>
            @endforeach
                <tr class="fw-bold">
                    <td colspan="3" class="text-end">Selisih (Bank - Ledger)</td>
                    <td colspan="2" class="text-end {{ $fields->Difference != 0 ? 'text-danger' : 'text-success' }}">
                        {{ number_format($fields->Difference, 2) }}
                    </td>
                </tr>
            </tbody>
        </table>

        <div class="d-grid gap-3 mb-3">
            <x-textbox-horizontal label="Tanggal Jurnal" id="JournalDate" :value="$fields->JournalDate" placeholder="yyyy-mm-dd" class="datepicker2" />
            <x-textbox-horizontal label="Keterangan" id="JournalRemark" :value="$fields->JournalRemark" placeholder="Keterangan jurnal" class="" />
        </div>

        <table class="table table-sm table-bordered mb-1" id="table-adjustment-lines">
            <thead class="table-light">
                <tr>
                    <th width="38%">Chart of Account</th>
                    <th width="12%">Posisi</th>
                    <th width="18%" class="text-end">Nilai</th>
                    <th>Keterangan Baris</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <tr class="table-light">
                    <td>{{ $fields->BankCOA }} <small class="text-muted">(otomatis)</small></td>
                    <td id="bank-side"></td>
                    <td class="text-end" id="bank-amount"></td>
                    <td></td>
                    <td></td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="5">
                        <button type="button" class="btn btn-sm btn-outline-primary" id="btn-add-line">
                            <i class="fas fa-plus me-1"></i> Tambah Baris
                        </button>
                        <span class="float-end">
                            Sisa selisih setelah jurnal: <b id="remaining"></b>
                        </span>
                    </td>
                </tr>
            </tfoot>
        </table>
    @endif

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#div-form-modal .modal-dialog').addClass('modal-xl');

            var difference = {{ (float) $fields->Difference }};
            var lineIndex = 0;

            function number(value)
            {
                return parseFloat(String(value).replace(/,/g, '')) || 0;
            }

            function format(value)
            {
                return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }

            function refreshBank()
            {
                var bank = 0;
                $('#table-adjustment-lines .line-row').each(function () {
                    var amount = number($(this).find('.line-amount').val());
                    bank += $(this).find('.line-side').val() == 'C' ? amount : -amount;
                });
                bank = Math.round(bank * 100) / 100;

                $('#bank-side').text(bank > 0 ? 'Debit' : (bank < 0 ? 'Kredit' : '-'));
                $('#bank-amount').text(bank != 0 ? format(Math.abs(bank)) : '');

                var remaining = Math.round((difference - bank) * 100) / 100;
                $('#remaining').text(format(remaining)).toggleClass('text-danger', remaining != 0).toggleClass('text-success', remaining == 0);
            }

            function addLine(side, amount)
            {
                var i = lineIndex++;
                var row = $('<tr class="line-row">'
                    + '<td><select name="lines[' + i + '][coa]" class="coa-select"></select></td>'
                    + '<td><select name="lines[' + i + '][side]" class="form-select form-select-sm line-side">'
                    + '<option value="D">Debit</option><option value="C">Kredit</option></select></td>'
                    + '<td><input type="text" name="lines[' + i + '][amount]" class="form-control form-control-sm text-end line-amount"/></td>'
                    + '<td><input type="text" name="lines[' + i + '][remark]" class="form-control form-control-sm" placeholder="(ikut keterangan jurnal)"/></td>'
                    + '<td><button type="button" class="btn btn-sm btn-outline-danger btn-remove-line"><i class="fas fa-times"></i></button></td>'
                    + '</tr>');

                row.find('.line-side').val(side);
                row.find('.line-amount').val(amount ? format(amount) : '').autoNumeric();
                $('#table-adjustment-lines tbody').append(row);

                row.find('.coa-select').select2({
                    ajax: {
                        url: "{{ url('/ac-search-coa-journal-detail') }}",
                        dataType: 'json',
                        type: 'post',
                        delay: 250,
                        data: function (params) {
                            return { q: params.term, _token: $('#_token').val() };
                        },
                        processResults: function (data) {
                            return { results: data };
                        },
                        cache: true
                    },
                    placeholder: 'Cari kode / nama COA (min. 3 huruf)',
                    minimumInputLength: 3,
                    width: '100%',
                    dropdownParent: $('#div-form-modal')
                });

                refreshBank();
            }

            $('#table-adjustment-lines').on('change keyup', '.line-side, .line-amount', refreshBank);

            $('#table-adjustment-lines').on('click', '.btn-remove-line', function () {
                $(this).closest('tr').remove();
                refreshBank();
            });

            $('#btn-add-line').click(function () {
                addLine('D', 0);
            });

            // DEFAULT: SATU BARIS LAWAN YANG MENUTUP SELURUH SELISIH
            addLine(difference >= 0 ? 'C' : 'D', Math.abs(difference));

            $('#div-form-modal').one('hidden.bs.modal', function () {
                $('#div-form-modal .modal-dialog').removeClass('modal-xl');
            });
        });
    </script>
@endsection
