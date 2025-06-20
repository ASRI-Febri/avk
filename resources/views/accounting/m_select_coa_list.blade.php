@extends('layouts.master-datatable-modal')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode CoA</span> 
                <input id="COAID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama CoA</span> 
                <input id="COADesc" type="text" class="form-control" />
            </div>
        </div>      
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama CoA 2</span> 
                <input id="COADesc2" type="text" class="form-control" />
            </div>
        </div>  
    </div>
@endsection

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_COA", visible: false },          
        { data: "COAID" },
        { data: "COADesc" },
        { data: "COADesc2", visible: false },               

        { data: "RecordStatus", visible: false, render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<x-badge-danger label="InActive" />';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<x-badge-info label="Active" />';
                }                
            }
            , class: "text-center"
        },

        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<x-badge-danger label="InActive" />';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<x-badge-info label="Active" />';
                }                
            }
            , class: "text-center"
        },

        { render: 
            function ( data, type, row )
            {						  																		
                return '<a href="#" title="Select" class="text-info bold" onClick="getSelected(\'' +  row['IDX_M_COA'] + '\',\'' + row['COAID'] + '\',\'' + row['COADesc'] + '\')">Pilih</a>';
            }, "sClass": "text-center"
        }
    ]

@endsection

@section('script')

    function getSelected(idx,id,name)
    {	
        @if($target_index !== '')        
        $('#{{ $target_index }}').val(idx);
        @endif

        @if($target_name !== '')        
        $('#{{ $target_name }}').val(id + ' - ' + name);
        @endif

        $('#div-form-modal').modal('hide');
    }

@endsection    