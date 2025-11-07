@extends('layouts.master-datatable')

@section('form_description')
    User ID list
@endsection 

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_User", visible: false }, 
        { data: "LoginID" },
        { data: "UserName" },
        { data: "UserAlias" },
       
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
        
        { data: "RecordStatus", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_User'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection