@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-disposal').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3 gap-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cari</span>
                <input id="SearchText" type="text" class="form-control" placeholder="Kode / nama aset / keterangan" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Tipe</span>
                <select id="DisposalType" class="form-select">
                    @foreach($dd_disposal_type as $key => $val)
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
        { data: "IDX_T_AssetDisposal", visible: false },
        { data: "IDX_M_Asset", visible: false },
        { data: "AssetCode" },
        { data: "AssetName" },
        { data: "DisposalDate" },
        { data: "DisposalType", visible: false },
        { data: "DisposalTypeDesc", class: "text-center" },

        { data: "DisposalProceed", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },
        { data: "AccumDeprAtDisposal", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },
        { data: "BookValueAtDisposal", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },
        { data: "GainLossAmount", class: "text-right", render:
            function( data, type, row )
            {
                var val = commaSeparateNumber(data);
                if (parseFloat(data) < 0)
                {
                    return '<span class="text-danger">' + val + '</span>';
                }
                return val;
            }
        },
        { data: "JournalRef" }
    ]
@endsection
