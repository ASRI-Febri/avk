@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-fp').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode Pembayaran</span> 
                <input id="PaymentID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Keterangan</span> 
                <input id="RemarkHeader" type="text" class="form-control" />
            </div>
        </div> 
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">No Rekening</span> 
                <input id="FinancialAccountID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Business Partner</span> 
                <input id="PartnerName" type="text" class="form-control" />
            </div>
        </div>  
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_FinancialPaymentHeader", visible: false },
        { data: "IDX_M_Company", visible: false },
        { data: "IDX_M_Branch", visible: false }, 

        { data: "CompanyName", visible: true },
        { data: "PaymentID", visible: true },
        { data: "VoucherNoManual", visible: true },
        { data: "FinancialAccountID", visible: true },
        { data: "PDCNo", visible: true },
        { data: "PaymentDate", visible: true },
        { data: "PartnerName", visible: true },

        { "data": "PaymentAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 

        { data: "RemarkHeader", visible: true },
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_FinancialPaymentHeader'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]

    {{-- $this->array_column = array('RowNumber', 'IDX_T_FinancialPaymentHeader', 'IDX_M_Company', 'IDX_M_Branch', 'PaymentID', 'FinancialAccountID',
         'PDCNo', 'PaymentDate', 'PartnerName', 'PaymentAmount', 'RemarkHeader', 'StatusDesc'); --}}
@endsection