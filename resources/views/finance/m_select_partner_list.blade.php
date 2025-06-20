@extends('layouts.master-datatable-modal')

@section('datatables_array')

    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Partner", visible: false },
        { data: "PartnerID", visible: true },
        { data: "PartnerName", visible: true },
        { data: "IsCustomer", visible: true },
        { data: "IsSupplier", visible: true },
        { data: "Remarks", visible: true },
        { data: "BarcodeMember", visible: false },
        { data: "SingleIdentityNumber", visible: false },
        { data: "Street", visible: true },
        {{-- { data: "PartnerType", visible: false }, --}}
        { data: "StatusDesc", visible: true },

        { render: 
            function ( data, type, row )
            {						  																		
                return '<a href="#" title="Select" class="text-primary" onClick="getSelected(\'' +  row['IDX_M_Partner'] + '\',\'' + row['PartnerID'] + '\',\'' + row['PartnerName'] + '\')">Select</a>';
            }, "sClass": "text-center"
        }
    ]

@endsection

@section('script')

    function getSelected(idx,id,name)
    {	
        @if($target_index !== '')        
        $('#{{ $target_index }}').val(idx);
        @endif

        @if($target_name !== '')        
        $('#{{ $target_name }}').val(id + ' - ' + name);
        @endif

        $('#div-form-modal').modal('hide');
    }

@endsection    