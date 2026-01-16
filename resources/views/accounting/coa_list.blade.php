@extends('layouts.master-datatable')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    {{-- $('#nav-link-sbp-ul').css("display","block"); --}}
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-coa').addClass('mm-active');
@endsection

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode CoA</span> 
                <input id="COAID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama CoA</span> 
                <input id="COADesc" type="text" class="form-control" />
            </div>
        </div>      
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama CoA 2</span> 
                <input id="COADesc2" type="text" class="form-control" />
            </div>
        </div> 
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Group CoA</span> 
                <input id="COAGroup1Name1" type="text" class="form-control" />
            </div>
        </div>  
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_COA", visible: false },          
        { data: "COAID" },
        { data: "COADesc" },
        { data: "COADesc2", visible: false }, 
        { data: "COAGroup1ID", visible: false }, 
        { data: "COAGroup1Name1", visible: true },               

        { data: "RecordStatus", visible: false, render: 
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_COA'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection