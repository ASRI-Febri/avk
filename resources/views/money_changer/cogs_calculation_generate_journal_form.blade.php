@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal"
        :label="($jumlah_jurnal ?? 0) > 0 ? 'Generate Ulang' : 'Generate Journal'"
        :url="$url_save_modal" />
@endsection

@section('modal-content')

    @if(($jumlah_jurnal ?? 0) > 0)
        {{-- Jurnal periode ini sudah ada; proses akan menghapus lalu membuat ulang --}}
        <div class="alert alert-label-danger">
            Periode ini sudah punya <strong>{{ $jumlah_jurnal }}</strong> jurnal HPP.
            Jurnal lama tersebut akan <strong>dihapus dan dibuat ulang</strong> memakai hasil
            perhitungan HPP yang berlaku sekarang.
        </div>
    @else
        <div class="alert alert-label-info">
            Jurnal HPP akan dibuat untuk seluruh nota penjualan yang sudah Approved pada periode ini.
        </div>
    @endif

    <div class="d-grid gap-3">
        <x-textbox-horizontal
            label="Journal Period"
            id="JournalPeriod"
            :value="$fields->JournalPeriod"
            placeholder="YYYYMM"
            class="required readonly" />

        <x-textbox-horizontal
            label="Nota Approved"
            id="JumlahNota"
            :value="($jumlah_nota ?? 0) . ' nota penjualan'"
            placeholder=""
            class="readonly" />

        <x-textbox-horizontal
            label="Jurnal HPP Saat Ini"
            id="JumlahJurnal"
            :value="($jumlah_jurnal ?? 0) . ' jurnal'"
            placeholder=""
            class="readonly" />
    </div>

    <p class="text-muted mt-2 mb-0">
        Satu jurnal dibuat per nota penjualan (voucher <code>HP-&lt;no nota&gt;</code>) dan langsung berstatus Posted.
        Kalau ada nota yang gagal, seluruh proses dibatalkan dan nomor notanya disebutkan di pesan error.
    </p>

@endsection
