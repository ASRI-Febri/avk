@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Buat Jurnal" :url="$url_save_modal"/>
@endsection

@section('modal-content')

    <input type="hidden" name="IDX_T_BankStatementHeader" value="{{ $fields->IDX_T_BankStatementHeader }}"/>

    @if($fields->AdminFeeCount == 0)
        <div class="alert alert-label-warning text-dark mb-0">Tidak ada baris biaya admin yang belum dijurnal.</div>
    @else
        <div class="alert alert-label-info">
            <div>
                <b>{{ $fields->AdminFeeCount }}</b> baris biaya admin yang belum dijurnal dijumlahkan menjadi satu jurnal
                penyesuaian (Journal Memorial, status Unposted): Debit COA biaya / Kredit <b>{{ $fields->BankCOA }}</b>.
            </div>
        </div>

        <div class="d-grid gap-3">
            <x-textbox-horizontal label="Total Biaya Admin" id="AdminFeeAmount" :value="number_format($fields->AdminFeeAmount, 2)" placeholder="" class="readonly text-end" />

            <div class="row">
                <label class="col-sm-3 col-form-label text-secondary">COA Biaya</label>
                <div class="col-sm-9">
                    <select id="IDX_M_COA" name="IDX_M_COA" class="required">
                        @if($fields->IDX_M_COA)
                        <option value="{{ $fields->IDX_M_COA }}" selected>{{ $fields->COAName }}</option>
                        @endif
                    </select>
                </div>
            </div>

            <x-textbox-horizontal label="Tanggal Jurnal" id="JournalDate" :value="$fields->JournalDate" placeholder="yyyy-mm-dd" class="required datepicker2" />
            <x-textbox-horizontal label="Keterangan" id="JournalRemark" :value="$fields->JournalRemark" placeholder="Keterangan jurnal" class="required" />
        </div>
    @endif

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#IDX_M_COA').select2({
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
        });
    </script>
@endsection
