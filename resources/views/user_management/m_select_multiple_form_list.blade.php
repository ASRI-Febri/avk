@extends('layouts.datatables_modal')

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Form", visible: false }, 
        { data: "ApplicationName" },
        { data: "FormID" },
        { data: "FormName" },
        { data: "FormURL", visible: false },
        { data: "FormDescription" },
        { data: "GroupID", visible: false },        

        { data: "RecordStatus", visible: false, render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<span class="label label-danger text-white"><strong>In-Active</strong></span>';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<span class="label label-info text-white"><strong>Active</strong></span>';
                }                
            }
            , class: "text-center"
        },

        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<x-badge-danger label="In-Active" />';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<x-badge-info label="Active" />';
                }                
            }
            , class: "text-center"
        },

        { "render": function ( data, type, row ){						  
                    var select = '<input type="checkbox" class="ids" id="chk_box[]" name="chk_box[]" value="' + row['IDX_M_Form'] + '">';									
                    return select;
                },
            "sClass": "text-center"
        },	 
    ]

@endsection

@section('additional_form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Group" name="IDX_M_Group" value="{{ $IDX_M_Group }}"/>
    <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/>
        
    <x-checkbox-horizontal id="selectAll" name="selectAll" label="Select All Data" value="" checked="" />
    <hr>    

@endsection

@section('button')
    {{-- <button class="btn btn-sm btn-outline-info" onclick="getMultiSelect()"><i class="fas fa-save"></i> Select and Save</button> --}}

    <x-btn-save-detail id="btn-save-detail" label="Select and Save" :url="$url_save_modal" table="table-form"/>
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