<!-- ========== Left Sidebar Start ========== -->
<div class="sidebar-left">

    <div data-simplebar class="h-100">

        <!--- Sidebar-menu -->
        <div id="sidebar-menu">
            <!-- Left Menu Start -->
            <ul class="left-menu list-unstyled" id="side-menu">
                <li>
                    <a href="{{ url('home') }}" class="">
                        <i class="fas fa-desktop"></i>
                        <span>Portal</span>
                    </a>
                </li>

                <li class="menu-title">Modules</li>               

                <li>
                    <a href="{{ url('money-changer') }}"><i class="fas fa-dollar-sign"></i> <span>Money Changer</span></a>
                </li>

                <li>
                    <a href="{{ url('pawn') }}"><i class="fas fa-handshake"></i> <span>Gadai</span></a>
                </li>

                <li>
                    <a href="{{ url('loan') }}"><i class="fas fa-coins"></i> <span>Pinjaman</span></a>
                </li>

                <li>
                    <a href="{{ url('finance') }}"><i class="fas fa-money-bill"></i> <span>Finance</span></a>
                </li>

                <li>
                    <a href="{{ url('accounting') }}"><i class="far fa-sticky-note"></i> <span>Accounting</span></a>
                </li>

                <li>
                    <a href="{{ url('general') }}"><i class="fas fa-cogs"></i> <span>Setting & Configuration</span></a>
                </li>

                <li>
                    <a href="{{ url('user-management') }}"><i class="far fa-address-card"></i> <span>User Management</span></a>
                </li>
            </ul>
        </div>
        <!-- Sidebar -->
    </div>
</div>
<!-- Left Sidebar End -->
