@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="card">
        <div class="card-header">
            <div class="card-icon">
                <i class="fas fa-cart-plus fs-14 text-muted"></i>
            </div>
            <h4 class="card-title mb-0">Overall Sales</h4>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-sm-4">
                    <div class="d-flex justify-content-between align-content-end shadow-lg p-3">
                        <div>
                            <p class="text-muted text-truncate mb-2">Penjualan Hari Ini</p>
                            <h5 class="mb-0">IDR {{ number_format($records->Sales_Today, 2) }}</h5>
                        </div>
                        <div class="text-success float-end">
                            <i class="mdi mdi-menu-up"> </i>IDR
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="d-flex justify-content-between align-content-end shadow-lg p-3">
                        <div>
                            <p class="text-muted text-truncate mb-2">Penjualan Bulan Ini</p>
                            <h5 class="mb-0">IDR {{ number_format($records->Sales_ThisMonth, 2) }}</h5>
                        </div>
                        <div class="text-success float-end">
                            <i class="mdi mdi-menu-up"> </i>IDR
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="d-flex justify-content-between align-content-end shadow-lg p-3">
                        <div>
                            <p class="text-muted text-truncate mb-2">Penjualan Tahun Ini</p>
                            <h5 class="mb-0">IDR {{ number_format($records->Sales_ThisYear, 2) }}</h5>
                        </div>
                        <div class="text-success float-end">
                            <i class="mdi mdi-menu-up"> </i>IDR
                        </div>
                    </div>
                </div>                
            </div>
            <div class="row mb-3">
                <div class="col-sm-4">
                    <div class="d-flex justify-content-between align-content-end shadow-lg p-3">
                        <div>
                            <p class="text-muted text-truncate mb-2">Pembelian Hari Ini</p>
                            <h5 class="mb-0">IDR {{ number_format($records->Purchase_Today, 2) }}</h5>
                        </div>
                        <div class="text-success float-end">
                            <i class="mdi mdi-menu-up"> </i>IDR
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="d-flex justify-content-between align-content-end shadow-lg p-3">
                        <div>
                            <p class="text-muted text-truncate mb-2">Pembelian Bulan Ini</p>
                            <h5 class="mb-0">IDR {{ number_format($records->Purchase_ThisMonth, 2) }}</h5>
                        </div>
                        <div class="text-success float-end">
                            <i class="mdi mdi-menu-up"> </i>IDR
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="d-flex justify-content-between align-content-end shadow-lg p-3">
                        <div>
                            <p class="text-muted text-truncate mb-2">Pembelian Tahun Ini</p>
                            <h5 class="mb-0">IDR {{ number_format($records->Purchase_ThisYear, 2) }}</h5>
                        </div>
                        <div class="text-success float-end">
                            <i class="mdi mdi-menu-up"> </i>IDR
                        </div>
                    </div>
                </div>                
            </div>
        </div>        
    </div>

    <div class="row g-3">
        <div class="col-xl-6 col-md-6 col-sm-12">

            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Valas</h3>

                    <div class="card-addon">
                        
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive-md">
                        <table class="table text-nowrap mb-0">
                            @php 
                                $row_number = 0;
                                $group_number = 0;

                                $group_a1 = '';    
                                $group_a2 = '';

                                $group_valas_amount = 0;
                                $total_valas_amount = 0;

                                $prev_currency_id = '';
                            @endphp
                            <thead>
                                <tr>
                                    <th>NO</th>
                                    <th>VALAS</th>
                                    <th class="text-end">QTY</th>
                                    <th class="text-end">VALAS AMOUNT</th>
                                    <th class="text-end">AVERAGE AMOUNT</th>
                                </tr>
                            </thead>
                            <tbody>
                                @if($records_stock)   
                                    
                                    @foreach($records_stock as $row)
                                    @php
                                        $row_number += 1;
                                        $group_a1 = $row->CurrencyID;           
                
                                        $total_valas_amount += ($row->EB_Quantity * $row->ValasChangeNumber);
                                    @endphp 

                                    @if($group_a1 <> $group_a2)

                                        @if($row_number > 1)
                                            <tr>
                                                <td class="text-end" colspan="3"><strong>TOTAL</strong></td>
                                                <td class="text-end"><strong>{{ $prev_currency_id   . ' ' . number_format($group_valas_amount,2,'.',',') }}</strong></td>
                                                <td></td>
                                            </tr>
                                        @endif 

                                        @php
                                            $group_number = 0;
                                            $group_valas_amount = 0;

                                            $group_a2 = $group_a1;
                                        @endphp 
                                    @endif 

                                    @php 
                                        $group_number += 1;

                                        $group_valas_amount += ($row->EB_Quantity * $row->ValasChangeNumber);
                                        $prev_currency_id = $row->CurrencyID;
                                    @endphp

                                    <tr>
                                        <td>{{ $row_number }}</td>
                                        <td>{{ $row->ValasName }}</td>
                                        <td class="text-end">{{ number_format($row->EB_Quantity,0,'.',',') }}</td>
                                        <td class="text-end">{{ $row->CurrencyID . ' ' . number_format($row->EB_Quantity * $row->ValasChangeNumber,0,'.',',') }}</td>
                                        <td class="text-end">{{ $row->CurrencyID . ' ' . number_format($row->AverageValue,4,'.',',') }}</td>
                                    </tr>
                                    @endforeach
                                    <tr>
                                        <td class="text-end" colspan="3"><strong>TOTAL</strong></td>
                                        <td class="text-end"><strong>{{ $prev_currency_id   . ' ' . number_format($group_valas_amount,2,'.',',') }}</strong></td>
                                        <td></td>
                                    </tr>
                                @endif 
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
        <div class="col-xl-6 col-md-6 col-sm-12">

            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Average Price by Currency</h3>

                    <div class="card-addon">
                        
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive-md">
                        <table class="table text-nowrap mb-0">
                            @php 
                                $row_number = 0;
                                $group_number = 0;

                                $group_a1 = '';    
                                $group_a2 = '';

                                $group_valas_amount = 0;
                                $total_valas_amount = 0;

                                $prev_currency_id = '';
                            @endphp
                            <thead>
                                <tr>
                                    <th>NO</th>
                                    <th>CURRENCY</th>                                    
                                    <th class="text-end">AVERAGE AMOUNT</th>
                                </tr>
                            </thead>
                            <tbody>
                                @if($records_average)   
                                    
                                    @foreach($records_average as $row)
                                    @php
                                        $row_number += 1;
                                        $group_a1 = $row->CurrencyID;           
                
                                        //$total_valas_amount += ($row->EB_Quantity * $row->ValasChangeNumber);
                                    @endphp 

                                    @if($group_a1 <> $group_a2)                                       

                                        @php
                                            $group_number = 0;
                                            $group_valas_amount = 0;

                                            $group_a2 = $group_a1;
                                        @endphp 
                                    @endif 

                                    @php 
                                        $group_number += 1;
                                        
                                        $prev_currency_id = $row->CurrencyID;
                                    @endphp

                                    <tr>
                                        <td>{{ $row_number }}</td>
                                        <td>{{ $row->CurrencyID . ' - ' . $row->CurrencyName }}</td>
                                        <td class="text-end">{{ number_format($row->AverageValue,2,'.',',') }}</td>                                        
                                    </tr>
                                    @endforeach
                                    
                                @endif 
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-6 col-md-6 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Top 10 Penjualan Valas</h3>

                    <div class="card-addon">
                        
                    </div>
                </div>
                <div class="card-body">

                </div>
            </div>
        </div>
        <div class="col-xl-6 col-md-6 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">Top 10 Pembelian Valas</h3>

                    <div class="card-addon">
                        
                    </div>
                </div>
                <div class="card-body">

                </div>
            </div>
        </div>
    </div>  

@endsection