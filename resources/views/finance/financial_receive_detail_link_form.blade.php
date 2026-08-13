@extends('layouts.modal_form')

@section('button-save')
    {{-- table = id div pembungkus tabel detail di financial_receive_form, dipakai
         save.js untuk memuat ulang tabel setelah link tersimpan --}}
    <x-btn-save-detail id="btn-save-detail" label="Link Dokumen" :url="$url_save_modal" table="table-receive-detail"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialReceiveDetail" name="IDX_T_FinancialReceiveDetail" value="{{ $fields->IDX_T_FinancialReceiveDetail }}"/>
    <input type="hidden" id="IDX_M_DocumentType" name="IDX_M_DocumentType" value=""/>
    <input type="hidden" id="IDX_DocumentNo" name="IDX_DocumentNo" value=""/>
    <input type="hidden" id="DocumentNo" name="DocumentNo" value=""/>

    <div class="alert alert-label-info">
        Pilih transaksi penjualan valas (Sales Order) yang akan dihubungkan dengan penerimaan ini.
        Hanya transaksi berstatus Approved yang bisa dipilih.
    </div>

    <x-textbox-horizontal label="No Penerimaan" id="ReceiveID" :value="$fields->ReceiveID" placeholder="" class="readonly" />
    <x-textbox-horizontal label="Keterangan" id="RemarkDetail" :value="$fields->RemarkDetail" placeholder="" class="readonly" />
    <x-textbox-horizontal label="Jumlah" id="ReceiveAmount" :value="$fields->ReceiveAmount" placeholder="" class="readonly" />

    <hr>

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Transaksi Penjualan</label>
        <div class="col-sm-9">
            <input type="text" id="DocumentSearch" name="DocumentSearch" class="form-control required"
                placeholder="Ketik no transaksi / nama konsumen..." autocomplete="off">
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
