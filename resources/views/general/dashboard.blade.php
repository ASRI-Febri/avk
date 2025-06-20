@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-xxl-12">
            <div class="row">
                <div class="col-xxl-12 col-xl-6">
                    <div class="card">
                        <div class="card-header justify-content-between">
                            <div class="card-icon text-muted"><i class="fas fa-coins fs-14"></i></div>
                            <h4 class="card-title"> Settings & Configuration</h4>
                            <p class="card-addon rich-list-subtitle text-success mb-0">*</p>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="d-flex justify-content-between mb-2">
                                    <h5 class="rich-list-title mb-0">Total</h5>
                                    <p class="rich-list-subtitle mb-0">$65,880</p>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <h5 class="rich-list-title mb-0">Sales</h5>
                                    <p class="rich-list-subtitle mb-0">554</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>       
    </div>

    

            



@endsection