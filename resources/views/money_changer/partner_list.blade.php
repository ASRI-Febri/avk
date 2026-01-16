@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');    
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-customer').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Partner</span> 
                <input id="PartnerName" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">No KTP</span> 
                <input id="SingleIdentityNumber" type="text" class="form-control" />
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
        { data: "TaxIdentityNumber", visible: false },
        { data: "MobilePhone", visible: false },   
        { data: "Remarks", visible: false },                          
        { data: "Street", visible: true }, 
        { data: "ActiveDesc", visible: false }, 
       
        { data: "ActiveDesc", render: 
            function( data, type, row )
            {	
                if(row['ActiveDesc'] == 'Inactive')
                {
                    return '<x-badge-danger label="In-Active" />';
                }
                else if(row['ActiveDesc'] == 'Active')
                {
                    return '<x-badge-info label="Active" />';
                }               
            }
            , class: "text-center"
        },
        
        { data: "ActiveDesc", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Partner'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection