@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-recurring-journal').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-12">
            <a href="javascript:void(0)" class="btn btn-success me-1" onclick="generateRecurring()">
                <i class="fas fa-cogs me-1"></i> Proses Periode
            </a>
            <a href="{{ url('ac-recurring-journal-log') }}" class="btn btn-info">
                <i class="fas fa-history me-1"></i> Log Generate
            </a>
        </div>
    </div>
    <div class="row mb-3 gap-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cari</span>
                <input id="SearchText" type="text" class="form-control" placeholder="Kode / nama template" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Status</span>
                <select id="RecurringStatus" class="form-select">
                    <option value="">--SEMUA--</option>
                    <option value="A">Aktif</option>
                    <option value="I">Non-Aktif</option>
                </select>
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_RecurringJournal", visible: false },
        { data: "RecurringCode" },
        { data: "RecurringName" },
        { data: "BranchName", visible: false },
        { data: "COADebet" },
        { data: "COACredit" },

        { data: "RecurringAmount", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },

        { data: "TotalAmount", class: "text-right", render:
            function( data, type, row )
            {
                return parseFloat(data) > 0 ? commaSeparateNumber(data) : '-';
            }
        },

        { data: "AdjustLastPeriodDesc", class: "text-center" },

        { data: "StartPeriod", class: "text-center" },
        { data: "EndPeriod", class: "text-center" },
        { data: "LastPeriod", class: "text-center" },

        { data: "RecurringStatus", visible: false },
        { data: "RecurringStatusDesc", class: "text-center" },

        { data: "RecurringStatus", render:
            function( data, type, row )
            {
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_RecurringJournal'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection

@section('additional_script')
    function generateRecurring()
    {
        var data = {
            _token: '{{ csrf_token() }}'
        };

        callAjaxModalView('{{ url('ac-recurring-journal/generate') }}', data);
    }
@endsection
