@extends('layouts.master-datatable')

@section('advance-search')
    <div class="row mb-3">
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Cabang</span> 
                <input id="branch_desc" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">No Pinjaman</span> 
                <input id="cont_contract_no" type="text" class="form-control" />
            </div>
        </div>
        <div class="col-4">
            <div class="input-group">
                <span class="input-group-text" id="inputGroup-sizing-default">Nama Anggota</span> 
                <input id="cust_name" type="text" class="form-control" />
            </div>
        </div>
    </div>
@endsection

@section('datatables_array')
    columns: [
        { data: 'RowNumber', name: 'DT_RowIndex' },
        { data: "IDX_T_Contract", visible: false },
        { data: "cont_branch_id", visible: false },
        { data: "branch_desc", visible: true },
        {{-- { data: "cont_contract_no", visible: true }, --}}

        { data: "cont_contract_no", render: 
            function ( data, type, row )
            {						  
                return '<a target="_blank" class="text-info" title="Kartu Piutang" href="{{ url('cf-loan-ar-eksternal') }}/' + row['IDX_T_Contract'] + '">' + data + '</a>';						
            }
        },

        { data: "cont_sales_date", visible: true },
        { data: "cont_commence_date", visible: false },
        { data: "cust_id", visible: false },
        { data: "cust_name", visible: true },
        { data: "mkt_name", visible: false },

        { "data": "cont_commence_amount", "bVisible": false, "bSearchable": true, "bSortable": true, "className": "dt-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        },

        { "data": "os_receivable", "bVisible": true, "bSearchable": true, "bSortable": true, "className": "dt-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        },

        { data: "cont_tenor", visible: true },        

        { "data": "cont_installment", "bVisible": true, "bSearchable": true, "bSortable": true, "className": "dt-right", 
          "render": function ( data, type, row ){								
                        return commaSeparateNumber(data); 
                    }
        }, 

        { data: "cont_status", visible: false },

        {{-- { data: "StatusDesc", visible: true }, --}}

        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                if(row['cont_status'] == 'P')
                {
                    return '<x-badge-danger label="Aplikasi" />';
                }
                else if(row['cont_status'] == 'V')
                {
                    return '<x-badge-info label="Disetujui" />';
                } 
                else if(row['cont_status'] == 'C')
                {
                    return '<x-badge-info label="Dicairkan" />';
                } 
                else if(row['cont_status'] == 'F')
                {
                    return '<x-badge-info label="Lunas" />';
                } 
                else if(row['cont_status'] == 'R')
                {
                    return '<x-badge-info label="Ditarik" />';
                } 
                else 
                {
                    return '<x-badge-danger label="Unknown" />';
                }                            
            }
            , class: "text-center"
        },

        { data: "Aging", visible: false },
        
        { data: "DisbursmentStatus", visible: true, "className": "dt-center", render: 
            function( data, type, row )
            {
                if(data == 'Sudah Dicairkan')
                {
                    return '<i class="fas fa-check text-info"></i>';
                }
                else 
                {
                    return '<i class="fas fa-times text-danger"></i>';
                }
            }
        },

        
        { data: "StatusDesc", render: 
            function( data, type, row )
            {	
                var url_update = '{{ $url_update }}' + '/' + row['IDX_T_Contract'];
                var url_payment = '{{ $url_payment }}' + '/' + row['IDX_T_Contract'];

                var edit = '<a class="btn btn-primary btn-icon btn-sm" href="' + url_update + '" title="Edit"><i class="fas fa-pencil-alt"></i></a>';
                var payment = '<a class="btn btn-success btn-icon btn-sm" href="' + url_payment + '" title="Input pembayaran"><i class="far fa-money-bill-alt"></i></a>';

                {{-- if(row['cont_status'] == 'V')
                {
                    return edit + payment;
                }
                else 
                {
                    return edit;
                } --}}
                
                return edit;

                {{-- @include('form_helper.url_edit')
                @include('form_helper.url_payment') --}}
            }
            , class: "text-center"
        }
    ]    
@endsection