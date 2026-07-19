@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-journal-type').addClass('mm-active');
@endsection

@section('right_header')
    @if($state !== 'create')
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_JournalType" name="IDX_M_JournalType" value="{{ $fields->IDX_M_JournalType }}"/>

    <!-- INPUT FIELDS -->
    <x-textbox-horizontal label="Journal Type ID" id="JournalTypeID" :value="$fields->JournalTypeID" placeholder="Contoh: FA-DEPR, GJ, SI" class="required" />
    <x-textbox-horizontal label="Description" id="JournalTypeDesc" :value="$fields->JournalTypeDesc" placeholder="Contoh: FA Depreciation, General Journal" class="required" />
    <x-select-horizontal label="Allow Journal Entry" id="AllowJournalEntry" :value="$fields->AllowJournalEntry" class="select2 required" :array="$dd_yes_no"/>
    <x-textbox-horizontal label="Journal Label" id="JournalLabel" :value="$fields->JournalLabel" placeholder="Label singkat untuk tampilan jurnal" class="" />

    <div class="alert alert-label-info mt-2">
        <span class="text-muted">
            <b>Allow Journal Entry</b>: Yes = journal type dapat dipilih dan diedit lewat input journal manual.
            No = hanya dipakai jurnal yang digenerate sistem (mis. penyusutan aset, HPP).
        </span>
    </div>

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br>
    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection
