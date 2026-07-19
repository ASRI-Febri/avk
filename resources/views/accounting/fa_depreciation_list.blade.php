@extends('layouts.master-datatable')

@section('active_link')
    $('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-depreciation').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3 gap-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Periode (YYYYMM)</span>
                <input id="DeprPeriod" type="text" class="form-control" maxlength="6" placeholder="Contoh: {{ date('Ym') }}" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: 'IDX_T_Depreciation', visible: false },
        { data: 'IDX_M_Company', visible: false },
        { data: 'DeprPeriod', visible: false },
        { data: 'PeriodDesc' },
        { data: 'TotalAsset', class: "text-right" },

        { data: 'TotalDepr', class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },
        { data: 'TotalFiscalDepr', class: "text-right", render:
            function( data, type, row )
            {
                return commaSeparateNumber(data);
            }
        },

        { data: 'DeprStatus', visible: false },
        { data: 'DeprStatusDesc', class: "text-center" },
        { data: 'JournalRef' },

        { data: 'DeprStatus', render:
            function( data, type, row )
            {
                var url_generate = '{{ url('ac-fa-depreciation/generate-journal') }}';
                var url_cancel = '{{ url('ac-fa-depreciation/cancel') }}';

                var buttons = '';

                if(row['DeprStatus'] == 'C')
                {
                    buttons += '<a href="javascript:void(0)" class="btn btn-sm btn-success me-1" ' +
                        'onclick="generateJournal(\'' + url_generate + '\', \'' + row['DeprPeriod'] + '\', \'' + row['IDX_M_Company'] + '\')">' +
                        '<i class="fas fa-book me-1"></i>Generate Journal</a>';

                    buttons += '<a href="javascript:void(0)" class="btn btn-sm btn-outline-danger" ' +
                        'onclick="cancelDepreciation(\'' + url_cancel + '\', \'' + row['DeprPeriod'] + '\', \'' + row['IDX_M_Company'] + '\')">' +
                        '<i class="fas fa-times me-1"></i>Batalkan</a>';
                }

                return buttons;
            }
            , class: "text-center"
        }
    ]
@endsection

@section('additional_script')
    function generateJournal(url, deprPeriod, companyId)
    {
        var data = {
            _token: '{{ csrf_token() }}',
            DeprPeriod: deprPeriod,
            IDX_M_Company: companyId
        };

        callAjaxModalView(url, data);
    }

    function cancelDepreciation(url, deprPeriod, companyId)
    {
        var data = {
            _token: '{{ csrf_token() }}',
            DeprPeriod: deprPeriod,
            IDX_M_Company: companyId
        };

        callAjaxModalView(url, data);
    }
@endsection
