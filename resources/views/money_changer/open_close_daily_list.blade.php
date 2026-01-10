@extends('layouts.master-datatable')

@section('advance-search')    
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Tanggal</span> 
                <input id="TransactionDate" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Teller</span> 
                <input id="TellerName" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },

        { data: "IDX_T_OpenCloseDaily", visible: false }, 
        { data: "TransactionDate", visible: true }, 
        { data: "TransactionStatus", visible: false },

        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['TransactionStatus'] == 'O')
                {
                    return '<x-badge-danger label="Open" />';
                }               
                else 
                {
                    return '<x-badge-secondary label="Close" />'; 
                }               
            }
            , class: "text-center", visible: true 
        },

        { data: "TellerID", visible: true },
        { data: "RecordStatus", visible: false },
        { data: "TellerName", visible: true },
        
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_OpenCloseDaily'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection