@extends('layouts.master-datatable')

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_COAGroup1", visible: false },
        { data: "IDX_M_COAType", visible: false },          
        { data: "COATypeDesc" },
        { data: "COAGroup1ID" },
        { data: "COAGroup1Name1", visible: true },
        { data: "COAGroup1Name2", visible: false },               

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
        
        { data: "RecordStatus", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_COAGroup1'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection