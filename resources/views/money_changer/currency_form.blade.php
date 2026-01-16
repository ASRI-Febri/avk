@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    {{-- $('#nav-link-sbp-ul').css("display","block"); --}}
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-currency').addClass('mm-active');
@endsection

@section('form-remark')
    Data mata uang dengan asal negara dan symbolnya. 
    <br> 
    Contoh <code>USD</code> untuk mata uang dollar Amerika.
@endsection

@section('content-form')    
   
    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Currency" name="IDX_M_Currency" value="{{ $fields->IDX_M_Currency }}"/>
    <input type="hidden" id="SalesAccount" name="SalesAccount" value="{{ $fields->SalesAccount }}"/>  
    <input type="hidden" id="PurchaseAccount" name="PurchaseAccount" value="{{ $fields->PurchaseAccount }}"/>

    <x-select-horizontal label="Negara" id="IDX_M_Country" :value="$fields->IDX_M_Country" class="required" :array="$dd_country"/>

    <x-textbox-horizontal label="Kode Currency" id="CurrencyID" :value="$fields->CurrencyID" placeholder="" class="required" />
    <x-textbox-horizontal label="Nama Currency" id="CurrencyName" :value="$fields->CurrencyName" placeholder="" class="required" />
    <x-textbox-horizontal label="Symbol" id="Symbol" :value="$fields->Symbol" placeholder="" class="required" />
    <x-textbox-horizontal label="Icon Flag" id="IconFlag" :value="$fields->IconFlag" placeholder="" class="required" />
    <x-textbox-horizontal label="Sort Priority" id="SortPriority" :value="$fields->SortPriority" placeholder="" class="auto required" />
    
    <x-textbox-horizontal label="Rate Beli" id="BuyRate" :value="$fields->BuyRate" placeholder="" class="required auto" />
    <x-textbox-horizontal label="Rate Jual" id="SellRate" :value="$fields->SellRate" placeholder="" class="required auto" />

    <x-lookup-horizontal label="Sales Account" id="SalesAccountDesc" :value="$fields->SalesAccountDesc" class="required" button="btn-find-coa-ar"/>
    
    <x-lookup-horizontal label="Purchase Account" id="PurchaseAccountDesc" :value="$fields->PurchaseAccountDesc" class="required" button="btn-find-coa-ap"/>

    <x-select-horizontal label="Status" id="RecordStatus" :value="$fields->RecordStatus" class="required" :array="$dd_record_status"/>

    <div class="row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div>       

@endsection 

@section('script')

    <script>

        $(document).ready(function(){

            $('#btn-find-coa-ar').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'SalesAccount',
                    target_name: 'SalesAccountDesc'                  
                }                

                callAjaxModalView('{{ url('/ac-select-coa') }}',data);                
            });

            $('#btn-find-coa-ap').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'PurchaseAccount',
                    target_name: 'PurchaseAccountDesc'                  
                }                

                callAjaxModalView('{{ url('/ac-select-coa') }}',data);                
            }); 

        });

    </script>

@endsection 