@extends('layouts.master-form-with-log')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-recurring-journal').addClass('mm-active');
@endsection

@section('right_header')
    @if($state !== 'create')
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif
@endsection

@section('content-form')

    <div class="alert alert-label-info">
        <span class="text-muted">
            Setiap kali diproses di akhir periode, template ini membuat jurnal:
            <b>Debet</b> akun debet dan <b>Kredit</b> akun kredit sebesar nilai per periode.
            Contoh amortisasi sewa: Debet <i>Biaya Sewa</i>, Kredit <i>Sewa Dibayar Dimuka</i>.
        </span>
    </div>

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_RecurringJournal" name="IDX_M_RecurringJournal" value="{{ $fields->IDX_M_RecurringJournal }}"/>

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="select2 required" :array="$dd_company"/>
    <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="select2 required" :array="$dd_branch"/>
    <x-textbox-horizontal label="Kode Recurring" id="RecurringCode" :value="$fields->RecurringCode" placeholder="Contoh: RJ-SEWA-KANTOR" class="required" />
    <x-textbox-horizontal label="Nama Recurring" id="RecurringName" :value="$fields->RecurringName" placeholder="Contoh: Amortisasi sewa kantor bulanan" class="required" />
    <x-textarea-horizontal label="Keterangan" id="RecurringDesc" :value="$fields->RecurringDesc" placeholder="Keterangan tambahan (no kontrak, dsb)" class="" />

    <hr>
    <h5 class="mb-3">Jurnal per Periode</h5>
    <x-select-horizontal label="Akun Debet" id="IDX_M_COA_Debet" :value="$fields->IDX_M_COA_Debet" class="select2 required" :array="$dd_coa"/>
    <x-select-horizontal label="Akun Kredit" id="IDX_M_COA_Credit" :value="$fields->IDX_M_COA_Credit" class="select2 required" :array="$dd_coa"/>
    <x-textbox-horizontal label="Nilai per Periode" id="RecurringAmount" :value="$fields->RecurringAmount" placeholder="0" class="required auto text-right" />

    <hr>
    <h5 class="mb-3">Penyesuaian Periode Terakhir</h5>
    <div class="alert alert-label-info">
        <span class="text-muted">
            Bila <b>Ya</b>: nilai jurnal pada <b>periode akhir</b> dihitung ulang =
            Nilai Total Kontrak − akumulasi yang sudah digenerate, sehingga tidak ada sisa pembulatan.
            Contoh sewa 58.000.000 / 12 bulan: 11 bulan &times; 4.833.333,33 = 53.166.666,63,
            periode ke-12 otomatis = 4.833.333,37.
        </span>
    </div>
    <x-select-horizontal label="Penyesuaian Periode Terakhir" id="AdjustLastPeriod" :value="$fields->AdjustLastPeriod" class="select2 required" :array="$dd_yes_no"/>
    <x-textbox-horizontal label="Nilai Total Kontrak" id="TotalAmount" :value="$fields->TotalAmount" placeholder="Contoh: 58000000 (wajib bila penyesuaian = Ya)" class="auto text-right" />

    <hr>
    <h5 class="mb-3">Masa Berlaku</h5>
    <x-textbox-horizontal label="Periode Mulai (YYYYMM)" id="StartPeriod" :value="$fields->StartPeriod" placeholder="Contoh: {{ date('Ym') }}" class="required" />
    <x-textbox-horizontal label="Periode Akhir (YYYYMM)" id="EndPeriod" :value="$fields->EndPeriod" placeholder="Kosongkan bila tanpa batas akhir" class="" />
    <x-select-horizontal label="Status" id="RecurringStatus" :value="$fields->RecurringStatus" class="select2 required" :array="$dd_active_status"/>

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br>
    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection
