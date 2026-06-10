@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-fr').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Receive ID</span>
                <input id="ReceiveID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Receive Date</span>
                <input id="ReceiveDate" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode FA</span>
                <input id="FinancialAccountID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Partner</span>
                <input id="PartnerName" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Voucher No Manual</span>
                <input id="VoucherNoManual" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Perusahaan</span>
                <input id="CompanyName" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Receive Amount</span>
                <input id="ReceiveAmount" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Remark</span>
                <input id="RemarkHeader" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_FinancialReceiveHeader", visible: false },
        { data: "IDX_M_Company", visible: false },
        { data: "IDX_M_Branch", visible: false }, 

        { data: "CompanyName", visible: false },
        { data: "ReceiveID", visible: true, "render":
            function( data, type, row )
            {
                return row['ReceiveID'] + '<br><small class="text-muted">' + row['ReceiveDate'] + '</small>';
            }
        },
        { data: "VoucherNoManual", visible: false },
        { data: "FinancialAccountID", visible: true },
        { data: "ReceiveDate", visible: false },
        { data: "PartnerName", visible: true },

        { "data": "ReceiveAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-right", 
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_FinancialReceiveHeader'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection