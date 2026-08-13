@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-financialpayment-detail"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialPaymentDetail" name="IDX_T_FinancialPaymentDetail" value="{{ $fields->IDX_T_FinancialPaymentDetail }}"/>
    <input type="hidden" id="IDX_T_FinancialPaymentHeader" name="IDX_T_FinancialPaymentHeader" value="{{ $fields->IDX_T_FinancialPaymentHeader }}"/>
    {{-- DOCUMENT TYPE IKUT DIKIRIM APA ADANYA SUPAYA TIDAK TERTIMPA SAAT DETAIL DISUNTING.
         SEBELUMNYA CONTROLLER MEMAKSA NILAI 2 (Purchase Invoice) SEHINGGA DETAIL YANG
         TERTAUT KE PURCHASE ORDER VALAS (11) PUTUS DARI LAPORAN AP. --}}
    <input type="hidden" id="IDX_M_DocumentType" name="IDX_M_DocumentType" value="{{ $fields->IDX_M_DocumentType ?? '' }}"/>
    <input type="hidden" id="IDX_DocumentNo" name="IDX_DocumentNo" value="{{ $fields->IDX_DocumentNo ?? 0 }}"/>
    <input type="hidden" id="DocumentNo" name="DocumentNo" value="{{ $fields->DocumentNo ?? '' }}"/>

    <x-select-horizontal label="Project" id="IDX_M_Project" :value="$fields->IDX_M_Project" class="required" :array="$dd_project"/>

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Account</label>
        <div class="col-sm-9">
            <select id="IDX_M_COA" name="IDX_M_COA" class="select2-coa required" style="width:100%;">
                @if(($fields->IDX_M_COA ?? 0) > 0)
                    <option value="{{ $fields->IDX_M_COA }}" selected>{{ $fields->COADesc1 }}</option>
                @endif
            </select>
        </div>
    </div>
    <x-textbox-horizontal label="Payment Amount" id="PaymentAmount" :value="$fields->PaymentAmount" placeholder="Payment Amount" class="required auto" />
    <x-textbox-horizontal label="Notes" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="Notes" class="required" />

@endsection

@section('script')
    <script>
        $(document).ready(function(){
            $('.select2').select2({		
                theme: 'bootstrap4',
                width: "100%",            
                placeholder: $(this).attr('placeholder'),
                dropdownParent: $('#div-form-modal')	
            });	

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