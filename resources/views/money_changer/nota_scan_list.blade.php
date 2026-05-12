@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-nota-scan').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-2">
        <div class="col-md-3">
            <input type="text" id="SearchText" name="SearchText"
                class="form-control" placeholder="No Nota / Keterangan" />
        </div>
        <div class="col-md-2">
            <select id="TipeTransaksi" class="form-control">
                <option value="">-- Semua Tipe --</option>
                <option value="J">Jual (SO)</option>
                <option value="B">Beli (PO)</option>
            </select>
        </div>
        <div class="col-md-2">
            <input type="text" id="DateFrom" name="DateFrom"
                class="form-control datepicker2" placeholder="Dari Tanggal" />
        </div>
        <div class="col-md-2">
            <input type="text" id="DateTo" name="DateTo"
                class="form-control datepicker2" placeholder="Sampai Tanggal" />
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber',        name: 'RowNumber',        orderable: false, searchable: false },
        { data: 'TipeTransaksiDesc',name: 'TipeTransaksiDesc' },
        { data: 'TanggalNota',      name: 'TanggalNota' },
        { data: 'NoNota',           name: 'NoNota' },
        { data: 'Keterangan',       name: 'Keterangan' },
        { data: 'FileName',         name: 'FileName' },
        { data: 'StatusDesc',       name: 'StatusDesc' },
        { data: 'Action',           name: 'Action', orderable: false, searchable: false },
    ],
@endsection
