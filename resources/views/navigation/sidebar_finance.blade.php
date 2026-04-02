<!-- ========== Left Sidebar Start ========== -->
<div class="sidebar-left">

    <div data-simplebar class="h-100">

        <!--- Sidebar-menu -->
        <div id="sidebar-menu">
            <!-- Left Menu Start -->
            <ul class="left-menu list-unstyled" id="side-menu">
                <li>
                    <a href="{{ url('home') }}" class="">
                        <i class="fas fa-home"></i>
                        <span>Portal</span>
                    </a>
                </li>
                

                <li class="menu-title">FINANCE</li>

                <li>
                    <a href="{{ url('finance') }}" class="">
                        <i class="fas fa-desktop"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-transaction">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Transaksi</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-transaction">
                        <li id="nav-li-view-pi">
                            <a href="{{ url('fm-purchase-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Nota Pembelian
                            </a>
                        </li>
                        <li id="nav-li-view-fp">
                            <a href="{{ url('fm-financial-payment') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Pengeluaran Uang
                            </a>
                        </li>
                        <li id="nav-li-view-si">
                            <a href="{{ url('fm-sales-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Nota Penjualan
                            </a>
                        </li>
                        <li id="nav-li-view-fr">
                            <a href="{{ url('fm-financial-receive') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Penerimaan Uang
                            </a>
                        </li>
                    </ul>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-report">
                        <i class="fas fa-list-ul"></i>
                        <span>Laporan</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-report">
                        <li id="nav-li-rpt-pi">
                            <a href="{{ url('fm-rpt-purchase-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Nota Pembelian
                            </a>
                        </li>
                        <li id="nav-li-rpt-fr">
                            <a href="{{ url('fm-rpt-financial-receive') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Penerimaan Uang
                            </a>
                        </li>
                        <li id="nav-li-rpt-si">
                            <a href="{{ url('fm-rpt-sales-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Nota Penjualan
                            </a>
                        </li>
                        <li id="nav-li-rpt-fp">
                            <a href="{{ url('fm-rpt-financial-payment') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Pengeluaran Uang
                            </a>
                        </li>
                    </ul>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-setting">
                        <i class="fa fa-cogs"></i>
                        <span>Setting</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-setting">
                        <li id="nav-li-setting-fa">
                            <a href="{{ url('fm-financial-account') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Financial Account
                            </a>
                        </li> 
                        <li id="nav-li-setting-bank">
                            <a href="{{ url('fm-bank') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Bank
                            </a>
                        </li>
                        {{-- <li id="nav-li-setting-currency">
                            <a href="{{ url('fm-currency') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Currency
                            </a>
                        </li>                  --}}
                    </ul>
                </li>

               

                
            </ul>
        </div>
        <!-- Sidebar -->
    </div>
</div>
<!-- Left Sidebar End -->
