@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Duplicate" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>

    <div class="alert alert-primary" role="alert">
        Fungsi ini untuk membuat duplikat data chart of account.
    </div>

    <dl class="row mb-0 redial-line-height-2_5">
        <dt class="col-sm-5">Prev COA ID:</dt>
        <dd class="col-sm-7">{{ $fields->COAID }}</dd>

        <dt class="col-sm-5">Prev COA Desc:</dt>
        <dd class="col-sm-7">{{ $fields->COADesc }}</dd>
        
        <dt class="col-sm-5">Prev COA Desc 2:</dt>
        <dd class="col-sm-7">{{ $fields->COADesc2}}</dd>
    </dl>
    <hr>

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="New COA ID" id="COAID" :value="$fields->COAID" placeholder="COA ID" class="required" />
        <x-textbox-horizontal label="New COA Name" id="COADesc" :value="$fields->COADesc" placeholder="" class="required" />
        <x-textbox-horizontal label="New COA Name 2" id="COADesc2" :value="$fields->COADesc2" placeholder="" class="required" />  
    </div>

@endsection 