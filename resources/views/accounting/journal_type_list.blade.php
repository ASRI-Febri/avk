@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-journal-type').addClass('mm-active');
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_JournalType", visible: false },
        { data: "JournalTypeID" },
        { data: "JournalTypeDesc" },

        { data: "AllowJournalEntry", visible: false },

        { data: "AllowJournalEntryDesc", render:
            function( data, type, row )
            {
                if(row['AllowJournalEntry'] == 'Y')
                {
                    return '<x-badge-info label="Yes" />';
                }
                else
                {
                    return '<x-badge-secondary label="No" />';
                }
            }
            , class: "text-center"
        },

        { data: "JournalLabel" },

        { data: "RecordStatus", visible: false },

        { data: "StatusDesc", render:
            function( data, type, row )
            {
                if(row['RecordStatus'] == 'I')
                {
                    return '<x-badge-danger label="In-Active" />';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<x-badge-info label="Active" />';
                }
            }
            , class: "text-center"
        },

        { data: "RecordStatus", render:
            function( data, type, row )
            {
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_JournalType'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection
