@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-recurring-journal').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-12">
            <a href="{{ url('ac-recurring-journal') }}" class="btn btn-secondary">
                <i class="fas fa-arrow-left me-1"></i> Kembali ke Daftar Template
            </a>
        </div>
    </div>
    <div class="row mb-3 gap-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cari</span>
                <input id="SearchText" type="text" class="form-control" placeholder="Kode / nama / no jurnal" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Periode (YYYYMM)</span>
                <input id="RecurringPeriod" type="text" class="form-control" maxlength="6" placeholder="Contoh: {{ date('Ym') }}" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_RecurringJournalLog", visible: false },
        { data: "IDX_M_RecurringJournal", visible: false },
        { data: "RecurringCode" },
        { data: "RecurringName" },
        { data: "RecurringPeriod", class: "text-center" },

        { data: "GeneratedAmount", class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },

        { data: "JournalRef" },
        { data: "JournalDate" },
        { data: "PostingStatusDesc", class: "text-center" },
        { data: "GeneratedBy" },
        { data: "GeneratedDate" }
    ]
@endsection
