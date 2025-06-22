@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-md-6 col-sm-12">
            <div class="card">
                <div class="card-header">
                    <div class="card-icon text-muted"><i class="fa fa-chalkboard fs14"></i></div>
                    <h3 class="card-title">Company summary</h3>
                    <div class="card-addon">
                        <div class="dropdown">
                            <button class="btn btn-label-primary btn-sm py-0 dropdown-toggle" data-bs-toggle="dropdown">June, 2020 <i class="mdi mdi-chevron-down fs-17 align-middle ms-1"></i></button>
                            <div class="dropdown-menu dropdown-menu-end dropdown-menu-animated">
                                <a class="dropdown-item" href="#">
                                    <div class="dropdown-icon"><i class="fa fa-poll"></i></div>
                                    <span class="dropdown-content">Report</span>
                                </a>
                                <a class="dropdown-item" href="#">
                                    <div class="dropdown-icon"><i class="fa fa-chart-pie"></i></div>
                                    <span class="dropdown-content">Charts</span>
                                </a>
                                <a class="dropdown-item" href="#">
                                    <div class="dropdown-icon"><i class="fa fa-chart-line"></i></div>
                                    <span class="dropdown-content">Statistics</span>
                                </a>
                                <div class="dropdown-divider"></div>
                                <a class="dropdown-item" href="#">
                                    <div class="dropdown-icon"><i class="fa fa-cog"></i></div>
                                    <span class="dropdown-content">Settings</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-6">
                            <div class="border rounded p-2">
                                <p class="text-muted mb-2">Server Load</p>
                                <h4 class="fs-16 mb-2">489</h4>
                                <div class="progress progress-sm" style="height:4px;">
                                    <div class="progress-bar bg-success" style="width: 49.4%"></div>
                                </div>
                                <p class="text-muted mb-0 mt-1">49.4% <span>Avg</span></p>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="border rounded p-2">
                                <p class="text-muted mb-2">Members online</p>
                                <h4 class="fs-16 mb-2">3,450</h4>
                                <div class="progress progress-sm" style="height:4px;">
                                    <div class="progress-bar bg-danger" style="width: 34.6%"></div>
                                </div>
                                <p class="text-muted mb-0 mt-1">34.6% <span>Avg</span></p>
                            </div>
                        </div>
                    </div>
                    <div class="row g-3 mt-2">
                        <div class="col-6">
                            <div class="border rounded p-2">
                                <p class="text-muted mb-2">Today's revenue</p>
                                <h4 class="fs-16 mb-2">$18,390</h4>
                                <div class="progress progress-sm" style="height:4px;">
                                    <div class="progress-bar bg-warning" style="width: 20%"></div>
                                </div>
                                <p class="text-muted mb-0 mt-1">$37,578 <span>Avg</span></p>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="border rounded p-2">
                                <p class="text-muted mb-2">Expected profit</p>
                                <h4 class="fs-16 mb-2">$23,461</h4>
                                <div class="progress progress-sm" style="height:4px;">
                                    <div class="progress-bar bg-info" style="width: 60%"></div>
                                </div>
                                <p class="text-muted mb-0 mt-1">$23,461 <span>Avg</span></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-xxl-4">
            <div class="row">
                <div class="col-xxl-12 col-xl-6">
                    <div class="card">
                        <div class="card-header justify-content-between">
                            <div class="card-icon text-muted"><i class="fas fa-coins fs-14"></i></div>
                            <h4 class="card-title"> Monthly income</h4>
                            <p class="card-addon rich-list-subtitle text-success mb-0">+15%</p>
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
        <div class="col-xxl-4">
            <div class="row">
                <div class="col-xxl-12 col-xl-6">
                    <div class="card">
                        <div class="card-header justify-content-between">
                            <div class="card-icon text-muted"><i class="fas fa-coins fs-14"></i></div>
                            <h4 class="card-title"> Monthly income</h4>
                            <p class="card-addon rich-list-subtitle text-success mb-0">+15%</p>
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
        <div class="col-xxl-4">
            <div class="row">
                <div class="col-xxl-12 col-xl-6">
                    <div class="card">
                        <div class="card-header justify-content-between">
                            <div class="card-icon text-muted"><i class="fas fa-coins fs-14"></i></div>
                            <h4 class="card-title"> Monthly income</h4>
                            <p class="card-addon rich-list-subtitle text-success mb-0">+15%</p>
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