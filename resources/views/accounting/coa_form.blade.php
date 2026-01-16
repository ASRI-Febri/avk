@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-coa').addClass('mm-active');
@endsection

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')        
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif 
@endsection

@section('form-remark')
    {{ $form_remark }}
@endsection

@section('content-form')  

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_COA" name="IDX_M_COA" value="{{ $fields->IDX_M_COA }}"/>  
    <input type="hidden" id="ParentID" name="ParentID" value="{{ $fields->ParentID }}"/>  
    

    <x-select-horizontal label="Header/Account" id="COAFlag" :value="$fields->COAFlag" class="required" :array="$dd_coa_flag"/>
    <x-select-horizontal label="COA Type" id="IDX_M_COAType" :value="$fields->IDX_M_COAType" class="required" :array="$dd_coa_type"/>
    <x-select-horizontal label="COA Category" id="IDX_M_COACategory" :value="$fields->IDX_M_COACategory" class="required" :array="$dd_coa_category"/>
    <x-textbox-horizontal label="COA ID" id="COAID" :value="$fields->COAID" placeholder="COA ID" class="required" />
    <x-textbox-horizontal label="COA Name" id="COADesc" :value="$fields->COADesc" placeholder="" class="required" />
    <x-textbox-horizontal label="COA Name 2" id="COADesc2" :value="$fields->COADesc2" placeholder="" class="required" />
    <x-select-horizontal label="Default Balance" id="DefaultBalance" :value="$fields->DefaultBalance" class="required" :array="$dd_debet_credit"/>
    <x-lookup-horizontal label="COA Parent" id="ParentDesc" :value="$fields->ParentDesc" class="" button="btn-find-coa-parent"/>
    <x-select-horizontal label="Allow for journal entry?" id="AllowJournalEntry" :value="$fields->AllowJournalEntry" class="required" :array="$dd_yes_no"/>
    <x-select-horizontal label="Need reconcile?" id="IsReconcile" :value="$fields->IsReconcile" class="required" :array="$dd_yes_no"/>
    <x-select-horizontal label="Status" id="COAStatus" :value="$fields->COAStatus" class="required" :array="$dd_active_status"/>
    <hr>

    

        <div id="div-coa-group1">
            <x-select-horizontal label="COA Group 1" id="COAGroup1" :value="$fields->COAGroup1" class="" :array="$dd_coa_group1"/>
            <br>
            <div id="div-coa-group2">
                <x-select-horizontal label="COA Group 2" id="COAGroup2" :value="$fields->COAGroup2" class="" :array="$dd_coa_group2"/>
                <br>
                <div id="div-coa-group3">
                    <x-select-horizontal label="COA Group 3" id="COAGroup3" :value="$fields->COAGroup3" class="" :array="$dd_coa_group3"/>
                </div>
            </div>
        </div>

    <x-switch-horizontal id="add-new-after-save" name="add-new-after-save" label="Add new data after save?" checked="" />
    {{-- <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save? " :value="''" checked="" /> --}}
    <br>

    <div class="row"> 
        <div class="col-12">           
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection

@section('script')

    <script>
        $(document).ready(function()
        { 
            $('#btn-find-coa-parent').click(function()
            {
                var data = {
                    _token: $("#_token").val(),
                    target_index: 'ParentID',
                    target_name: 'ParentDesc'                    
                }                

                callAjaxModalView('{{ url('/ac-select-coa') }}',data);
            });

            $("#IDX_M_COAType").change(function(){
                var data = {
                    _token: $('#_token').val(),
                    IDX_M_COAType:$("#IDX_M_COAType").val()
                };

                $.ajax({
                        type: "POST",
                        url : "{{ url('ac-select-coa-group1') }}",
                        data: data,
                        beforeSend: function()
                        {
                            $('#div-coa-group1').block({ 
                                message: '<span class="text-semibold"><i class="fa fa-spinner spinner position-center"></i>&nbsp; Loading...</span>', 
                                overlayCSS: {
                                    backgroundColor: '#fff',
                                    opacity: 0.8,
                                    cursor: 'wait'
                                },
                                css: {
                                    border: 0,
                                    padding: '10px 15px',
                                    color: '#fff',
                                    width: 'auto',
                                    '-webkit-border-radius': 2,
                                    '-moz-border-radius': 2,
                                    backgroundColor: '#333'
                                }
                            });	
                        },
                        success: function(msg){
                            $('#div-coa-group1').unblock(); 
                            $('#div-coa-group1').html(msg);
                        }
                });
            });

            $("#COAGroup1").change(function(){
                var data = {
                    _token: $('#_token').val(),
                    COAGroup1:$("#COAGroup1").val()
                };

                $.ajax({
                        type: "POST",
                        url : "{{ url('ac-select-coa-group2') }}",
                        data: data,
                        beforeSend: function()
                        {
                            $('#div-coa-group2').block({ 
                                message: '<span class="text-semibold"><i class="fa fa-spinner spinner position-center"></i>&nbsp; Loading...</span>', 
                                overlayCSS: {
                                    backgroundColor: '#fff',
                                    opacity: 0.8,
                                    cursor: 'wait'
                                },
                                css: {
                                    border: 0,
                                    padding: '10px 15px',
                                    color: '#fff',
                                    width: 'auto',
                                    '-webkit-border-radius': 2,
                                    '-moz-border-radius': 2,
                                    backgroundColor: '#333'
                                }
                            });	
                        },
                        success: function(msg){
                            $('#div-coa-group2').unblock(); 
                            $('#div-coa-group2').html(msg);
                        }
                });
            });

            $("#COAGroup2").change(function(){
                var data = {
                    _token: $('#_token').val(),
                    COAGroup2:$("#COAGroup2").val()
                };

                $.ajax({
                        type: "POST",
                        url : "{{ url('ac-select-coa-group3') }}",
                        data: data,
                        success: function(msg){
                            $('#div-coa-group3').html(msg);
                        }
                });
            });
        });

    </script>

@endsection