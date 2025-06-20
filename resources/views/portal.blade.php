@extends('layouts.master')

@section('title')
    Portal
@endsection

@section('topbar-title')
    Portal Topbar
@endsection

@section('css')
@endsection

@section('content')

    <div class="row">
        <div class="col-xl-6 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Business Modules</h3>
                </div>
                <div class="card-body">
                    <p class="text-muted">Aplikasi untuk bisnis, profit center</p>
                    <div class="grid-nav grid-nav-bordered grid-nav-action">
                        <div class="grid-nav-row">
                            <a href="{{ url('money-changer') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="fas fa-dollar-sign"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Money Changer</h3>
                                    <span class="grid-nav-subtitle">Buy, Sell Foreign Exchange</span>
                                </div>
                            </a>                            
                            <a href="{{ url('pawn') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="fas fa-handshake"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Pawn (Gadai)</h3>
                                    <span class="grid-nav-subtitle">Gadai elektronik, emas</span>
                                </div>
                            </a>
                            <a href="{{ url('loan') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="fas fa-coins"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Pinjaman</h3>
                                    <span class="grid-nav-subtitle">Pinjaman dengan BPKB</span>
                                </div>
                            </a>
                        </div>                        
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-6 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Corporate Modules</h3>
                </div>
                <div class="card-body">
                    <p class="text-muted">Aplikasi pendukung bisnis, seperti finance, accounting, pembelian dan konfigurasi</p>
                    <div class="grid-nav grid-nav-bordered grid-nav-action">
                        <div class="grid-nav-row">
                            <a href="{{ url('finance') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="fas fa-money-bill"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Finance</h3>
                                    <span class="grid-nav-subtitle">Cashflow, Cash In, Cash Out</span>
                                </div>
                            </a>
                            <a href="{{ url('accounting') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-sticky-note"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Accounting</h3>
                                    <span class="grid-nav-subtitle">Journal and Ledger</span>
                                </div>
                            </a>
                            <a href="{{ url('general') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="fas fa-cogs"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Setting</h3>
                                    <span class="grid-nav-subtitle">Setting & Configuration</span>
                                </div>
                            </a> 
                        </div>
                        <div class="grid-nav-row">
                            <a href="{{ url('user-management') }}" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-address-card"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">User Management</h3>
                                    <span class="grid-nav-subtitle">User ID, Group Access</span>
                                </div>
                            </a> 
                            <a href="#" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-clone--"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title"></h3>
                                    <span class="grid-nav-subtitle">-</span>
                                </div>
                            </a>
                            <a href="#" class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-clone--"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title"></h3>
                                    <span class="grid-nav-subtitle">-</span>
                                </div>
                            </a>
                        </div>
                        
                        {{-- <div class="grid-nav-row">
                            <div class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-calendar-check"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Tasks</h3>
                                    <span class="grid-nav-subtitle">Remind my tasks</span>
                                </div>
                            </div>
                            <div class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-sticky-note"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Accounting</h3>
                                    <span class="grid-nav-subtitle">Show my notes</span>
                                </div>
                            </div>
                            <div class="grid-nav-item">
                                <div class="grid-nav-icon">
                                    <i class="far fa-bell"></i>
                                </div>
                                <div class="grid-nav-content">
                                    <h3 class="grid-nav-title">Notification</h3>
                                    <span class="grid-nav-subtitle">Check all notification</span>
                                </div>
                            </div>
                        </div> --}}
                    </div>
                </div>
            </div>
        </div>
    </div>

    

@endsection