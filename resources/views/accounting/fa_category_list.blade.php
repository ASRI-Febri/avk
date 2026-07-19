@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-fa-category').addClass('mm-active');
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_AssetCategory", visible: false },
        { data: "CategoryCode" },
        { data: "CategoryName" },
        { data: "COAAsset" },
        { data: "COAAccumDepr", visible: false },
        { data: "COADeprExpense", visible: false },
        { data: "DefaultUsefulLifeMonth", class: "text-right" },
        { data: "DeprMethodDesc" },
        { data: "FiscalGroupDesc", visible: false },

        { data: "RecordStatus", visible: false },

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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_AssetCategory'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection
