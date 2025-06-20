@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode</span> 
                <input id="ValasChangeID" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Pecahan</span> 
                <input id="ValasChangeName" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nilai Pecahan</span> 
                <input id="ValasChangeNumber" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_ValasChange", visible: false },
        { data: "ValasChangeID", visible: true },
        { data: "ValasChangeName", visible: true },
        { data: "ValasChangeNumber", visible: true },        

        { data: "RecordStatus", visible: false },

        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['RecordStatus'] == 'A')
                {
                    return '<x-badge-info label="Active" />';
                }               
                else 
                {
                    return '<x-badge-danger label="InActive" />';
                }                            
            }
            , class: "text-center"
        },
        
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	 
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_ValasChange'];
                @include('form_helper.url_edit')                
            }
            , class: "text-center"
        }
    ]    
@endsection