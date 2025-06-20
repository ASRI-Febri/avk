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
                    <a href="javascript: void(0);" class="has-arrow ">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Transaction</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false">
                        <li><a href="{{ url('fm-purchase-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Invoice Pembelian
                            </a>
                        </li>
                        <li><a href="{{ url('fm-financial-payment') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Pengeluaran Uang
                            </a>
                        </li>
                        <li><a href="{{ url('fm-sales-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Invoice Penjualan
                            </a>
                        </li>
                        <li><a href="{{ url('fm-financial-receive') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Penerimaan Uang
                            </a>
                        </li>
                    </ul>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow ">
                        <i class="fas fa-list-ul"></i>
                        <span>Report</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false">
                        <li><a href="{{ url('fm-rpt-purchase-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Invoice Pembelian
                            </a>
                        </li>
                        <li><a href="{{ url('fm-rpt-financial-receive') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Penerimaan Uang
                            </a>
                        </li>
                        <li><a href="{{ url('fm-rpt-sales-invoice') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Invoice Penjualan
                            </a>
                        </li>
                        <li><a href="{{ url('fm-rpt-financial-payment') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Laporan Pengeluaran Uang
                            </a>
                        </li>
                    </ul>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow ">
                        <i class="fa fa-cogs"></i>
                        <span>Setting</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false">
                        <li><a href="{{ url('fm-financial-account') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Financial Account
                            </a>
                        </li> 
                        <li><a href="{{ url('fm-bank') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Bank
                            </a>
                        </li>
                        <li><a href="{{ url('fm-currency') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Currency
                            </a>
                        </li>                 
                    </ul>
                </li>

               

                
            </ul>
        </div>
        <!-- Sidebar -->
    </div>
</div>
<!-- Left Sidebar End -->
