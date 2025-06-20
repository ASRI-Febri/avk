@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Save Address" :url="$url_save_modal" table="table-address"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_M_PartnerAddress" name="IDX_M_PartnerAddress" value="{{ $fields->IDX_M_PartnerAddress }}"/>
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_M_PostalCode" name="IDX_M_PostalCode" value="{{ $fields->IDX_M_PostalCode }}"/>
    
    @php
        $IsDefault = '';
        if($fields->IsDefault == 'Y'){ $IsDefault = 'checked'; }
    @endphp 
    
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary"></label>
        <div class="col-sm-9">
            <x-switch-horizontal id="IsDefault" name="IsDefault" label="Default Address ?" :value="$IsDefault" :checked="$IsDefault" />
        </div>
    </div>
    <br>
    
    <x-select-horizontal label="Address Type" id="IDX_M_AddressType" :value="$fields->IDX_M_AddressType" class="required mb-2" :array="$dd_address_type"/>   
    <br> 
    <x-textarea-horizontal label="Address" id="Street" :value="$fields->Street" placeholder="" class="required mb-2" />    

    {{-- <x-textbox-horizontal label="Kota / Kelurahan" id="CityDescription" :value="$fields->CityDescription" placeholder="" class="required mb-2" /> --}}
    
    {{-- <x-select-horizontal label="Kota / Kelurahan" id="CityDescription" :value="$fields->CityDescription" class="required mb-2" :array="$dd_city_description"/> --}}

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Kota / Kelurahan</label>
        <div class="col-sm-9">
            <select id="CityDescription" name="CityDescription" class="">            
                
            </select>
        </div>
    </div>
    <br>
    
    <x-textbox-horizontal label="Postal Code" id="Zip" :value="$fields->Zip" placeholder="" class="mb-2" />
    <x-textbox-horizontal label="Remark" id="Notes" :value="$fields->Notes" placeholder="" class="mb-2" />

@endsection

@section('script')
    <script>
        $(document).ready(function()
        {
            $("#CityDescription").select2({
                ajax: {
                    url: "{{ url('/search-postal-code') }}",
                    dataType: 'json',
                    type: 'post',
                    delay: 250,
                    data: function (params) {
                        return {
                            q: params.term, // search term
                            //page: params.page,
                            _token: $('#_token').val()
                        };
                    },
                    // processResults: function (data, params) {
                    //     // parse the results into the format expected by Select2
                    //     // since we are using custom formatting functions we do not need to
                    //     // alter the remote JSON data, except to indicate that infinite
                    //     // scrolling can be used
                    //     params.page = params.page || 1;

                    //     return {
                    //         results: data.items,
                    //         pagination: {
                    //         more: (params.page * 30) < data.total_count
                    //         }
                    //     };
                    // },
                    processResults: function (data) {
                        return {
                            results: data
                        };
                    },
                    cache: true
                },
                placeholder: "{{ $fields->CityDescription }}",
                minimumInputLength: 3,
                //templateResult: formatRepo,
                //templateSelection: formatRepoSelection,
                dropdownParent: $("#div-form-modal") 
            });

            $('#CityDescription').on('select2:select', function (e) {
                var data = e.params.data;

                console.log(data);

                $("#IDX_M_PostalCode").val(data.IDX_M_PostalCode);
                $("#IDX_M_PostalCode").text(data.IDX_M_PostalCode);
                $("#Zip").val(data.Zip);
                $("#Zip").text(data.Zip);
            });
            
            function formatRepo (repo)
            {
                if (repo.loading) {
                    return repo.text;
                }

                var $container = $(
                    "<div class='select2-result-repository clearfix'>" +
                    "<div class='select2-result-repository__avatar'><img src='" + repo.owner.avatar_url + "' /></div>" +
                    "<div class='select2-result-repository__meta'>" +
                        "<div class='select2-result-repository__title'></div>" +
                        "<div class='select2-result-repository__description'></div>" +
                        "<div class='select2-result-repository__statistics'>" +
                        "<div class='select2-result-repository__forks'><i class='fa fa-flash'></i> </div>" +
                        "<div class='select2-result-repository__stargazers'><i class='fa fa-star'></i> </div>" +
                        "<div class='select2-result-repository__watchers'><i class='fa fa-eye'></i> </div>" +
                        "</div>" +
                    "</div>" +
                    "</div>"
                );

                $container.find(".select2-result-repository__title").text(repo.full_name);
                $container.find(".select2-result-repository__description").text(repo.description);
                $container.find(".select2-result-repository__forks").append(repo.forks_count + " Forks");
                $container.find(".select2-result-repository__stargazers").append(repo.stargazers_count + " Stars");
                $container.find(".select2-result-repository__watchers").append(repo.watchers_count + " Watchers");

                return $container;
            }

            function formatRepoSelection (repo) {
                return repo.full_name || repo.text;
            }
            
            
        });

        
    </script>
@endsection