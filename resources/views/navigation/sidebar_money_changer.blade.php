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
                

                <li class="menu-title">MONEY CHANGER</li>

                <li>
                    <a href="{{ url('money-changer') }}" class="">
                        <i class="fas fa-desktop"></i>
                        <span>Dashboard</span>
                    </a>
                </li>

                {{-- <li>
                    <a href="{{ url('mc/kurs') }}" class="" target="_blank">
                        <i class="fas fa-desktop"></i>
                        <span>Daftar Kurs</span>
                    </a>
                </li> --}}

                <li>
                    <a href="{{ url('mc-display-kurs') }}" class="" target="_blank">
                        <i class="fas fa-money-check-alt"></i>
                        <span>Display Kurs</span>
                    </a>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-sop">
                        <i class="fas fa-list"></i>
                        <span>SOP</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-sop">
                        <li><a href="{{ url('show-files/so-tupoksi.pdf') }}" target="_blank">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Struktur Organisasi
                            </a>
                        </li>
                        <li><a href="{{ url('show-files/sop-daily-operation.pdf') }}" target="_blank">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Operasional Harian
                            </a>
                        </li>
                        <li><a href="{{ url('show-files/sop-perlindungan-konsumen.pdf') }}" target="_blank">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Perlindungan Konsumen
                            </a>
                        </li>
                        <li><a href="{{ url('show-files/sop-manajemen-risiko.pdf') }}" target="_blank">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Manajemen Risiko
                            </a>
                        </li>
                        <li><a href="{{ url('show-files/sop-apu-ppt-pppspm.pdf') }}" target="_blank">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> APU PPT PPPSPM
                            </a>
                        </li>
                    </ul>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-transaction">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Transaksi Jual Beli</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-transaction">
                        <li id="nav-li-input-customer">
                            <a href="{{ url('mc-partner/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input / Edit Customer
                            </a>
                        </li>
                        <li id="nav-li-view-customer"><a href="{{ url('mc-partner') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Customer
                            </a>
                        </li>
                        <li id="nav-li-opening-closing"><a href="{{ url('mc-open-close') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Opening & Closing
                            </a>
                        </li>
                        <li id="nav-li-input-so"><a href="{{ url('mc-sales-order/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Transaksi Jual
                            </a>
                        </li>
                        <li id="nav-li-view-so"><a href="{{ url('mc-sales-order') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Transaksi Jual
                            </a>
                        </li>
                         <li id="nav-li-input-po"><a href="{{ url('mc-purchase-order/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Transaksi Beli
                            </a>
                        </li>
                        <li id="nav-li-view-po"><a href="{{ url('mc-purchase-order') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Transaksi Beli
                            </a>
                        </li>
                    </ul>
                </li>

                {{-- <li>
                    <a href="javascript: void(0);" class="has-arrow ">
                        <i class="fas fa-cart-plus"></i>
                        <span>Pembelian Stok</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false">
                        <li><a href="{{ url('mc-purchase-order/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input PO Valas
                            </a>
                        </li>
                        <li><a href="{{ url('mc-purchase-order') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Daftar PO Valas
                            </a>
                        </li>
                        <li><a href="{{ url('mc-stock-card') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Kartu Stok Rekap
                            </a>
                        </li>
                    </ul>
                </li> --}}

                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-report">
                        <i class="fas fa-list-ul"></i>
                        <span>Laporan</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-report">
                        <li id="nav-li-rpt-daily-closing"><a href="{{ url('mc-rpt-daily-calculation') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Perhitungan Closing Harian
                            </a>
                        </li>
                        <li id="nav-li-rpt-so">
                            <a href="{{ url('mc-rpt-so') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Penjualan Harian
                            </a>
                        </li>
                        <li id="nav-li-rpt-po">
                            <a href="{{ url('mc-rpt-po') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Pembelian Harian
                            </a>
                        </li>
                        <li id="nav-li-rpt-stock"><a href="{{ url('mc-rpt-inventory') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Stok Valas
                            </a>
                        </li>   
                        <li id="nav-li-rpt-inventory-calculation"><a href="{{ url('mc-rpt-inventory-calculation') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Perhitungan Persediaan
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
                        <li id="nav-li-setting-currency"><a href="{{ url('mc-currency') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Currency
                            </a>
                        </li>
                        <li id="nav-li-setting-valas"><a href="{{ url('mc-valas') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Valas
                            </a>
                        </li>
                        <li id="nav-li-setting-input-valas"><a href="{{ url('mc-valas/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input / Edit Valas
                            </a>
                        </li>                    
                        <li id="nav-li-setting-valas-uom"><a href="{{ url('mc-valas-change') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Pecahan Valas
                            </a>
                        </li>
                        <li id="nav-li-setting-input-valas-uom"><a href="{{ url('mc-valas-change/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input / Edit Pecahan Valas
                            </a>
                        </li>
                        {{-- <li><a href="{{ url('mc-valas-deduction') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Potongan Harga
                            </a>
                        </li>
                        <li><a href="{{ url('mc-valas-deduction/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Potongan Harga
                            </a>
                        </li>  --}}
                    </ul>
                </li>

               

                
            </ul>
        </div>
        <!-- Sidebar -->
    </div>
</div>
<!-- Left Sidebar End -->
