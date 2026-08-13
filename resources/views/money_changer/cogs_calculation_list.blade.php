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

        { data: 'JournalDesc', render:
            function( data, type, row )
            {
                if(row['JournalState'] == 'lengkap')
                {
                    return '<x-badge-success label="__LABEL__" />'.replace('__LABEL__', data);
                }
                else if(row['JournalState'] == 'sebagian')
                {
                    return '<x-badge-primary label="__LABEL__" />'.replace('__LABEL__', data);
                }

                return '<x-badge-secondary label="__LABEL__" />'.replace('__LABEL__', data);
            }
            , class: "text-center"
        },

        { data: 'COGSPeriod', render:
            function( data, type, row )
            {
                var url_report = '{{ url('mc-rpt-cogs-calculation') }}';
                var url_generate = '{{ url('mc-cogs-calculation/generate-journal') }}';

                var report = '<a href="' + url_report + '" class="btn btn-sm btn-info me-1">' +
                       '<i class="fas fa-file-alt me-1"></i>Lihat Laporan</a>';

                // Jurnal yang sudah ada akan ditimpa, jadi labelnya dibedakan
                var sudah_ada = (row['JournalState'] != 'kosong');

                var generate = '<a href="javascript:void(0)" class="btn btn-sm ' +
                       (sudah_ada ? 'btn-outline-success' : 'btn-success') + '" ' +
                       'onclick="generateJournal(\'' + url_generate + '\', \'' + row['COGSPeriod'] + '\')">' +
                       '<i class="fas fa-book me-1"></i>' +
                       (sudah_ada ? 'Generate Ulang' : 'Generate Journal') + '</a>';

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
