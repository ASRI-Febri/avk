@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-pettycash-detail"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PettyCashDetail" name="IDX_T_PettyCashDetail" value="{{ $fields->IDX_T_PettyCashDetail }}"/>
    <input type="hidden" id="IDX_T_PettyCashHeader" name="IDX_T_PettyCashHeader" value="{{ $fields->IDX_T_PettyCashHeader }}"/>

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="Tanggal Transaksi" id="TransactionDate" :value="$fields->TransactionDate" placeholder="Tanggal Transaksi" class="required datepicker2" />
        <x-select-horizontal label="Document Type" id="IDX_M_DocumentType" :value="$fields->IDX_M_DocumentType" class="required" :array="$dd_document_type"/>

        <div class="form-group row">
            <label class="col-sm-3 col-form-label text-secondary">Account (Beban)</label>
            <div class="col-sm-9">
                <select id="IDX_M_COA" name="IDX_M_COA" class="select2-coa required" style="width:100%;">
                    @if(($fields->IDX_M_COA ?? 0) > 0)
                        <option value="{{ $fields->IDX_M_COA }}" selected>{{ $fields->COADesc1 }}</option>
                    @endif
                </select>
            </div>
        </div>

        <x-textbox-horizontal label="No Referensi" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="No referensi (cth: no nota)" class="" />
        <x-textbox-horizontal label="Dibayarkan ke" id="PartnerName" :value="$fields->PartnerName" placeholder="Nama penerima" class="required" />
        <x-textbox-horizontal label="Keterangan" id="DetailDesc" :value="$fields->DetailDesc" placeholder="Keterangan" class="required" />
        <x-textbox-horizontal label="Jumlah" id="PettyCashAmount" :value="$fields->PettyCashAmount" placeholder="Jumlah" class="required auto" />
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function(){
            $('.select2-coa').select2({
                width: "100%",
                dropdownParent: $('#div-form-modal'),
                placeholder: 'Ketik min. 3 huruf untuk cari COA...',
                allowClear: true,
                minimumInputLength: 3,
                ajax: {
                    url: "{{ url('/fm-account/search') }}",
                    type: "POST",
                    dataType: "json",
                    delay: 250,
                    data: function (params) {
                        return {
                            q: params.term,
                            _token: $('#_token').val()
                        };
                    },
                    processResults: function (data) {
                        return {
                            results: $.map(data, function (item) {
                                return { id: item.IDX_M_COA, text: item.label };
                            })
                        };
                    },
                    cache: true
                }
            });
        });
    </script>
@endsection
