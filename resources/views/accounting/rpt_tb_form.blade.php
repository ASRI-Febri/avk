@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content_form')

    <input type="hidden" id="CompanyDesc" name="CompanyDesc" value=""/>  
    <input type="hidden" id="BranchDesc" name="BranchDesc" value=""/>

    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$IDX_M_Branch" class="required" :array="$dd_branch"/>
    <x-textbox-horizontal label="Start Date" id="start_date" :value="$start_date" placeholder="Start Date" class="required datepicker2" />
    <x-textbox-horizontal label="End Date" id="end_date" :value="$start_date" placeholder="End Date" class="required datepicker2" />       

@endsection

@section('script')

    <script>

    $(document).ready(function(){ 
            $("#IDX_M_Company").change(function()
            {   
                //alert('company blur');
                var company_id = document.getElementById("IDX_M_Company").value;				
                var company_id_index = document.getElementById("IDX_M_Company").selectedIndex;				
                var company_name = document.getElementById("IDX_M_Company").options[company_id_index].text;
                                
                $("#CompanyDesc").val(company_name);
            });

            $("#IDX_M_Branch").change(function()
            {
                //alert('branch blur');
                var branch_id = document.getElementById("IDX_M_Branch").value;				
                var branch_id_index = document.getElementById("IDX_M_Branch").selectedIndex;				
                var branch_name = document.getElementById("IDX_M_Branch").options[branch_id_index].text;
                                
                $("#BranchDesc").val(branch_name);
            });              

        });
    </script>

@endsection