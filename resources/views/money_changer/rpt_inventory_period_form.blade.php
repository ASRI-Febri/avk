@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content-form')
    
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $IDX_M_Branch }}"/>
    <input type="hidden" id="CurrencyName" name="CurrencyName" value=""/>
    <input type="hidden" id="ValasName" name="ValasName" value=""/>

    <div class="d-grid gap-3">
        {{-- <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch" flag="required" /> --}}
        
        {{-- <x-lookup-horizontal label="Vendor" id="PartnerDesc" :value="$fields->PartnerDesc" class="" button="btn-find-vendor"/>  --}}

        <x-select-horizontal label="Mata Uang (Opsional)" id="IDX_M_Currency" :value="$IDX_M_Currency" class="required" :array="$dd_currency"/>

        <x-select-horizontal label="Kode Valas (Opsional)" id="IDX_M_Valas" :value="$IDX_M_Valas" class="required" :array="$dd_valas"/>

        <x-textbox-horizontal label="Tanggal Awal" id="start_date" :value="$start_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-textbox-horizontal label="Tanggal Akhir" id="end_date" :value="$end_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />
    </div>
   
@endsection

@section('report-script')

    <script>

        $(document).ready(function(){ 

            $("#IDX_M_Currency").change(function()
            {   
                //alert('company blur');
                var currency_id = document.getElementById("IDX_M_Currency").value;				
                var currency_id_index = document.getElementById("IDX_M_Currency").selectedIndex;				
                var currency_name = document.getElementById("IDX_M_Currency").options[currency_id_index].text;
                                
                $("#CurrencyName").val(currency_name);
            });

            $("#IDX_M_Valas").change(function()
            {   
                //alert('company blur');
                var valas_id = document.getElementById("IDX_M_Valas").value;				
                var valas_id_index = document.getElementById("IDX_M_Valas").selectedIndex;				
                var valas_name = document.getElementById("IDX_M_Valas").options[valas_id_index].text;
                                
                $("#ValasName").val(valas_name);
            });

        });

    </script>

@endsection 