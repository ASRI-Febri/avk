@extends('layouts.master-form-with-log')

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('form-remark')
    {{ $form_remark }}
@endsection

@section('content-form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_FinancialAccount" name="IDX_M_FinancialAccount" value="{{ $fields->IDX_M_FinancialAccount }}"/>
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>
    
    <legend><h6 class="text-muted font-weight-bold">Account Info</h6></legend>
    <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
    <x-textbox-horizontal label="Kode FA" id="FinancialAccountID" :value="$fields->FinancialAccountID" placeholder="Financial Account ID" class="required" />
    <x-textbox-horizontal label="Nama FA" id="FinancialAccountDesc" :value="$fields->FinancialAccountDesc" placeholder="Financial Account Desc" class="required" />
    <x-select-horizontal label="Jenis Akun" id="FinancialAccountType" :value="$fields->FinancialAccountType" class="required" :array="$dd_account_type"/>
    <x-lookup-horizontal label="Chart Of Account" id="COADesc" :value="$fields->COADesc" class="required"  button="btn-find-coa"/>

    <legend><h6 class="text-muted font-weight-bold">Additional Info</h6></legend>
    <x-select-horizontal label="Currency" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>
    <x-select-horizontal label="Bank" id="IDX_M_Bank" :value="$fields->IDX_M_Bank" class="required" :array="$dd_bank"/>
    <x-textbox-horizontal label="No Rekening Bank" id="AccountNo" :value="$fields->AccountNo" placeholder="Account No" class="required" />
    <x-textbox-horizontal label="Nama di Rekening" id="AccountName" :value="$fields->AccountName" placeholder="Account Name" class="required" />
   
    <div class="form-row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection

@section('script')

    <script> 

        $(document).ready(function(){
            $('#btn-find-coa').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_COA',
                    target_name: 'COADesc'                  
                }              

                callAjaxModalView('{{ url('/fm-select-coa') }}',data);                
            });
        });

    </script>

@endsection