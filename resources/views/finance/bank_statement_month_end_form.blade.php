@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Buat Jurnal" :url="$url_save_modal"/>
@endsection

@section('modal-content')

    <input type="hidden" name="IDX_T_BankStatementHeader" value="{{ $fields->IDX_T_BankStatementHeader }}"/>

    @if(count($records_detail) == 0)
        <div class="alert alert-label-warning text-dark mb-0">Tidak ada baris biaya, bunga, atau pajak akhir bulan yang belum dijurnal.</div>
    @else
        <div class="alert alert-label-info">
            <div>
                Baris berikut dijadikan satu journal memorial (status Unposted), dua baris jurnal per mutasi
                dengan COA bank <b>{{ $fields->BankCOA }}</b>. Biaya dan pajak: Debit COA kategori / Kredit Bank.
                Bunga: Debit Bank / Kredit COA kategori.
            </div>
        </div>

        <div class="table-responsive mb-3">
            <table class="table table-sm table-bordered mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Tanggal</th>
                        <th>Keterangan</th>
                        <th>Kategori</th>
                        <th class="text-end">Debit</th>
                        <th class="text-end">Kredit</th>
                    </tr>
                </thead>
                <tbody>
                @foreach($records_detail as $row)
                    <tr>
                        <td class="text-nowrap">{{ date('d/m/Y', strtotime($row->PostingDate)) }}</td>
                        <td><small>{{ $row->Remark }}</small></td>
                        <td class="text-nowrap">{{ $categories[$row->Category]['label'] }}</td>
                        <td class="text-end">{{ $row->DebitAmount > 0 ? number_format($row->DebitAmount, 2) : '' }}</td>
                        <td class="text-end">{{ $row->CreditAmount > 0 ? number_format($row->CreditAmount, 2) : '' }}</td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>

        <div class="d-grid gap-3">
            @foreach($categories as $category)
            <div class="row">
                <label class="col-sm-3 col-form-label text-secondary">COA {{ $category['label'] }}</label>
                <div class="col-sm-9">
                    <select name="{{ $category['field'] }}" class="coa-select required">
                        @if($category['default'])
                        <option value="{{ $category['default']->IDX_M_COA }}" selected>{{ $category['default']->COAName }}</option>
                        @endif
                    </select>
                </div>
            </div>
            @endforeach

            <x-textbox-horizontal label="Tanggal Jurnal" id="JournalDate" :value="$fields->JournalDate" placeholder="yyyy-mm-dd" class="required datepicker2" />
            <x-textbox-horizontal label="No Referensi" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="Maks. 32 karakter" class="required" />
            <x-textbox-horizontal label="Keterangan" id="JournalRemark" :value="$fields->JournalRemark" placeholder="Keterangan jurnal" class="required" />
        </div>
    @endif

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#div-form-modal .modal-dialog').addClass('modal-lg');

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

            $('#div-form-modal').one('hidden.bs.modal', function () {
                $('#div-form-modal .modal-dialog').removeClass('modal-lg');
            });
        });
    </script>
@endsection
