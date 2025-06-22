@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Mata Uang</span> 
                <input id="CurrencyName" type="text" class="form-control" />
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
        { data: "IDX_M_Valas", visible: false },  
        { data: "ValasSKU", visible: true },    
        { data: "EffectiveDate", visible: true },   
        { data: "CurrencyID", visible: true },
        { data: "CurrencyName", visible: true },
        { data: "ValasChangeName", visible: true },
        { data: "ValasChangeNumber", visible: true },        

        { "data": "BuyValue", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 

        { "data": "SellValue", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 

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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Valas'];
                var url_duplicate = '{{ $url_duplicate }}' + '/' + row['IDX_M_Valas'];

                var duplicate = '<a class="btn btn-outline-info btn-icon btn-sm" href="' + url_duplicate + '" title="Copy or duplicate"><i class="fas fa-copy"></i></a>';

                var edit = '<a class="btn btn-outline-primary btn-icon btn-sm" href="' + url_update + '" title="Edit"><i class="fas fa-pen"></i></a>';

                return '<div class="btn-group">' + edit + duplicate + '</div>';              
            }
            , class: "text-center"
        }
    ]    
@endsection