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
        { data: "COAID", visible: true },
        { data: "COADesc", visible: true },
        { data: "COADesc2", visible: true },
        { data: "COAGroup1ID", visible: false }, 
        { data: "COAGroup1Name1", visible: true }, 

        { render: 
            function ( data, type, row )
            {						  																		
                return '<a href="#" title="Select" class="text-primary" onClick="getSelected(\'' +  row['IDX_M_COA'] + '\',\'' + row['COAID'] + '\',\'' + row['COADesc'] + '\',\'' + row['COADesc2'] + '\')">Select</a>';
            }, "sClass": "text-center"
        }
    ]

@endsection

@section('script')

    function getSelected(idx,id,name,name2)
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