@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save" :url="$url_save_modal" table="table-bank"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_M_PartnerBank" name="IDX_M_PartnerBank" value="{{ $fields->IDX_M_PartnerBank }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>        

    @php
        $IsDefault = '';
        if($fields->IsDefault == 'Y'){ $IsDefault = 'checked'; }
    @endphp 

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary"></label>
        <div class="col-sm-9">
            <x-switch-horizontal id="IsDefault" name="IsDefault" label="Default Bank Account?" :value="$IsDefault" :checked="$IsDefault" />
        </div>
    </div>
    <br>
    
    <x-select-horizontal label="Bank" id="IDX_M_Bank" :value="$fields->IDX_M_Bank" class="required mb-2" :array="$dd_bank"/>
    <br>
    <x-textbox-horizontal label="Bank Account No" id="BankAccountNo" :value="$fields->BankAccountNo" placeholder="" class="required mb-2" />    
    <x-textbox-horizontal label="Bank Account Name" id="BankAccountName" :value="$fields->BankAccountName" placeholder="" class="mb-2" />
    <x-textbox-horizontal label="Bank Account Branch" id="BankAccountBranch" :value="$fields->BankAccountBranch" placeholder="" class="mb-2" />
    <x-textbox-horizontal label="Remarks" id="Remarks" :value="$fields->Remarks" placeholder="" class="mb-2" />

@endsection

@section('script')
    <script>
        $(document).ready(function() {      
            
            
            
        });
    </script>
@endsection