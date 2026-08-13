@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Link Dokumen" :url="$url_save_modal" table="table-financialpayment-detail"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialPaymentDetail" name="IDX_T_FinancialPaymentDetail" value="{{ $fields->IDX_T_FinancialPaymentDetail }}"/>
    <input type="hidden" id="IDX_M_DocumentType" name="IDX_M_DocumentType" value=""/>
    <input type="hidden" id="IDX_DocumentNo" name="IDX_DocumentNo" value=""/>
    <input type="hidden" id="DocumentNo" name="DocumentNo" value=""/>

    <div class="alert alert-label-info">
        Pilih transaksi pembelian valas (Purchase Order) yang akan dihubungkan dengan pembayaran ini.
        Hanya transaksi berstatus Approved yang bisa dipilih.
    </div>

    <x-textbox-horizontal label="No Pembayaran" id="PaymentID" :value="$fields->PaymentID" placeholder="" class="readonly" />
    <x-textbox-horizontal label="Keterangan" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="" class="readonly" />
    <x-textbox-horizontal label="Jumlah" id="PaymentAmount" :value="$fields->PaymentAmount" placeholder="" class="readonly" />

    <hr>

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Transaksi Pembelian</label>
        <div class="col-sm-9">
            <input type="text" id="DocumentSearch" name="DocumentSearch" class="form-control required"
                placeholder="Ketik no transaksi / nama partner..." autocomplete="off">
            <small id="DocumentInfo" class="text-muted"></small>
        </div>
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function(){

            $("#DocumentSearch").autocomplete({

                source: function( request, response ){
                    $.ajax({
                        url: "{{ $url_search_document }}",
                        dataType: "json",
                        type: "POST",
                        data: {
                            q: request.term,
                            _token: $('#_token').val()
                        },
                        success: function(data){
                            response( data );
                        }
                    });
                },
                minLength: 0,
                select: function( event, ui )
                {
                    $("#IDX_M_DocumentType").val(ui.item.IDX_M_DocumentType);
                    $("#IDX_DocumentNo").val(ui.item.IDX_DocumentNo);
                    $("#DocumentNo").val(ui.item.DocumentNo);
                    $("#DocumentInfo").text(ui.item.label);
                }
            }).focus(function(){
                // TAMPILKAN TRANSAKSI TERBARU WALAU BELUM DIKETIK APA APA
                $(this).autocomplete("search", $(this).val());
            });

            // KALAU TEKS DIUBAH MANUAL, PILIHAN SEBELUMNYA DIBATALKAN SUPAYA
            // TIDAK MENGIRIM NOMOR DOKUMEN YANG TIDAK COCOK DENGAN INDEXNYA
            $("#DocumentSearch").on('input', function(){
                if($(this).val() !== $("#DocumentNo").val()){
                    $("#IDX_M_DocumentType").val('');
                    $("#IDX_DocumentNo").val('');
                    $("#DocumentNo").val('');
                    $("#DocumentInfo").text('');
                }
            });
        });
    </script>
@endsection
