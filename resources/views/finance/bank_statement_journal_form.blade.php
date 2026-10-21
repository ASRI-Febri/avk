@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" :label="$submit_title" :url="$url_save_modal"/>
@endsection

@section('modal-content')

    <input type="hidden" name="IDX_T_BankStatementHeader" value="{{ $fields->IDX_T_BankStatementHeader }}"/>

    @if(count($records_detail) == 0)
        <div class="alert alert-label-warning text-dark mb-0">Baris yang dipilih sudah memiliki jurnal.</div>
    @else
        @php
            $total = 0;
            $latest = '';
            foreach ($records_detail as $row) {
                $total += $row->DebitAmount + $row->CreditAmount;
                $latest = max($latest, substr($row->PostingDate, 0, 10));
            }
        @endphp

        <div class="alert alert-label-info">
            <div>
                Journal Memorial berstatus Unposted dengan COA bank <b>{{ $fields->BankCOA }}</b>.
                Uang masuk: Debit Bank / Kredit COA lawan. Uang keluar: Debit COA lawan / Kredit Bank.
            </div>
        </div>

        @if(count($records_detail) > 1)
        <div class="row mb-3">
            <label class="col-sm-3 col-form-label text-secondary">Cara Jurnal</label>
            <div class="col-sm-9 pt-2">
                <div class="form-check form-check-inline">
                    <input class="form-check-input journal-mode" type="radio" name="JournalMode" id="mode-row" value="row" checked>
                    <label class="form-check-label" for="mode-row">1 jurnal per baris</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input journal-mode" type="radio" name="JournalMode" id="mode-merge" value="merge">
                    <label class="form-check-label" for="mode-merge">
                        Gabungkan {{ count($records_detail) }} baris jadi 1 jurnal (total {{ number_format($total, 2) }})
                    </label>
                </div>
            </div>
        </div>

        <div id="panel-merge" class="d-grid gap-3 mb-3" style="display: none !important;">
            <div class="row">
                <label class="col-sm-3 col-form-label text-secondary">Chart of Account Lawan</label>
                <div class="col-sm-9">
                    <select name="MergeCOA" class="coa-select"></select>
                </div>
            </div>
            <x-textbox-horizontal label="Tanggal Jurnal" id="MergeDate" :value="$latest" placeholder="yyyy-mm-dd" class="datepicker2" />
            <x-textbox-horizontal label="Keterangan" id="MergeRemark" value="" placeholder="mis. Beban gaji periode September 2026" class="" />
        </div>
        @endif

        <div id="panel-row" class="row mb-3">
            <label class="col-sm-3 col-form-label text-secondary">COA untuk semua baris</label>
            <div class="col-sm-9">
                <select id="coa-all" class="coa-select"></select>
            </div>
        </div>

        <div class="table-responsive" style="max-height: 450px;">
            <table class="table table-sm table-bordered">
                <thead class="table-light">
                    <tr>
                        <th>Tanggal</th>
                        <th class="text-end">Debit</th>
                        <th class="text-end">Kredit</th>
                        <th class="col-merge-info" style="display: none;">Keterangan Bank</th>
                        <th width="35%" class="col-row-input">Chart of Account Lawan</th>
                        <th width="35%" class="col-row-input">Keterangan Jurnal</th>
                    </tr>
                </thead>
                <tbody>
                @foreach($records_detail as $row)
                    <tr>
                        <td class="text-nowrap">{{ date('d/m/Y', strtotime($row->PostingDate)) }}</td>
                        <td class="text-end">{{ $row->DebitAmount > 0 ? number_format($row->DebitAmount, 2) : '' }}</td>
                        <td class="text-end">{{ $row->CreditAmount > 0 ? number_format($row->CreditAmount, 2) : '' }}</td>
                        <td class="col-merge-info" style="display: none;"><small>{{ $row->Remark }}</small></td>
                        <td class="col-row-input">
                            <select name="rows[{{ $row->IDX_T_BankStatementDetail }}][coa]" class="coa-select coa-row"></select>
                        </td>
                        <td class="col-row-input">
                            <textarea name="rows[{{ $row->IDX_T_BankStatementDetail }}][remark]" class="form-control form-control-sm" rows="2">{{ $row->Remark }}</textarea>
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    @endif

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#div-form-modal .modal-dialog').addClass('modal-xl');

            $('.coa-select').select2({
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

            $('.journal-mode').change(function () {
                var merge = $('#mode-merge').is(':checked');
                $('#panel-merge').attr('style', merge ? '' : 'display: none !important;');
                $('#panel-row, .col-row-input').toggle(!merge);
                $('.col-merge-info').toggle(merge);
            });

            $('#coa-all').on('select2:select', function (e) {
                var coa = e.params.data;
                $('.coa-row').each(function () {
                    $(this).empty().append(new Option(coa.text, coa.id, true, true)).trigger('change');
                });
            });

            $('#div-form-modal').one('hidden.bs.modal', function () {
                $('#div-form-modal .modal-dialog').removeClass('modal-xl');
            });
        });
    </script>
@endsection
