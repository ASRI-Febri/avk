@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('sub-title')
    {{ $form_sub_title }}
@endsection

@section('css')
    @yield('css-form')
@endsection 

@section('content')

    <div class="row">
        <div class="col-xl-12 col-md-8 col-sm-12">

            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title ?? '' }}</h3>

                    <div class="card-addon">
                        <x-btn-create-new label="Create New" :url="$url_create" />
                        
                        @include('form_helper.btn_back_to_list') 

                        @yield('action')
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
                        <input type="hidden" id="RecordStatus" name="RecordStatus" value="{{ $fields->RecordStatus ?? 'A' }}"/>

                        <!-- CONTENT FORM -->
                        @yield('content-form')

                    </form>

                </div>
            </div>

        </div>
    </div>

@endsection