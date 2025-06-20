@extends('layouts.datatables_modal')

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Project", visible: false },           
        { data: "ProjectID", visible: true },
        { data: "ProjectName", visible: true },       
        { data: "ProjectDesc", visible: true },

        { "render": 	function ( data, type, row ){						  
                    var select = '<input type="checkbox" class="ids" id="chk_box[]" name="chk_box[]" value="' + row['IDX_M_Project'] + '">';									
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

    <x-btn-save-detail id="btn-save-detail" label="Select and Save" :url="$url_save_modal" table="table-project"/>
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