@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    {{-- $('#nav-link-sbp-ul').css("display","block"); --}}
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-branch').addClass('mm-active');
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
        { data: "IDX_M_Branch", visible: false },          
        { data: "BranchID" },
        { data: "BranchName" },
        { data: "BranchAlias", visible: true },  
        { data: "BranchRemark", visible: true },  
        { data: "COASales", visible: false },  
        { data: "COAID", visible: true },  
        { data: "COADesc", visible: true },               

        { data: "RecordStatus", visible: false, render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'I')
                {
                    return '<span class="label label-danger"><strong>In-Active</strong></span>';
                }
                else if(row['RecordStatus'] == 'A')
                {
                    return '<span class="label label-info"><strong>Active</strong></span>';
                }                
            }
            , class: "text-center"
        },

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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Branch'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection