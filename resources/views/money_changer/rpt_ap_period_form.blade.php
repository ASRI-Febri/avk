@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content-form')
    
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $IDX_M_Branch }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $IDX_M_Partner }}"/>
    
    <div class="d-grid gap-3">
        <x-lookup-horizontal label="Konsumen (Opsional)" id="PartnerDesc" :value="$PartnerDesc" class="required"  button="btn-find-partner"/>

        <x-textbox-horizontal label="Tanggal Awal" id="start_date" :value="$start_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-textbox-horizontal label="Tanggal Akhir" id="end_date" :value="$end_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-select-horizontal label="Diurutkan Berdasarkan" id="GroupReport" :value="$GroupReport" class="required" :array="$dd_group_report"/>
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