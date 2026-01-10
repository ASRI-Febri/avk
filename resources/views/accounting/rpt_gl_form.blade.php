@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="CompanyDesc" name="CompanyDesc" value=""/>  
    <input type="hidden" id="BranchDesc" name="BranchDesc" value=""/>
    <input type="hidden" class="required" id="coa" name="coa"/>

    <div class="mb-2">
        <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    </div>

    <div class="mb-2">
        <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$IDX_M_Branch" class="required" :array="$dd_branch"/>
    </div>

    <x-textbox-horizontal label="Start Date" id="start_date" :value="$start_date" placeholder="Start Date" class="required datepicker2 mb-2" />
    <x-textbox-horizontal label="End Date" id="end_date" :value="$end_date" placeholder="End Date" class="required datepicker2 mb-2" />       

    <hr>
    <button id="btn-select-coa" type="button" class="btn btn-secondary btn-sm" 
        title="Search and add chart of account" ><i class="icon-search4"></i> Pilih Chart of Account...
    </button>
    <br><br>
    <p><em>Jika tidak dipilih, laporan ini akan menampilkan semua chart of account</em></p>

    <table id="table-selected-coa" class="table">
        <thead>
            <tr>            
                <th>ID</th>							
                <th>CoA ID</th>
                <th>CoA Description</th>					           
                <th>Action</th>
            </tr>
        </thead>
        <tbody>

        </tbody>
    </table>
    <hr>

@endsection

@section('script')

<script>

    function deleteSelected(idx)
	{
		//alert(idx);

		var str = document.getElementById('coa').value;
		var res = str.replace(idx+',', "");

		//alert(str);
		//alert(res);
		
		document.getElementById('coa').value = res;
		//document.getElementById('coa').focus();
		//document.getElementById('submit_form').focus();

		$('#table-selected-coa tr').click(function(){
			$(this).remove();
			return false;
		});

		var coa = $("#coa").val();				

		$('#coa').val(coa);
	}

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

        $('#btn-select-coa').click(function()
        {   
            var data = {
                _token: $("#_token").val(),                  
            }                

            callAjaxModalView('{{ url('ac-coa/select-multiple') }}',data);            
        });

        

    });
</script>

@endsection