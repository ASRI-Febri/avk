@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-so').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        {{-- <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Perusahaan</span> 
                <input id="CompanyName" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cabang</span> 
                <input id="BranchName" type="text" class="form-control" />
            </div>
        </div> --}}
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">No Transaksi</span> 
                <input id="SONumber" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Keterangan</span> 
                <input id="SONotes" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Konsumen</span> 
                <input id="PartnerName" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },

        { data: "IDX_T_SalesOrder", visible: false }, 
        { data: "CompanyName", visible: false }, 
        { data: "BranchName", visible: false },
        { data: "SONumber", visible: true,  "bSortable": false },
        { data: "SODate", visible: true },
        { data: "PartnerName", visible: true },
        { data: "SONotes", visible: true },
        { data: "SOStatus", visible: false },
       
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['SOStatus'] == 'D')
                {
                    return '<x-badge-danger label="Draft" />';
                }
                else if(row['SOStatus'] == 'A')
                {
                    return '<x-badge-info label="Approved" />';
                }
                else if(row['SOStatus'] == 'V')
                {
                    return '<x-badge-info label="Void" />';
                } 
                else if(row['SOStatus'] == 'C')
                {
                    return '<x-badge-info label="Cancel" />';
                } 
                else if(row['SOStatus'] == 'F')
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_SalesOrder'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection