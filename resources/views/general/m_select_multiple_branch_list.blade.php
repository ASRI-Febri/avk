@extends('layouts.datatables_modal')

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Branch", visible: false },          
        { data: "BranchID" },
        { data: "BranchName" },
        { data: "BranchAlias", visible: true },  
        { data: "BranchRemark", visible: true },  
        { data: "COASales", visible: false },  
        { data: "COAID", visible: false },  
        { data: "COADesc", visible: false },               

        { data: "RecordStatus", visible: false, render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<span class="label label-danger"><strong>In-Active</strong></span>';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<span class="label label-info"><strong>Active</strong></span>';
                }                
            }
            , class: "text-center"
        },

        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<span class="badge outline-badge-danger">In-Active</span>';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<span class="badge outline-badge-info">Active</span>';
                }                
            }
            , class: "text-center"
        },

        { "render": 	function ( data, type, row ){						  
                    var select = '<input type="checkbox" class="ids" id="chk_box[]" name="chk_box[]" value="' + row['IDX_M_Branch'] + '">';									
                    return select;
                },
            "sClass": "text-center"
        },	 
    ]

@endsection

@section('additional_form')

    

        <!-- HIDDEN FIELDS -->
        <input type="hidden" id="IDX_M_User" name="IDX_M_User" value="{{ $IDX_M_User }}"/>
        <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/>
            
        <x-checkbox-horizontal id="selectAll" name="selectAll" label="Select All Data" value="" checked="" />
        <hr>

    

@endsection

@section('button')
    {{-- <button class="btn btn-sm btn-outline-info" onclick="getMultiSelect()"><i class="fas fa-save"></i> Select and Save</button> --}}

    <x-btn-save-detail id="btn-save-detail" label="Select and Save" :url="$url_save_modal" table="table-branch"/>
@endsection

@section('script')

    $(document).ready(function(){

        $("#selectAll").click(function(){        
            var checked_status = this.checked;
            $("input[name='chk_box[]']").each(function()
            {
                this.checked = checked_status;
            });
        });

    });

    {{-- function getSelected(idx,partner_id,partner_name)
    {	
        @if($target_index !== '')        
        $('#{{ $target_index }}').val(idx);
        @endif

        @if($target_name !== '')        
        $('#{{ $target_name }}').val(partner_id + ' - ' + partner_name);
        @endif

        $('#div-form-modal').modal('hide');
    } --}}

@endsection    