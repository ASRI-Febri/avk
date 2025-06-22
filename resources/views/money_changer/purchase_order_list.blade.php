@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
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
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">No PO</span> 
                <input id="PONumber" type="text" class="form-control" />
            </div>
        </div>
    </div>
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Catatan PO</span> 
                <input id="PONotes" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
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

        { data: "IDX_T_PurchaseOrder", visible: false }, 
        { data: "CompanyName", visible: false }, 
        { data: "BranchName", visible: true },
        { data: "PONumber", visible: true,  "bSortable": false },
        { data: "PODate", visible: true },
        { data: "PartnerName", visible: true },
        { data: "PONotes", visible: true },
        { data: "POStatus", visible: false },
       
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['POStatus'] == 'D')
                {
                    return '<x-badge-danger label="Draft" />';
                }
                else if(row['POStatus'] == 'A')
                {
                    return '<x-badge-info label="Approved" />';
                }
                else if(row['POStatus'] == 'V')
                {
                    return '<x-badge-info label="Void" />';
                } 
                else if(row['POStatus'] == 'C')
                {
                    return '<x-badge-info label="Cancel" />';
                } 
                else if(row['POStatus'] == 'F')
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_PurchaseOrder'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection