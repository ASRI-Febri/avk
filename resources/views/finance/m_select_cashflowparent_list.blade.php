@extends('layouts.master-datatable-modal')

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_CashflowID", visible: false },
        { data: "CashflowID", visible: true },
        { data: "CashflowDesc", visible: true },

        { render: 
            function ( data, type, row )
            {						  																		
                return '<a href="#" title="Select" class="text-primary" onClick="getSelected(\'' +  row['IDX_M_CashflowID'] + '\',\'' + row['CashflowID'] + '\',\'' + row['CashflowDesc'] + '\')">Select</a>';
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