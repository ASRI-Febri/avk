@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-mutation').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3 gap-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cari</span>
                <input id="SearchText" type="text" class="form-control" placeholder="Kode / nama aset / keterangan" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_AssetMutation", visible: false },
        { data: "IDX_M_Asset", visible: false },
        { data: "AssetCode" },
        { data: "AssetName" },
        { data: "MutationDate" },
        { data: "BranchFrom" },
        { data: "BranchTo" },
        { data: "DeptFrom", visible: false },
        { data: "DeptTo", visible: false },
        { data: "MutationNotes" },
        { data: "UCreate" }
    ]
@endsection
