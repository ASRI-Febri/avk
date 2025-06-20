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
                

                <li class="menu-title">PINJAMAN</li>

                <li>
                    <a href="{{ url('money-changer') }}" class="">
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
                        <li><a href="{{ url('mc-sales-order/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Baru
                            </a>
                        </li>
                        <li><a href="{{ url('mc-sales-order/buy-list') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Transaksi Beli
                            </a>
                        </li>
                        <li><a href="{{ url('mc-sales-order/sell-list') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Transaksi Jual
                            </a>
                        </li>
                        <li><a href="{{ url('mc-valas-rate') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Nilai Tukar
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
                        <li><a href="{{ url('mc-rpt-transaction') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Transaction by Period
                            </a>
                        </li>
                        <li><a href="{{ url('mc-rpt-inventory') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Valas Inventory
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
                        <li><a href="{{ url('mc-valas') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Daftar Valas
                            </a>
                        </li>
                        <li><a href="{{ url('mc-valas/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Valas
                            </a>
                        </li>                    
                        <li><a href="{{ url('mc-valas-change') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Daftar Pecahan Valas
                            </a>
                        </li>
                        <li><a href="{{ url('mc-valas-change/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Pecahan Valas
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
