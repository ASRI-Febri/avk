@extends('layouts.master-datatable-modal')

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_COA", visible: false },    
        { data: "COAID" },
        { data: "COADesc" },
        { data: "COADesc2", visible: false }, 
        { "render": 	function ( data, type, row ){						  
                    var select = '<input type="checkbox" class="ids" id="chk_box[]" name="chk_box[]" value="'+row['IDX_M_COA']+','+row['COAID']+','+row['COADesc']+'">';									
                    return select;
                },
            "sClass": "text-center"
        },
    ]

@endsection

@section('button')
    <button class="btn btn-info" onclick="getMultiSelect()">Select COA !</button>
@endsection 

@section('script')

    function getMultiSelect()
	{
		var idx = [];
			
		$('.ids:checked').each(function(i, e) {

			var c = $(this).val().split(',')

			//alert(c[0]);
			//alert(c[1]);
			//alert(c[2]);

			//ids.push($(this).val());

			var coa = $("#coa").val();

			// CHECK IF EXISTS
			if(!coa.includes(c[0])){

				idx.push(c[0]);

				var coa = $("#coa").val();
				coa += c[0] + ','
				$('#coa').val(coa);

				var link_delete = '<a href="#" class=\"deleteLink text-danger\" title="Delete" onClick="deleteSelected(' +  c[0] + ')">Delete</a>';

				$("#table-selected-coa").find('tbody')
					.append("<tr id=\"" + c[0] + "\"><td>" + c[0] + "</td><td>" + c[1] + "</td><td>" + c[2] + "</td><td>" + link_delete + "</td></tr>");
			}
		});	

		$('#div-form-modal').modal('hide');			
    }
    
    function getSelected(idx,coa_id,coa_name,coa_name2)
    {	
        {{-- $('#idx_m_coa').val(idx);	       	
        $('#coa_name').val(coa_name);
        $('#coa_name2').val(coa_name2); --}}

        @if($target_index !== '')        
        $('#{{ $target_index }}').val(idx);
        @endif

        @if($target_name !== '')        
        $('#{{ $target_name }}').val(coa_id + ' - ' + coa_name);
        @endif

        $('#div-form-modal').modal('hide');
    }

@endsection    