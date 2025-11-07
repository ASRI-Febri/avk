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
                

                <li class="menu-title">USER MANAGEMENT</li>

                <li>
                    <a href="{{ url('user-management') }}" class="">
                        <i class="fas fa-desktop"></i>
                        <span>Dashboard</span>
                    </a>
                </li>

                <li>
                    <a href="javascript: void(0);" class="has-arrow ">
                        <i class="fa fa-cogs"></i>
                        <span>Setting</span>
                    </a>
                    <ul class="sub-menu" aria-expanded="false">
                        <li><a href="{{ url('sm-user') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> User ID
                            </a>
                        </li>
                        <li><a href="{{ url('sm-group-user') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Group ID
                            </a>
                        </li>
                        <li><a href="{{ url('sm-form') }}">
                                <i class="mdi mdi-checkbox-blank-circle align-middle"></i> Form ID
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
