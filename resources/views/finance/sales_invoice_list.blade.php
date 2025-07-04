@extends('layouts.datatables')

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_SalesInvoiceHeader", visible: false }, 

        { data: "CompanyName", visible: true },
        { data: "ProjectID", visible: true },
        { data: "ProjectName", visible: true,  "bSortable": false },
        { data: "InvoiceNo", visible: true },
        { data: "PartnerName", visible: true },
        { data: "InvoiceDate", visible: true },
        { data: "InvoiceDueDate", visible: false },
        { data: "RemarkHeader", visible: true },

        {{-- { "data": "DetailAmount", "bVisible": true, "bSearchable": true, "bSortable": false, "sClass": "text-right", 
        "render": function ( data, type, row ){								
                      return commaSeparateNumber(data); 
                  }
        }, --}}
        { "data": "TotalInvoice", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        },
        { "data": "ReceiveAmount", "bVisible": true, "bSearchable": true, "bSortable": false, "sClass": "text-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        { "data": "Outstanding", "bVisible": true, "bSearchable": true, "bSortable": false, "sClass": "text-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 

        {{-- { data: "StatusDesc", visible: true }, --}}
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['StatusDesc'] == 'Draft')
                {
                    return '<x-badge-danger label="Draft" />';
                }
                else if(row['StatusDesc'] == 'Approved')
                {
                    return '<x-badge-info label="Approved" />';
                }
                else if(row['StatusDesc'] == 'Void')
                {
                    return '<x-badge-danger label="Void" />';
                } 
                else if(row['StatusDesc'] == 'Cancel')
                {
                    return '<x-badge-info label="Cancel" />';
                } 
                else if(row['StatusDesc'] == 'Validate')
                {
                    return '<x-badge-info label="Validate" />';
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_SalesInvoiceHeader'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection