@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-delete-detail" label="Hapus ?" :url="$url_save_modal" table="table-stock-card"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_StockCardValas" name="IDX_T_StockCardValas" value="{{ $fields->IDX_T_StockCardValas }}"/>
    <input type="hidden" id="IDX_Transaction" name="IDX_Transaction" value="{{ $fields->IDX_Transaction }}"/>
    <input type="hidden" id="IDX_M_TransactionType" name="IDX_M_TransactionType" value="{{ $fields->IDX_M_TransactionType }}"/>
    <input type="hidden" id="state" name="state" value="{{ $state }}"/>

    <h5 class="text-danger">Hapus baris kartu stok : {{ $fields->TransactionNo }} &mdash; {{ $fields->ValasSKU }} ({{ $fields->ValasName }}) ?</h5>
    <p class="text-muted">Tindakan ini menghapus permanen 1 baris di <code>MC_T_StockCardValas</code>.</p>

@endsection
