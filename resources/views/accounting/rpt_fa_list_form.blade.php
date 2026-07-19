@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <input type="hidden" id="CompanyDesc" name="CompanyDesc" value=""/>
    <input type="hidden" id="BranchDesc" name="BranchDesc" value=""/>

    <div class="mb-2">
        <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    </div>

    <div class="mb-2">
        <x-select-horizontal label="Profit Center" id="IDX_M_Branch" :value="$IDX_M_Branch" class="" :array="$dd_branch"/>
    </div>

    <div class="mb-2">
        <x-select-horizontal label="Kategori Aset" id="IDX_M_AssetCategory" :value="$IDX_M_AssetCategory" class="" :array="$dd_asset_category"/>
    </div>

    <x-textbox-horizontal label="Tanggal Cut-Off" id="cutoff_date" :value="$cutoff_date" placeholder="Tanggal Cut-Off" class="required datepicker2 mb-2" />

@endsection

@section('script')

    <script>

    $(document).ready(function(){
            $("#IDX_M_Company").change(function()
            {
                var company_id_index = document.getElementById("IDX_M_Company").selectedIndex;
                var company_name = document.getElementById("IDX_M_Company").options[company_id_index].text;

                $("#CompanyDesc").val(company_name);
            });

            $("#IDX_M_Branch").change(function()
            {
                var branch_id_index = document.getElementById("IDX_M_Branch").selectedIndex;
                var branch_name = document.getElementById("IDX_M_Branch").options[branch_id_index].text;

                $("#BranchDesc").val(branch_name);
            });

        });
    </script>

@endsection
