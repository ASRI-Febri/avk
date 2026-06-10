@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Simpan" :url="$url_save_modal" table="table-stock-card"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_StockCardValas" name="IDX_T_StockCardValas" value="{{ $fields->IDX_T_StockCardValas }}"/>
    <input type="hidden" id="IDX_Transaction" name="IDX_Transaction" value="{{ $fields->IDX_Transaction }}"/>
    <input type="hidden" id="IDX_M_TransactionType" name="IDX_M_TransactionType" value="{{ $fields->IDX_M_TransactionType }}"/>

    <div class="alert alert-label-info">
        <span class="text-muted">
            {{ $fields->TransactionNo }} &mdash; {{ $fields->ValasSKU }} ({{ $fields->ValasName }})
        </span>
    </div>

    <div class="d-grid gap-3">

        @if($fields->IDX_M_TransactionType == 3)
            <x-textbox-horizontal label="Qty Masuk (Pembelian)" id="StockInQty" :value="number_format($fields->StockInQty, 2, '.', ',')" placeholder="" class="required auto" />
            <input type="hidden" id="StockOutQty" name="StockOutQty" value="{{ $fields->StockOutQty }}"/>
        @else
            <x-textbox-horizontal label="Qty Keluar (Penjualan)" id="StockOutQty" :value="number_format($fields->StockOutQty, 2, '.', ',')" placeholder="" class="required auto" />
            <input type="hidden" id="StockInQty" name="StockInQty" value="{{ $fields->StockInQty }}"/>
        @endif

    </div>

@endsection
