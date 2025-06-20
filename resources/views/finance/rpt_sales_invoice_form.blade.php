@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content_form')

    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner"/>
    <input type="hidden" id="CompanyDesc" name="CompanyDesc" value=""/>  
    <input type="hidden" id="BranchDesc" name="BranchDesc" value=""/>

    {{-- <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$IDX_M_Branch" class="required" :array="$dd_branch"/> --}}

    <div class="row">
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Company</label>
                <div class="form-group">
                    <select id="IDX_M_Company" name="IDX_M_Company" class="select2 form-control">            
                        @foreach($dd_company as $key => $value)
                            <option value="{{ $key }}">{{ $value }}</option>                            
                        @endforeach
                    </select>
                </div>                                                 
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Branch</label>
                <div class="form-group">
                    <select id="IDX_M_Branch" name="IDX_M_Branch" class="select2 form-control">            
                        @foreach($dd_branch as $key => $value)
                            <option value="{{ $key }}">{{ $value }}</option>                            
                        @endforeach
                    </select>
                </div>                                                 
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Invoice Start Date</label>
                <input class="form-control required datepicker2" id="start_date" name="start_date" type="text" placeholder="" value="{{ $start_date }}" />                                                    
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Invoice End Date</label>
                <input class="form-control required datepicker2" id="end_date" name="end_date" type="text" placeholder="" value="{{ $end_date }}" />                                                    
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group row">
                <label class="col-sm-3 col-form-label text-secondary">Business Partner</label>
                <div class="col-sm-9">
                    <div class="input-group">
                        <input type="text" id="PartnerDesc" name="PartnerDesc" readonly class="form-control" placeholder="">
                        <div class="input-group-prepend">
                            <button class="btn btn-icon btn-outline-secondary" type="button" onClick="clearMe('PartnerDesc');"><i class="fa fa-times"></i></button>
                            <button id="btn-find-partner" class="btn btn-icon btn-outline-secondary" type="button" title="Search">
                                <i class="fa fa-search"></i>
                            </button>                      
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('script')
    <script>
        $(document).ready(function(){
            $("#IDX_M_Company").change(function()
            {   
                //alert('company blur');
                var company_id = document.getElementById("IDX_M_Company").value;				
                var company_id_index = document.getElementById("IDX_M_Company").selectedIndex;				
                var company_name = document.getElementById("IDX_M_Company").options[company_id_index].text;

                $("#CompanyDesc").val(company_name);
            });

            $("#IDX_M_Branch").change(function()
            {
                //alert('branch blur');
                var branch_id = document.getElementById("IDX_M_Branch").value;				
                var branch_id_index = document.getElementById("IDX_M_Branch").selectedIndex;				
                var branch_name = document.getElementById("IDX_M_Branch").options[branch_id_index].text;

                $("#BranchDesc").val(branch_name);
            });  

            $('#btn-find-partner').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_Partner',
                    target_name: 'PartnerDesc'                  
                }              

                callAjaxModalView('{{ url('/fm-select-partner-pi') }}',data);                
            });
        });
    </script>
@endsection