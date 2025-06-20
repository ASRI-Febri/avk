@extends('layouts.master')

@section('content')
    
    <!-- BEGIN BREADCRUMBS -->
    <div class="row">
        <div class="col-12 align-self-center">
            <div class="sub-header mt-3 py-3 align-self-center d-sm-flex w-100 rounded">
                <div class="w-sm-100 mr-auto">
                    <h4 class="mb-0">Page Error</h4>
                    <p>500</p>
                </div>

                <ol class="breadcrumb bg-transparent align-self-center m-0 p-0">
                    <li class="breadcrumb-item">
                        <a href="{{ url('portal') }}">Back To Portal</a>
                    </li>                                  
                </ol>
            </div>
        </div>
    </div>
    <!-- END BREADCRUMBS -->

    <div class="card mt-3">
        <div class="card-header bg-transparent">
            Error
        </div>
        <div class="card-body">
            <h6 class="text-danger">Error while connecting to server!</h6>    
        </div>
    </div>

    
@endsection