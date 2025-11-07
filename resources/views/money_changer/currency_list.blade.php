@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Negara</span> 
                <input id="CountryName" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-6">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Currency</span> 
                <input id="CurrencyName" type="text" class="form-control" />
            </div>
        </div>        
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_M_Currency", visible: false },
        { data: "CurrencyID", visible: true },
        { data: "CurrencyName", visible: true },
        { data: "CountryID", visible: false },
        { data: "CountryName", visible: true },       

        { "data": "BuyRate", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 
        { "data": "SellRate", "bVisible": true, "bSearchable": true, "bSortable": true, "sClass": "text-end", 
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
                var url_update = '{{ $url_update }}' + '/' + row['IDX_M_Currency'];
                @include('form_helper.url_edit')                
            }
            , class: "text-center"
        }
    ]    
@endsection