@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <input type="hidden" id="BranchName" name="BranchName" value=""/>
    <input type="hidden" id="ValasName" name="ValasName" value=""/>

    <div class="d-grid gap-3">

        <x-select-horizontal label="Jenis Rekonsiliasi" id="ReconScope" :value="$ReconScope" class="required" :array="$dd_recon_scope" flag="required" />

        <x-select-horizontal label="Pilihan Data" id="DataScope" :value="$DataScope" class="required" :array="$dd_data_scope" flag="required" />

        <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$IDX_M_Branch" class="required" :array="$dd_branch" flag="required" />

        <x-select-horizontal label="Kode Valas (Opsional)" id="IDX_M_Valas" :value="$IDX_M_Valas" class="required" :array="$dd_valas"/>

        <x-textbox-horizontal label="Tanggal Awal" id="start_date" :value="$start_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-textbox-horizontal label="Tanggal Akhir" id="end_date" :value="$end_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

    </div>

@endsection

@section('report-script')

    <script>

        $(document).ready(function(){

            $("#IDX_M_Branch").change(function()
            {
                var idx = document.getElementById("IDX_M_Branch").selectedIndex;
                $("#BranchName").val(document.getElementById("IDX_M_Branch").options[idx].text);
            });

            $("#IDX_M_Valas").change(function()
            {
                var idx = document.getElementById("IDX_M_Valas").selectedIndex;
                $("#ValasName").val(document.getElementById("IDX_M_Valas").options[idx].text);
            });

        });

    </script>

@endsection
