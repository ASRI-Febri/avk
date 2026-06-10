@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-cogs-calculation').addClass('mm-active');
@endsection

@section('advance-search')
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: 'COGSPeriod', visible: false },
        { data: 'PeriodDesc', visible: true },

        { data: 'COGSPeriod', render:
            function( data, type, row )
            {
                var url_report = '{{ url('mc-rpt-cogs-calculation') }}';
                var url_generate = '{{ url('mc-cogs-calculation/generate-journal') }}';

                var report = '<a href="' + url_report + '" class="btn btn-sm btn-info me-1">' +
                       '<i class="fas fa-file-alt me-1"></i>Lihat Laporan</a>';

                var generate = '<a href="javascript:void(0)" class="btn btn-sm btn-success" ' +
                       'onclick="generateJournal(\'' + url_generate + '\', \'' + row['COGSPeriod'] + '\')">' +
                       '<i class="fas fa-book me-1"></i>Generate Journal</a>';

                return report + generate;
            }
            , class: "text-center"
        }
    ]
@endsection

@section('additional_script')
    function generateJournal(url, cogsPeriod)
    {
        var data = {
            _token: '{{ csrf_token() }}',
            COGSPeriod: cogsPeriod
        };

        callAjaxModalView(url, data);
    }
@endsection
