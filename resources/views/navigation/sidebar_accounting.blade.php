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
                

                <li class="menu-title">ACCOUNTING</li>

                <li>
                    <a href="{{ url('accounting') }}" class="">
                        <i class="fas fa-desktop"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-transaction">
                        <i class="fas fa-file-invoice-dollar"></i>
                        <span>Transaction</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-transaction">
                        <li id="nav-li-view-journal">
                            <a href="{{ url('ac-journal') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Journal
                            </a>
                        </li>
                        <li id="nav-li-input-journal"><a href="{{ url('ac-journal/create') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Input Journal
                            </a>
                        </li>
                        <li id="nav-li-view-journal-detail"><a href="{{ url('ac-journal-item') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Lihat Detail Journal
                            </a>
                        </li>
                    </ul>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow" id="nav-report">
                        <i class="fas fa-list-ul"></i>
                        <span>Report</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false" id="nav-ul-report">
                        <li id="nav-li-rpt-gl">
                            <a href="{{ url('ac-rpt-gl') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> General Ledger
                            </a>
                        </li>
                        <li id="nav-li-rpt-tb">
                            <a href="{{ url('ac-rpt-tb') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Trial Balance
                            </a>
                        </li>
                        <li id="nav-li-rpt-bs">
                            <a href="{{ url('ac-rpt-bs') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Neraca (Balance Sheet)
                            </a>
                        </li>
                        <li id="nav-li-rpt-pl">
                            <a href="{{ url('ac-rpt-pl') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Profit & Loss
                            </a>
                        </li>
                        <li id="nav-li-rpt-cf">
                            <a href="{{ url('ac-rpt-cf') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Cashflow
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
                        <li id="nav-li-setting-coa">
                            <a href="{{ url('ac-coa') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Chart of Account
                            </a>
                        </li>
                        <li id="nav-li-setting-coa-group1">
                            <a href="{{ url('ac-coa-group1') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> CoA Group 1
                            </a>
                        </li>
                        <li id="nav-li-setting-coa-group2">
                            <a href="{{ url('ac-coa-group2') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> CoA Group 2
                            </a>
                        </li>
                        <li id="nav-li-setting-coa-group3">
                            <a href="{{ url('ac-coa-group3') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> CoA Group 3
                            </a>
                        </li>
                        <li id="nav-li-setting-journal-type">
                            <a href="{{ url('ac-journal-type') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Journal Type
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
