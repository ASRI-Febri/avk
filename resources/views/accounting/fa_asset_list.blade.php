@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-asset').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3 gap-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cari</span>
                <input id="SearchText" type="text" class="form-control" placeholder="Kode / nama aset / referensi" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kategori</span>
                <select id="IDX_M_AssetCategory" class="form-select">
                    @foreach($dd_asset_category as $key => $val)
                    <option value="{{ $key }}">{{ $val }}</option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Status Aset</span>
                <select id="AssetStatus" class="form-select">
                    @foreach($dd_asset_status as $key => $val)
                    <option value="{{ $key }}">{{ $val }}</option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cabang</span>
                <select id="IDX_M_Branch" class="form-select">
                    @foreach($dd_branch as $key => $val)
                    <option value="{{ $key }}">{{ $val }}</option>
                    @endforeach
                </select>
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Asset", visible: false },
        { data: "IDX_M_Company", visible: false },
        { data: "IDX_M_Branch", visible: false },
        { data: "BranchName" },
        { data: "IDX_M_AssetCategory", visible: false },
        { data: "CategoryName" },
        { data: "AssetCode" },
        { data: "AssetName" },
        { data: "AcquisitionDate" },

        { data: "AcquisitionCost", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },
        { data: "AccumDepr", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },
        { data: "BookValue", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },

        { data: "AssetStatus", visible: false },

        { data: "AssetStatusDesc", class: "text-center" },

        { data: "AssetStatus", render:
            function( data, type, row )
            {
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Asset'];
                var buttons = '<a href="' + url_update + '">' +
                    '<button class="btn btn-sm btn-outline-primary me-1" title="Edit"><i class="fas fa-edit"></i></button></a>';

                if(row['AssetStatus'] == 'A')
                {
                    buttons += '<a href="{{ url('ac-fa-mutation/create') }}/' + row['IDX_M_Asset'] + '">' +
                        '<button class="btn btn-sm btn-outline-info me-1" title="Mutasi Aset"><i class="fas fa-exchange-alt"></i></button></a>';

                    buttons += '<a href="{{ url('ac-fa-disposal/create') }}/' + row['IDX_M_Asset'] + '">' +
                        '<button class="btn btn-sm btn-outline-danger" title="Pelepasan Aset"><i class="fas fa-sign-out-alt"></i></button></a>';
                }

                return buttons;
            }
            , class: "text-center"
        }
    ]
@endsection
