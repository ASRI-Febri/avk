@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-dttot').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama</span>
                <input id="FullName" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode Densus</span>
                <input id="DensusCode" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_DTTOT", visible: false },
        { data: "FullName" },

        { data: "Description", render:
            function( data, type, row )
            {
                if (data && data.length > 100) {
                    return '<span title="' + $('<div/>').text(data).html() + '">' + $('<div/>').text(data.substring(0, 100)).html() + '...</span>';
                }
                return $('<div/>').text(data || '').html();
            }
        },

        { data: "SuspectType", class: "text-center" },
        { data: "DensusCode", class: "text-center" },
        { data: "PlaceOfBirth", visible: false },
        { data: "DateOfBirth", class: "text-center" },
        { data: "Nationality" },

        { data: "Address", render:
            function( data, type, row )
            {
                if (data && data.length > 80) {
                    return '<span title="' + $('<div/>').text(data).html() + '">' + $('<div/>').text(data.substring(0, 80)).html() + '...</span>';
                }
                return $('<div/>').text(data || '').html();
            }
        },

        { data: "FileName", visible: false },
        { data: "UploadDate", class: "text-center" }
    ]
@endsection
