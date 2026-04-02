@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-bank').addClass('mm-active');
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Bank", visible: false },          
        { data: "BankCode" },
        { data: "BankName" },
        { data: "BankAlias", visible: true },               

        { data: "RecordStatus", visible: false, render: 
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Bank'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection