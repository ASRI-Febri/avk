@extends('layouts.datatables')

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Branch", visible: false },          
        { data: "BranchID" },
        { data: "BranchName" },
        { data: "BranchAlias", visible: true },  
        { data: "BranchRemark", visible: true },  
        { data: "COASales", visible: false },  
        { data: "COAID", visible: true },  
        { data: "COADesc", visible: true },               

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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Branch'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection