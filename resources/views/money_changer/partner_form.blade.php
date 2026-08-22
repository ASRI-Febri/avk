@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');    
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-customer').addClass('mm-active');
@endsection

@section('form-remark')
    Business partner adalah customer atau supplier yang melakukan transaksi jual beli. 
    {{-- <br> 
    Contoh nomor PO <code>PO-100-2506-001</code> untuk kode cabang 100, bulan 05 tahun 2025. --}}
@endsection

@section('action')
    @include('form_helper.btn_save_header')
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->        
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>  
    <input type="hidden" id="ARAccount" name="ARAccount" value="{{ $fields->ARAccount }}"/>  
    <input type="hidden" id="APAccount" name="APAccount" value="{{ $fields->APAccount }}"/>  
    <input type="hidden" id="APAccount" name="APAccount" value="{{ $fields->APAccount }}"/>  
    <input type="hidden" id="APAccount" name="APAccount" value="{{ $fields->APAccount }}"/>     
    
    @if($state <> 'create')
        <h6 class="text-secondary">{{ $fields->PartnerID . ' - ' . $fields->PartnerName }}</h6>
    @endif

    <div class="row">
        <div class="col-xl-8 col-md-8 col-sm-12">

            <div class="card border">
                <div class="card-header">
                    
                    <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
                        <a class="nav-item nav-link active" id="card-general-tab" data-bs-toggle="tab" href="#card-general" aria-selected="false" role="tab" tabindex="-1">
                            <i class="fas fa-align-justify"></i> General
                        </a>
                        <a class="nav-item nav-link" id="card-additional-tab" data-bs-toggle="tab" href="#card-additional" aria-selected="false" role="tab" tabindex="-1">
                            <i class="fas fa-list"></i> Additional</a>
                        <a class="nav-item nav-link" id="card-accounting-tab" data-bs-toggle="tab" href="#card-accounting" aria-selected="true" role="tab">
                            <i class="fas fa-cogs"></i> Accounting</a>
                        <a class="nav-item nav-link" id="card-address-tab" data-bs-toggle="tab" href="#card-address" aria-selected="true" role="tab">
                            <i class="fas fa-book"></i> Alamat</a>
                        <a class="nav-item nav-link" id="card-bank-tab" data-bs-toggle="tab" href="#card-bank" aria-selected="true" role="tab">
                            <i class="fas fa-coins"></i> Rekening Bank</a>
                        <a class="nav-item nav-link" id="card-ktp-tab" data-bs-toggle="tab" href="#card-ktp" aria-selected="true" role="tab">
                            <i class="fas fa-id-card"></i> Foto KTP</a>
                    </div>
                </div>
                <div class="card-body">
                    <div class="tab-content">
                        <div class="tab-pane fade active show" id="card-general" role="tabpanel" aria-labelledby="#card-general-tab">
                            
                            <x-textbox-horizontal label="Kode" id="PartnerID" :value="$fields->PartnerID" placeholder="(Auto)" class="readonly mb-2" />
                            <x-textbox-horizontal label="Bpk/Ibu/PT/CV" id="Prefix" :value="$fields->Prefix" placeholder="(Bpk/Ibu/PT/CV)" class="required mb-2" />
                            <x-textbox-horizontal label="Nama Lengkap" id="PartnerName" :value="$fields->PartnerName" placeholder="" class="required mb-2" />
                            <x-textbox-horizontal label="Alias" id="PartnerAlias" :value="$fields->PartnerAlias" placeholder="" class="required mb-2" />
                            <x-textbox-horizontal label="KTP" id="SingleIdentityNumber" :value="$fields->SingleIdentityNumber" placeholder="" class="required mb-2" />
                            <x-textbox-horizontal label="NPWP" id="TaxIdentityNumber" :value="$fields->TaxIdentityNumber" placeholder="" class="TaxIdentityNumber mb-2" />
                            <x-select-horizontal label="Status" id="ActiveStatus" :value="$fields->ActiveStatus" class="required mb-2" :array="$dd_active_status"/>

                        </div>
                        <div class="tab-pane fade" id="card-additional" role="tabpanel" aria-labelledby="#card-additional-tab">
                            
                            <div class="form-group row mb-3">
                                <div class="col-6">
                                    @php
                                        $IsCompany = '';
                                        if($fields->IsCompany == 'Y'){ $IsCompany = 'checked'; }
            
                                        $IsSupplier = '';
                                        if($fields->IsSupplier == 'Y'){ $IsSupplier = 'checked'; }
            
                                        $IsCustomer = '';
                                        if($fields->IsCustomer == 'Y'){ $IsCustomer = 'checked'; }

                                        $IsMember = '';
                                        if($fields->IsMember == 'Y'){ $IsMember = 'checked'; }

                                        $IsDTTOT = '';
                                        if($fields->IsDTTOT == 'Y'){ $IsDTTOT = 'checked'; }
                                    @endphp      
                                    
                                    <div class="d-grid gap-1">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="IsCompany" name="IsCompany" {{ $IsCompany }} /> 
                                            <label class="form-check-label" for="IsCompany">is Company ?</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="IsSupplier" name="IsSupplier" {{ $IsSupplier }} />
                                            <label class="form-check-label" for="IsSupplier">is Supplier ?</label>
                                        </div>
                                        {{-- <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="flexSwitchCheckDisabled" disabled="disabled" />
                                            <label class="form-check-label" for="flexSwitchCheckDisabled">Disabled switch checkbox input</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="flexSwitchCheckCheckedDisabled" checked="checked" disabled="disabled" />
                                            <label class="form-check-label" for="flexSwitchCheckCheckedDisabled">Disabled checked switch checkbox input</label>
                                        </div> --}}
                                    </div>
                                    
                                    {{-- <x-checkbox-horizontal id="IsCompany" name="IsCompany" label="Is Company ?" :value="$IsCompany" :checked="$IsCompany" />
                                    <x-checkbox-horizontal id="IsSupplier" name="IsSupplier" label="Is Supplier ?" :value="$IsSupplier" :checked="$IsSupplier" />
                                    <x-checkbox-horizontal id="IsCustomer" name="IsCustomer" label="Is Customer ?" :value="$IsCustomer" :checked="$IsCustomer" />                        
                                    <x-checkbox-horizontal id="IsMember" name="IsMember" label="Is Member ?" :value="$IsMember" :checked="$IsMember"/> --}}
                                    
                                </div>

                                <div class="col-6">
                                    <div class="d-grid gap-1">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="IsCustomer" name="IsCustomer" {{ $IsCustomer }} /> 
                                            <label class="form-check-label" for="IsCustomer">is Customer ?</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="IsMember" name="IsMember" {{ $IsMember }} />
                                            <label class="form-check-label" for="IsMember">is Member ?</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="IsDTTOT" name="IsDTTOT" {{ $IsDTTOT }} />
                                            <label class="form-check-label" for="IsDTTOT">is DTTOT ?</label>
                                        </div>
                                        {{-- <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="flexSwitchCheckDisabled" disabled="disabled" />
                                            <label class="form-check-label" for="flexSwitchCheckDisabled">Disabled switch checkbox input</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" role="switch" id="flexSwitchCheckCheckedDisabled" checked="checked" disabled="disabled" />
                                            <label class="form-check-label" for="flexSwitchCheckCheckedDisabled">Disabled checked switch checkbox input</label>
                                        </div> --}}
                                    </div>
                                </div>
                            </div>

                            {{-- <x-textbox-horizontal label="Barcode Member" id="BarcodeMember" :value="$fields->BarcodeMember" placeholder="" class=" mb-2" />                         --}}
                            <x-select-horizontal label="Gender" id="Gender" :value="$fields->Gender" class="required mb-2" :array="$dd_gender"/>
                            <x-textbox-horizontal label="Tanggal Lahir" id="DateOfBirth" :value="$fields->DateOfBirth" placeholder="" class="required datepicker2 mt-2 mb-2" />
                            <x-textbox-horizontal label="Tempat Lahir" id="PlaceOfBirth" :value="$fields->PlaceOfBirth" placeholder="" class=" mb-2" />
                            {{-- <x-textbox-horizontal label="Credit Limit" id="CreditLimit" :value="$fields->CreditLimit" placeholder="" class="required auto mb-2" />  --}}
                            <x-textbox-horizontal label="Keterangan" id="Remarks" :value="$fields->Remarks" placeholder="" class=" mb-2" />                    


                        </div>
                        <div class="tab-pane fade " id="card-accounting" role="tabpanel" aria-labelledby="#card-accounting-tab">
                            <x-lookup-horizontal label="AR Account" id="ARAccountDesc" :value="$fields->ARAccountDesc" class="required" button="btn-find-coa-ar"/>
                            <br>
                            <x-lookup-horizontal label="AP Account" id="APAccountDesc" :value="$fields->APAccountDesc" class="required" button="btn-find-coa-ap"/>

                        </div>
                        <div class="tab-pane fade" id="card-address" role="tabpanel" aria-labelledby="#card-address-tab">

                            <x-textbox-horizontal label="Phone 1" id="Phone1" :value="$fields->Phone1" placeholder="" class="required mb-2" />
                            <x-textbox-horizontal label="Phone 2" id="Phone2" :value="$fields->Phone2" placeholder="" class="mb-2" />
                            <x-textbox-horizontal label="Fax" id="FaxNo" :value="$fields->FaxNo" placeholder="" class="mb-2" />
                            <x-textbox-horizontal label="Mobile Phone" id="MobilePhone" :value="$fields->MobilePhone" placeholder="" class="mb-2" />
                            <x-textbox-horizontal label="Email" id="Email" :value="$fields->Email" placeholder="" class="mb-2" />
                            
                            @if($state <> 'create')
                            <br>
                            <x-btn-add-detail id="btn-add-address" label="Add New Address" />

                            <div id="table-address" class="table-responsive">
                                @include('general.partner_address_list')
                            </div>
                            @endif

                        </div>
                        <div class="tab-pane fade" id="card-bank" role="tabpanel" aria-labelledby="#card-bank-tab">

                            @if($state <> 'create')
                                <x-btn-add-detail id="btn-add-bank" label="Add New Bank Account" />

                                <div id="table-bank" class="table-responsive">
                                    @include('general.partner_bank_list')
                                </div>
                            @endif

                        </div>
                        <div class="tab-pane fade" id="card-ktp" role="tabpanel" aria-labelledby="#card-ktp-tab">

                            @if($state == 'create')
                                <div class="alert alert-info mb-0">
                                    Simpan dulu data konsumen ini, baru foto KTP bisa diupload.
                                </div>
                            @else
                                <p class="text-muted">
                                    Format jpg, jpeg, png, atau webp; ukuran maksimal 5 MB.
                                    Upload ulang akan menggantikan foto yang lama.
                                </p>

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary">Pilih Berkas</label>
                                        <input type="file" id="KTPFile" class="form-control"
                                            accept="image/jpeg,image/png,image/webp">

                                        <div class="mt-3">
                                            <button type="button" class="btn btn-primary" id="btn-ktp-upload">
                                                <i class="fas fa-upload me-1"></i> Upload KTP
                                            </button>
                                            <button type="button" class="btn btn-danger {{ $url_ktp_view === '' ? 'd-none' : '' }}" id="btn-ktp-delete">
                                                <i class="fas fa-trash me-1"></i> Hapus
                                            </button>
                                        </div>

                                        <div id="ktp-pesan" class="alert alert-danger mt-3 mb-0 d-none"></div>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label text-secondary">Foto Tersimpan</label>

                                        <div id="ktp-kosong" class="alert alert-light mb-0 {{ $url_ktp_view === '' ? '' : 'd-none' }}">
                                            Belum ada foto KTP.
                                        </div>

                                        <a href="{{ $url_ktp_view }}" target="_blank" id="ktp-link"
                                            class="{{ $url_ktp_view === '' ? 'd-none' : '' }}">
                                            <img src="{{ $url_ktp_view }}" id="ktp-preview" class="img-fluid border rounded"
                                                alt="Foto KTP">
                                        </a>
                                    </div>
                                </div>
                            @endif

                        </div>
                    </div>
                    
                </div>
            </div>
        </div> 
        <div class="col-xl-4 col-md-4 col-sm-12">
            <div class="card border">
                <div class="card-header card-header-bordered">
                    <div class="card-icon text-muted"><i class="fa fa-list-alt"></i></div>
                    <h3 class="card-title">Log</h3>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-nowrap table-borderless mb-0">
                            <tbody>
                                <tr>
                                    <th scope="row"><i class="mdi mdi-account align-middle text-primary me-2"></i> Created</th>
                                    <td>{{ $fields->CreateByID ?? ''}} {{ $fields->CreateByName ?? ''}}</td>
                                </tr>
                                <tr>
                                    <th scope="row"><i class="mdi mdi-calendar align-middle text-primary me-2"></i> Date :</th>
                                    <td>{{ $fields->CreateByDate ?? ''}}</td>
                                </tr>
                            </tbody>
                        </table>

                        @yield('additional-log')
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row"> 
        <div class="col-12">           
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection

@section('script')

    <script>

        function deleteAddress(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('gn-partner-address/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),                
                "IDX_M_PartnerAddress": idx,
                "Address": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editAddress(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('gn-partner-address/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),                
                "IDX_M_PartnerAddress": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function deleteBank(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('gn-partner-bank/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),                
                "IDX_M_PartnerBank": idx,
                "BankAccountNo": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editBank(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('gn-partner-bank/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),                
                "IDX_M_PartnerBank": idx            
            }
            
            callAjaxModalView(url,data);
        }

        $(document).ready(function()
        { 
            // ---------- FOTO KTP ----------
            // Upload lewat AJAX supaya isian form transaksi yang belum disimpan
            // tidak ikut hilang saat halaman berpindah.
            function ktpPesan(html)
            {
                $('#ktp-pesan').html(html).removeClass('d-none');
            }

            $('#btn-ktp-upload').click(function()
            {
                var berkas = $('#KTPFile')[0].files[0];

                $('#ktp-pesan').addClass('d-none').empty();

                if (!berkas)
                {
                    ktpPesan('Berkas KTP belum dipilih!');
                    return;
                }

                var data = new FormData();
                data.append('_token', $('#_token').val());
                data.append('IDX_M_Partner', $('#IDX_M_Partner').val());
                data.append('KTPFile', berkas);

                var $tombol = $(this);
                $tombol.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i> Mengupload...');

                $.ajax({
                    url: '{{ $url_ktp_upload ?? '' }}',
                    type: 'POST',
                    data: data,
                    processData: false,
                    contentType: false
                }).done(function(hasil)
                {
                    if (hasil.flag !== 'success')
                    {
                        ktpPesan(hasil.message);
                        return;
                    }

                    $('#ktp-preview').attr('src', hasil.url);
                    $('#ktp-link').attr('href', hasil.url).removeClass('d-none');
                    $('#ktp-kosong').addClass('d-none');
                    $('#btn-ktp-delete').removeClass('d-none');
                    $('#KTPFile').val('');

                    Swal.fire({ title: 'Foto KTP tersimpan', icon: 'success', timer: 1500, showConfirmButton: false });
                }).fail(function()
                {
                    ktpPesan('Upload gagal. Coba ulangi.');
                }).always(function()
                {
                    $tombol.prop('disabled', false).html('<i class="fas fa-upload me-1"></i> Upload KTP');
                });
            });

            $('#btn-ktp-delete').click(function()
            {
                Swal.fire({
                    title: 'Hapus foto KTP?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Hapus',
                    cancelButtonText: 'Batal'
                }).then(function(pilih)
                {
                    if (!pilih.isConfirmed) { return; }

                    $.post('{{ $url_ktp_delete ?? '' }}', {
                        _token: $('#_token').val(),
                        IDX_M_Partner: $('#IDX_M_Partner').val()
                    }).done(function(hasil)
                    {
                        if (hasil.flag !== 'success')
                        {
                            ktpPesan(hasil.message);
                            return;
                        }

                        $('#ktp-link').addClass('d-none').attr('href', '');
                        $('#ktp-preview').attr('src', '');
                        $('#ktp-kosong').removeClass('d-none');
                        $('#btn-ktp-delete').addClass('d-none');
                    }).fail(function()
                    {
                        ktpPesan('Foto KTP gagal dihapus. Coba ulangi.');
                    });
                });
            });

            $('#btn-add-address').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_Partner: $("#IDX_M_Partner").val(),
                }                

                callAjaxModalView('{{ url('gn-partner-address/create') }}',data);            
            });

            $('#btn-add-bank').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_Partner: $("#IDX_M_Partner").val(),
                }                

                callAjaxModalView('{{ url('gn-partner-bank/create') }}',data);            
            });

            $('#btn-find-coa-ar').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'ARAccount',
                    target_name: 'ARAccountDesc'                  
                }                

                callAjaxModalView('{{ url('/ac-select-coa') }}',data);                
            });

            $('#btn-find-coa-ap').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'APAccount',
                    target_name: 'APAccountDesc'                  
                }                

                callAjaxModalView('{{ url('/ac-select-coa') }}',data);                
            }); 

        });

    </script>

@endsection