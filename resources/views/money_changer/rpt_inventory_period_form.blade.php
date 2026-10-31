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

        <x-select-horizontal label="Group Data" id="GroupBy" :value="$GroupBy" class="required" :array="$dd_group_by"/>

        <x-textbox-horizontal label="Tanggal Awal" id="start_date" :value="$start_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-textbox-horizontal label="Tanggal Akhir" id="end_date" :value="$end_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />
    </div>
   
@endsection

@section('report-script')

    <script>

        $(document).ready(function(){

            var valasCurrencyMap = @json($valas_currency_map ?? []);
            var valasOptions = $("#IDX_M_Valas option").clone();

            $("#IDX_M_Currency").change(function()
            {
                //alert('company blur');
                var currency_id = document.getElementById("IDX_M_Currency").value;
                var currency_id_index = document.getElementById("IDX_M_Currency").selectedIndex;
                var currency_name = document.getElementById("IDX_M_Currency").options[currency_id_index].text;

                $("#CurrencyName").val(currency_id === '' ? '' : currency_name);

                // CHAINED DROPDOWN: TAMPILKAN KODE VALAS SESUAI MATA UANG TERPILIH
                var valas = $("#IDX_M_Valas");
                var valasGroup = valas.closest('.form-group');
                var selected = valas.val();

                valasGroup.block({
                    message: '<span class="text-semibold"><i class="fa fa-spinner fa-spin"></i>&nbsp; Memuat kode valas...</span>',
                    overlayCSS: { backgroundColor: '#fff', opacity: 0.8, cursor: 'wait' },
                    css: { border: 0, padding: '5px 10px', color: '#fff', width: 'auto', backgroundColor: '#333' }
                });

                // DITUNDA AGAR LOADER SEMPAT TERLIHAT SEBELUM DROPDOWN DIPERBARUI
                setTimeout(function(){
                    valas.empty().append(valasOptions.filter(function(){
                        return this.value === '' || currency_id === ''
                            || String(valasCurrencyMap[this.value]) === currency_id;
                    }).clone());

                    if (valas.find('option[value="' + selected + '"]').length) {
                        valas.val(selected);
                    } else {
                        valas.val('');
                        $("#ValasName").val('');
                    }
                    valas.trigger('change.select2');

                    valasGroup.unblock();
                }, 300);
            });

            $("#IDX_M_Valas").change(function()
            {   
                //alert('company blur');
                var valas_id = document.getElementById("IDX_M_Valas").value;				
                var valas_id_index = document.getElementById("IDX_M_Valas").selectedIndex;				
                var valas_name = document.getElementById("IDX_M_Valas").options[valas_id_index].text;
                                
                $("#ValasName").val(valas_id === '' ? '' : valas_name);
            });

        });

    </script>

@endsection 