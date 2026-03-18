@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-po').addClass('mm-active');
@endsection

@section('form-remark')
    Input / edit pembelian valuta asing dari konsumen atau supplier (purchase order). 
    <br> 
    Contoh nomor PO <code>PO-100-2506-001</code> untuk kode cabang 100, bulan 05 tahun 2025.
@endsection

@section('action')

    @if($state <> 'create')
    <x-btn-action>
        
        @if($fields->POStatus == 'D')
        <a id="btn-approval" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i> 
            </div>
            <span class="dropdown-content">Approval</span>            
        </a>
        @endif

        @if($fields->POStatus == 'A')
        <a id="btn-reverse" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i> 
            </div>
            <span class="dropdown-content">Reverse to Draft</span> 
        </a>
        @endif

        <div class="dropdown-divider"></div>   

        <a href="{{ url('mc-purchase-order/download-pdf').'/'.$fields->IDX_T_PurchaseOrder }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i>
            </div> 
            <span class="dropdown-content">Print Pembelian</span>            
        </a>        
    </x-btn-action>
    @endif

@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_PurchaseOrder" name="IDX_T_PurchaseOrder" value="{{ $fields->IDX_T_PurchaseOrder }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="POStatus" name="POStatus" value="{{ $fields->POStatus }}"/>
    <input type="hidden" id="IDX_M_Company" name="IDX_M_Company" value="{{ $fields->IDX_M_Company }}"/>
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $fields->IDX_M_Branch }}"/>

    @if($state <> 'create')
        <h5 class="text-secondary">{{ $fields->PONumber . ' - ' . $fields->StatusDesc }}</h5>
    @endif

    <div class="row">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">General</h3>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-3">
                        {{-- <x-select-horizontal label="Perusahaan" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                        <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/> --}}
                        <x-textbox-horizontal label="No Nota" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="(No nota)" class="" />
                    </div>
                </div>
            </div>            
        </div>
        <div class="col-md-6">

            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Informasi Pembelian</h3>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-3">
                        <x-textbox-horizontal label="No System" id="PONumber" :value="$fields->PONumber" placeholder="(Auto)" class="readonly" />
                        <x-textbox-horizontal label="Tanggal Pembelian" id="PODate" :value="$fields->PODate" placeholder="" class="required datepicker2" />
                        <x-lookup-horizontal label="Beli Dari" id="PartnerDesc" :value="$fields->PartnerDesc" class="required"  button="btn-find-partner"/>                        
                        <x-textbox-horizontal label="Keterangan" id="PONotes" :value="$fields->PONotes" placeholder="" class="required" />
                    </div>
                </div>
            </div> 
            
        </div>
    </div>
    <hr>
    @if($fields->POStatus == 'D')
    <div class="row"> 
        <div class="col-12 mb-2">           
            @include('form_helper.btn_save_header')
        </div>
    </div>
    @endif
    
    @if($state != 'create')          
        <div class="card border">
            <div class="card-header">      
                <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
                    <a class="nav-item nav-link active" id="card-detail-tab" data-bs-toggle="tab" href="#card-detail" aria-selected="false" role="tab" tabindex="-1">
                        <i class="fas fa-align-justify"></i> Detail Pembelian
                    </a>    
                    <a class="nav-item nav-link" id="card-payment-tab" data-bs-toggle="tab" href="#card-payment" aria-selected="true" role="tab">
                        <i class="fas fa-coins"></i> Pembayaran
                    </a> 
                    <a class="nav-item nav-link" id="card-upload-tab" data-bs-toggle="tab" href="#card-upload" aria-selected="true" role="tab">
                        <i class="fas fa-file"></i> Upload Dokumen
                    </a>
                    <a class="nav-item nav-link" id="card-log-tab" data-bs-toggle="tab" href="#card-log" aria-selected="true" role="tab">
                        <i class="fas fa-list"></i> Log
                    </a>        
                </div>
            </div>
            <div class="card-body">
                <div class="tab-content">
                    <div class="tab-pane fade active show" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">                        
                        @if($fields->POStatus == 'D')                
                            <x-btn-add-detail id="btn-add-detail" label="Input Valas" />                        
                        @endif
            
                        <div id="table-order-detail" class="table-responsive">
                            @include('money_changer.purchase_order_detail_list')            
                        </div>
                    </div>
                    <div class="tab-pane fade" id="card-payment" role="tabpanel" aria-labelledby="#card-payment-tab">
                        
                        @if($fields->POStatus == 'A')
                        <x-btn-add-detail id="btn-add-payment" label="Input Pembayaran" />
                        @endif
                        
                        <div id="table-order-payment" class="table-responsive">
                            @include('money_changer.purchase_order_payment_list')  
                        </div>
                    </div>

                    <div class="tab-pane fade" id="card-upload" role="tabpanel" aria-labelledby="#card-upload-tab">
                        <div class="card">
                            <div class="card-body">
                                <div class="row form-group">
                                    <div class="col-sm-6">
                                        <x-select-horizontal label="Kategori Dokumen" id="UploadCategory" value="" class="required" :array="$dd_upload_category"/>                                        
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="d-grid gap-3">
                                            
                                            <input id="UploadFile" name="UploadFile" type="file" class="form-control">
                                        </div>
                                    </div>
                                </div>

                                <hr>

                                <div class="form-group row">
                                    <div class="col-sm-12">
                                        <button type="button" class="btn btn-outline-dark" id="btn-upload">
                                            <i class="fas fa-upload fs-4 me-2"></i> Upload File
                                        </button>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <div class="col-sm-12">
                                        <hr>
                                        <span><b>Daftar file yang sudah diupload</b></span>
                                        

                                        <div id="div-upload" class="table-responsive">
                                            @include('money_changer.purchase_order_upload_list')  
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="card-log" role="tabpanel" aria-labelledby="#card-log-tab">         
                        <div class="form-group row mb-2">
                            <div class="col-md-6">
                                <x-textbox-horizontal label="Dibuat oleh" id="UCreate" :value="$fields->UCreate" placeholder="" class="" />
                            </div>
                            <div class="col-md-6">
                                <x-textbox-horizontal label="Tanggal Input" id="DCreate" :value="$fields->DCreate" placeholder="" class="" />
                            </div>
                        </div>  
                        <div class="form-group row">
                            <div class="col-md-6">
                                <x-textbox-horizontal label="Edit terakhir oleh" id="UModified" :value="$fields->UModified" placeholder="" class="" />
                            </div>
                            <div class="col-md-6">
                                <x-textbox-horizontal label="Tanggal Edit" id="DModified" :value="$fields->DModified" placeholder="" class="" />
                            </div>
                        </div>             
                        
                    </div>
                </div>
            </div>
        </div>
    @endif                 

@endsection

@section('script')

    <script>

        function deleteDetail(idx,item_description)
        {
            alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseOrderDetail": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Edit ' + idx);
            var url = "{{ url('mc-purchase-order-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseOrderDetail": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function deleteTax(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-tax/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseInvoiceTax": idx,
                "ItemDesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function addTax(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-tax/create') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),                     
            }
            
            callAjaxModalView(url,data);
        }

        function editTax(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('mc-purchase-order-tax/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_PurchaseOrder": $("#IDX_T_PurchaseOrder").val(),
                "IDX_T_PurchaseInvoiceTax": idx            
            }
            
            callAjaxModalView(url,data);
        }

        $(document).ready(function(){

            $('#btn-find-partner').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_Partner',
                    target_name: 'PartnerDesc'                  
                }              

                callAjaxModalView('{{ url('/gn-select-partner') }}',data);                
            });

            $('#btn-find-coa').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_COA',
                    target_name: 'COAHeader'                  
                }              

                callAjaxModalView('{{ url('/fm-select-coa') }}',data);                
            });

            // $( "#InvoiceDate, #InvoiceDueDate" ).datepicker({ dateFormat: 'yy-mm-dd' });

            $('#btn-add-detail').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order-detail/create') }}',data);            
            });

            $('#btn-add-tax').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order-tax/create') }}',data);            
            });
            
            $('#btn-add-payment').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order-payment/create') }}',data);            
            });

            $('#btn-approval').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order/approve') }}',data);            
            });

            $('#btn-reverse').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order/reverse') }}',data);            
            });

            // $("#ReferenceNo").autocomplete({                
                
            //     source: function( request, response ){
            //         $.ajax( {
            //         url: "{{ url('/fm-purchase-order/search') }}",
            //         dataType: "json",
            //         type: "POST",
            //         data: {
            //             q: request.term,
            //             _token: $('#_token').val()
            //         },
            //         success: function(data){					
            //             response( data );
            //         }
            //         });
            //     },			
            //     minLength: 3,
            //     select: function( event, ui )
            //     {  
            //         $("#ReferenceNo").text(ui.item.ReferenceNo);
            //     }
            // });  

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_PurchaseOrder: $("#IDX_T_PurchaseOrder").val(),
                }                

                callAjaxModalView('{{ url('mc-purchase-order/duplicate') }}',data);            
            });

            $("#btn-upload").click(function()
            {       
                //alert('upload'); 
                //$("#form-upload").submit(); // Submit the form

                if($('#UploadCategory').val() == ''){
                    //alert('Upload Category Belum Diisi!');

                    Swal.fire({
						title: "Error!",
						html: "<p>Upload category belum diisi!</p>",
						icon: "error",
						confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
						confirmButtonClass: "btn btn-danger",
					});

                    return false;
                }

                url = "{{ url('mc-purchase-order-upload') }}";

                //alert(url);

                // Get form
                //var form = $('#form-entry')[0];

                // Create an FormData object 
                //var data = new FormData(form);

                var myFormData = new FormData();

                myFormData.append('_token', $("#_token").val());
                myFormData.append('IDX_T_PurchaseOrder', $("#IDX_T_PurchaseOrder").val());
                myFormData.append('PONumber', $("#PONumber").val());
                myFormData.append('UploadCategory', $("#UploadCategory").val());
                myFormData.append('UploadFile', $('#UploadFile')[0].files[0]);

                // var data = {                
                //     _token:$("#_token").val(),
                //     flatrate: $("#cont_flat_rate").val(),
                //     tenor: $("#cont_tenor").val(),
                //     tenor_type: $("#cont_tenor_type").val(),
                //     principal: $("#cont_collateral_amount").val(),
                //     commence_date: $("#cont_commence_date").val()
                // };

                $.ajax({
                    type: "POST",
                    enctype: 'multipart/form-data',     
                    processData: false,  // Important!
                    contentType: false,
                    cache: false,			               
                    url: url,
                    data: myFormData,
                    // data: {
                    //     _token:$("#_token").val(),                        
                    //     IDX_T_Contract: $("#IDX_T_Contract").val(),
                    //     cont_contract_no: $("#cont_contract_no").val(),
                    //     UploadCategory: $("#UploadCategory").val(),
                    //     UploadFile: $('#UploadFile')[0].files[0],                        
                    // }, 
                    success: function(data)
                    {
                        //alert(data); // show response from the php script.

                        //callAjaxView(data);

                        $("#div-upload").html(data);
                    }
                });

            });

        });

        function deleteFile(filePath)
        {
            alert(filePath);
        }

    </script>

@endsection