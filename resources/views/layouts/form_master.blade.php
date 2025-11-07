@extends('layouts.master')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('content')  

    <div class="row">
        <div class="col-xl-8 col-md-8 col-sm-12">

            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title ?? '' }}</h3>

                    <div class="card-addon">
                        <x-btn-create-new label="Create New" :url="$url_create" />
                        @include('form_helper.btn_back_to_list') 
                    </div>
                </div>
                <div class="card-body">

                    <div class="alert alert-label-info">
                        <span class="text-muted">
                            @yield('form-remark')
                        </span>
                    </div>
                                        
                    <form id="form-entry" name="form-entry" class="d-grid gap-3" autocomplete="off" enctype="multipart/form-data" action="{{ $url_save_header ?? '#' }}" role="form" method="post">

                        <!-- CSRF TOKEN -->
                        <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/>
                        <input type="hidden" id="state" name="state" value="{{ $state }}"/>
                        {{-- <input type="hidden" id="RecordStatus" name="RecordStatus" value="{{ $fields->RecordStatus ?? 'A' }}"/> --}}

                        <!-- CONTENT FORM -->
                        <!-- HIDDEN FIELDS -->
                        @foreach($array_hidden_field as $row)
                            @if($row['type'] == 'textbox')  
                                <input type="hidden" id="{{ $row['field'] }}" name="{{ $row['field'] }}" class="form-control" placeholder="" value="{{ $row['value'] }}">                
                            @endif            
                        @endforeach

                        <!-- DATABASE FIELDS -->
                        @foreach($array_field as $row)

                            @if($row['type'] == 'textbox')
                            <x-textbox-horizontal :label="$row['label']" :id="$row['field']" :value="$row['value']" placeholder="" :class="$row['class']" />

                            {{-- <div class="col-6 mb-3">
                                <label>{{ $row['label'] }}</label>
                                <input type="text" id="{{ $row['field'] }}" name="{{ $row['field'] }}" class="form-control {{ $row['class'] }}" placeholder="" value="{{ $row['value'] }}">
                            </div> --}}
                            @endif

                            @if($row['type'] == 'dropdown')
                            <x-select-horizontal :label="$row['label']" :id="$row['field']" :value="$row['value']" :class="$row['class']" :array="$row['dd_array']"/> 

                            {{-- <div class="col-6 mb-3"> 
                                <label>{{ $row['label'] }}</label>                                               
                                <select id="{{ $row['field'] }}" name="{{ $row['field'] }}" class="select2 form-control {{ $row['class'] }}">
                                    <option label="Choose on thing">Select</option>
                                    @foreach($row['dd_array'] as $key => $value)
                                        <option value="{{ $key }}" {{ $row['value'] == $key ? 'selected=' : '' }}>{{ $value }}</option>                            
                                    @endforeach
                                </select>
                            </div> --}}
                            @endif

                            @if($row['type'] == 'checkbox')
                            <x-checkbox-horizontal :id="$row['field']" :name="$row['field']" :label="$row['label']" :value="trim($row['value'])" :checked="trim($row['checked'])" />
                            @endif 

                        @endforeach

                    </form>

                </div>
            </div>

        </div>
        <div class="col-xl-4 col-md-4 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <div class="card-icon text-muted"><i class="fa fa-list-alt"></i></div>
                    <h3 class="card-title">Log</h3>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-nowrap table-borderless mb-0">
                            <tbody>
                                <tr>
                                    <th scope="row"><i class="mdi mdi-account align-middle text-primary me-2"></i> Created By</th>
                                    <td>{{ $fields->UCreate ?? ''}}</td>
                                </tr>
                                <tr>
                                    <th scope="row"><i class="mdi mdi-calendar align-middle text-primary me-2"></i> Date :</th>
                                    <td>{{ $fields->DCreate ?? ''}}</td>
                                </tr>
                                <tr>
                                    <th scope="row"><i class="mdi mdi-account align-middle text-primary me-2"></i> Last Modified</th>
                                    <td>{{ $fields->UModified ?? ''}}</td>
                                </tr>
                                <tr>
                                    <th scope="row"><i class="mdi mdi-calendar align-middle text-primary me-2"></i> Date :</th>
                                    <td>{{ $fields->DModified ?? ''}}</td>
                                </tr>
                            </tbody>
                        </table>

                        @yield('additional-log')
                    </div>
                </div>
            </div>
        </div>
    </div>

@endsection