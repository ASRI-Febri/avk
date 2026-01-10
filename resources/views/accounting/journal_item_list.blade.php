@extends('layouts.master-datatable')

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Company", visible: false },
        { data: "CompanyName", visible: false },
        { data: "IDX_M_Branch", visible: false }, 
        { data: "BranchName", visible: false },
        { data: "IDX_T_JournalHeader", visible: false },
        { data: "IDX_T_JournalDetail", visible: false },
        { data: "IDX_M_Partner", visible: false },
        { data: "PartnerDesc", visible: true },
        { data: "VoucherNo", visible: true },
        { data: "JournalDate", visible: true },
        { data: "RemarkHeader", visible: false },
        { data: "PostingStatus", visible: false },        

        { data: "PostingStatusDesc", render: 
            function( data, type, row )
            {	
                if(row['PostingStatus'] == 'U')
                {
                    return '<x-badge-danger label="UnPosting" />';
                }
                else if(row['PostingStatus'] == 'P')
                {
                    return '<x-badge-info label="Posting" />';
                } 
                else 
                {
                    return '<x-badge-danger label="Unknown" />';
                }                            
            }
            , class: "text-center"
        },

        { data: "COAID", visible: true },
        { data: "COADesc", visible: true },
        { data: "COADesc2", visible: false },
        { data: "COADesc", RemarkDetail: true },
        { data: "OriginalCurrencyID", visible: false },
        { data: "ODebetAmount", visible: false },
        { data: "OCreditAmount", visible: false },
        { data: "BaseCurrencyID", visible: false },

        { "data": "BDebetAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 

        { "data": "BCreditAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        },
        
        { data: "PostingStatusDesc", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_JournalHeader'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]    
@endsection