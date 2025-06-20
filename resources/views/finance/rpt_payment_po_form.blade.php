@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content_form')

    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner"/>

    <div class="row">
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>Start Date</label>
                <input class="form-control required datepicker2" id="start_date" name="start_date" type="text" placeholder="" value="{{ $start_date }}" />                                                    
            </div>
        </div>
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label>End Date</label>
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
        <div class="col-md-6 col-sm-12">
            <div class="form-group row">
                <label class="col-sm-3 col-form-label text-secondary">Project</label>
                <div class="col-sm-9">
                    <select id="IDX_M_Project" name="IDX_M_Project" class="select2 form-control">            
                        @foreach($dd_project as $key => $value)
                            <option value="{{ $key }}">{{ $value }}</option>                            
                        @endforeach
                    </select>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('script')
    <script>
        $(document).ready(function(){

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