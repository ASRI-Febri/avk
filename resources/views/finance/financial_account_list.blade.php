@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode FA</span> 
                <input id="FinancialAccountID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama FA</span> 
                <input id="FinancialAccountDesc" type="text" class="form-control" />
            </div>
        </div> 
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">No Rekening</span> 
                <input id="AccountNo" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama di Rekening</span> 
                <input id="AccountName" type="text" class="form-control" />
            </div>
        </div>  
    </div>
@endsection


@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_FinancialAccount", visible: false }, 

        { data: "FinancialAccountID", visible: true },
        { data: "FinancialAccountDesc", visible: true },
        { data: "AccountNo", visible: true },
        { data: "AccountName", visible: true },
        { data: "StatusDesc", visible: true },
        
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_FinancialAccount'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection