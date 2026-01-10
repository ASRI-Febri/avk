@extends('layouts.master-datatable-modal')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode Konsumen</span> 
                <input id="PartnerID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Konsumen</span> 
                <input id="PartnerName" type="text" class="form-control" />
            </div>
        </div>  
    </div>
@endsection

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Partner", visible: false },   
        { data: "BarcodeMember", visible: false }, 
        { data: "PartnerID" },
        { data: "PartnerName", visible: true },
        { data: "IsCustomer", visible: false },
        { data: "IsMember", visible: false },
        { data: "IsSupplier", visible: false },        
        { data: "SingleIdentityNumber", visible: true }, 
        { data: "TaxIdentityNumber", visible: true },
        { data: "MobilePhone", visible: false },   
        { data: "Remarks", visible: false },                          
        { data: "Street", visible: false }, 
        { data: "ActiveDesc", visible: false }, 
       
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                return '<span class="badge badge-info">' + data + '</span>';            
            }
            , class: "text-center"
        },

        { render: 
            function ( data, type, row )
            {						  																		
                return '<a href="#" title="Select" class="text-primary" onClick="getSelected(\'' +  row['IDX_M_Partner'] + '\',\'' + row['PartnerID'] + '\',\'' + row['PartnerName'] + '\')">Select</a>';
            }, "sClass": "text-center"
        }
    ]

@endsection

@section('script')

    function getSelected(idx,partner_id,partner_name)
    {	
        @if($target_index !== '')        
        $('#{{ $target_index }}').val(idx);
        @endif

        @if($target_name !== '')        
        $('#{{ $target_name }}').val(partner_id + ' - ' + partner_name);
        @endif

        $('#div-form-modal').modal('hide');
    }

@endsection    