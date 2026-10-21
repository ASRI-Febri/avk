@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-bs').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text">No Rekening Koran</span>
                <input id="StatementNo" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text">Financial Account</span>
                <input id="FinancialAccount" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text">No Rekening</span>
                <input id="AccountNo" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text">Periode (yyyy-mm)</span>
                <input id="Period" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_BankStatementHeader", visible: false },
        { data: "StatementNo", visible: true },
        { data: "FinancialAccount", visible: true },
        { data: "AccountNo", visible: true },
        { data: "PeriodStart", visible: true, "render":
            function( data, type, row )
            {
                return row['PeriodStart'] + ' s/d ' + row['PeriodEnd'];
            }
        },
        { data: "OpeningBalance", "sClass": "text-right", "render":
            function ( data, type, row ){
                return commaSeparateNumber(data);
            }
        },
        { data: "ClosingBalance", "sClass": "text-right", "render":
            function ( data, type, row ){
                return commaSeparateNumber(data);
            }
        },
        { data: "JournalCount", class: "text-center", "render":
            function ( data, type, row ){
                return row['JournalCount'] + ' / ' + row['LineCount'] + ' baris';
            }
        },
        { data: "IDX_T_BankStatementHeader", render:
            function( data, type, row )
            {
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_BankStatementHeader'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection
