@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <input type="hidden" id="CompanyDesc" name="CompanyDesc" value=""/>

    <div class="mb-2">
        <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    </div>

    <x-textbox-horizontal label="Tahun Pajak" id="TaxYear" :value="$TaxYear" placeholder="Contoh: {{ date('Y') }}" class="required mb-2" />

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

            $('#TaxYear').on('input', function () {
                this.value = this.value.replace(/\D/g, '').slice(0, 4);
            });
        });
    </script>

@endsection
