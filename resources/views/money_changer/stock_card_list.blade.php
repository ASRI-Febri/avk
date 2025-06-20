@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Lokasi</span> 
                <input id="BranchName" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Kode Valas</span> 
                <input id="ValasSKU" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Valas</span> 
                <input id="ValasName" type="text" class="form-control" />
            </div>
        </div>
    </div>
    
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },

        { data: "IDX_M_Valas", visible: false },         
        { data: "BranchID", visible: true },
        { data: "BranchName", visible: true },
        { data: "ValasSKU", visible: true,  "bSortable": false },
        { data: "ValasName", visible: true },
        
        { "data": "StockInQty", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
       { "data": "StockInForeignAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        { "data": "StockOutQty", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        { "data": "StockOutForeignAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        { "data": "BalanceQty", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        { "data": "BalanceForeignAmount", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        
        
        { data: "IDX_M_Valas", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Valas'];
                @include('form_helper.url_edit')
            }
            , class: "text-center"
        }
    ]
@endsection