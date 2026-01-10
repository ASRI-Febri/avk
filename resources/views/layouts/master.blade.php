<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <title> @yield('title')</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta content="Premium Multipurpose Admin & Dashboard Template" name="description" />
    <meta content="Codebucks" name="author" />
    <!-- App favicon -->
    <link rel="shortcut icon" href="{{ URL::asset('assets/images/avk-logo-sm.png') }}">

    <!-- include head css -->
    @include('layouts.head-css')

    <!-- DATEPICKER POSITION -->	
	<style>		
		.datepicker2 { z-index: 10000 !important; }
    </style>

</head>

<body>

    <!-- BEGIN MODAL FORM -->
    <div id="div-form-modal" class="modal fade" tabindex="-1" role="dialog" data-bs-backdrop="static" data-keyboard="false" aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">

            </div>
        </div>
    </div>
    <!-- END MODAL FORM -->

    <!-- Begin page -->
    <div id="layout-wrapper">
        <!-- topbar -->
        @include('layouts.topbar')
        <!-- sidebar components -->
        @include($sidebar ?? 'layouts.sidebar')

        <!-- ============================================================== -->
        <!-- Start right Content here -->
        <!-- ============================================================== -->
        <div class="main-content">

            <div class="page-content">
                <div class="container-fluid">

                    <!-- start page title -->
                    <div class="row">
                        <div class="col-12">
                            <div class="page-title-box d-flex align-items-center justify-content-between">
                                <div>
                                    <h4 class="fs-16 fw-semibold mb-1 mb-md-2">@yield('title')</h4>
                                    <p class="text-muted mb-0">{{ $form_remark ?? '' }}</p>
                                </div>
                                <div class="page-title-right">
                                    @if(isset($breads))
                                    <ol class="breadcrumb m-0">
                                        {{-- <li class="breadcrumb-item"><a href="javascript: void(0);">@yield('topbar-title')</a>
                                        </li>
                                        <li class="breadcrumb-item active">@yield('sub-title')</li> --}}

                                        @php      
                                            $length = sizeof($breads);
                                            $i = 0; 
                                            $class = 'class="breadcrumb-item"';     
                                            $icon = '';
                                            foreach ($breads as $bread){
                                                $i += 1;
                                    
                                                if($i == $length){
                                                    $class = 'class="breadcrumb-item active text-primary"';
                                                }
                                                echo '<li ' . $class . '>'.$bread.'</li>';
                                            }  
                                        @endphp
                                    </ol>
                                    @endif
                                </div>

                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <!-- CSRF TOKEN -->
                    <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/>

                    <!-- MAIN CONTENT -->
                    <div id="div-main-content">
                        @yield('content')
                    </div>

                </div>
                <!-- container-fluid -->
            </div>
            <!-- End Page-content -->

            <!-- footer -->
            @include('layouts.footer')

        </div>
        <!-- end main content-->
    </div>
    <!-- END layout-wrapper -->

    <!-- customizer -->
    @include('layouts.right-sidebar')

    <!-- vendor-scripts -->
    @include('layouts.vendor-scripts')

    <!-- CUSTOM SCRIPT -->
    <script src="{{ URL::asset('public/js/save.js') }}"></script>
    <script src="{{ URL::asset('public/js/router.js') }}"></script>

</body>

</html>
