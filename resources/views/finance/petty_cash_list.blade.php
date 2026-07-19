@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-pc').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Transaction ID</span>
                <input id="TransactionID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Opening Date</span>
                <input id="OpeningDate" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Description</span>
                <input id="TransactionDesc" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Perusahaan</span>
                <input id="CompanyName" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_PettyCashHeader", visible: false },
        { data: "IDX_M_Company", visible: false },
        { data: "IDX_M_Branch", visible: false },

        { data: "CompanyName", visible: false },
        { data: "TransactionID", visible: true, "render":
            function( data, type, row )
            {
                return row['TransactionID'] + '<br><small class="text-muted">' + row['OpeningDate'] + '</small>';
            }
        },
        { data: "OpeningDate", visible: false },
        { data: "TransactionDesc", visible: true },
        { data: "CashierName", visible: true },

        { "data": "TotalAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-right",
          "render": function ( data, type, row ){
                        return commaSeparateNumber(data);
                    }
        },

        { data: "StatusDesc", render:
            function( data, type, row )
            {
                if(row['StatusDesc'] == 'Open')
                {
                    return '<x-badge-danger label="Open" />';
                }
                else if(row['StatusDesc'] == 'Closed')
                {
                    return '<x-badge-info label="Closed" />';
                }
                else
                {
                    return '<x-badge-secondary label="Unknown" />';
                }
            }
            , class: "text-center", visible: true
        },

        { data: "StatusDesc", render:
            function( data, type, row )
            {
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_PettyCashHeader'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection
