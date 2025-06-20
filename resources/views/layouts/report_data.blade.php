<!DOCTYPE html>
<html>
<head>
    <title>@yield('title')</title>
    <!-- Meta-Tags -->
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="utf-8">
    <meta name="keywords" content="ASBS">    
	<meta name="csrf-token" content="{{ csrf_token() }}">
    <!-- //Meta-Tags -->

    <!-- CSS FILES -->    
    <link href="{{ URL::asset('public/css/report-view.css') }}" rel="stylesheet" type="text/css" media="all"/>
    <link href="{{ URL::asset('public/css/report-print.css') }}" rel="stylesheet" type="text/css" media="all"/>    

    <script src="{{ URL::asset('public/js/jquery.min.js') }}"></script>
    <script src="{{ URL::asset('public/js/jquery.table2excel.js') }}"></script>    

    <script type="text/javascript" language="javascript">

		$(document).ready(function(){			
			
			$("#export_xls").click(function (){
				
				$("#table-report").table2excel({
					exclude: ".noExl",
					name: "Excel Document Name",
					fileext: ".xls"
				});
				
			});

		});
	
	</script>

    <!-- WEB ICON -->
	<link rel="shortcut icon" href="{{ URL::asset('public/logo-quality-small.png') }}" />
	
	<style>
		@media print {
			a[href]:after {
				content: none !important;
			}
		  
			#export_xls {
				display: none !important;
			}
		}	

        .header {            
            width: 100%;
            position: relative;
            margin-bottom: 0;
        }

        .wrapper {
            width: 100%;
            position: relative;
            margin: 30px 0;
        }

        .logo {
            display: flex;
        }

        .logo img {
            
        }

        .header-text {
            text-align: center;
            position: absolute;
            font-weight: bold;
            font-size: 18px;
            width: 100%;
            top: 50%;
            transform: translateY(-50%);
        }

        .header-small {
            text-align: center;
            position: absolute;
            font-weight: bold;
            font-size: 14px;
            width: 100%;
            top: 100%;
            /* transform: translateY(-50%); */
        }

    </style>
    
    <!-- BEGIN CHECK TOP LOCATION -->
	<script language="javascript">
        if(self.location == top.location){ 
            //self.location="index.html";
            //alert('top');
        } else {
            //alert('not top');
            //self.location="index.html";
            top.location.href = "{{ url('/login') }}"; 
        }
    </script>
    <!-- END CHECK TOP LOCATION -->	
</head>
<body class="full-width">
    <!-- BEGIN PAGE CONTAINER -->
	<div class="page-container">        
	    <div class="page-content">            
	        <div class="page-header">
                <div class="page-title">
                    {{-- <img src="{{ url('public/logo-tunas-with-font-small.png') }}" width="142" height="60" />
                    <h2>@yield('pagetitle')</h2> --}}

                    <header class="header">
                        <div class="wrapper">
                            <div class="logo">
                                <img src="{{ url('public/logo-quality.jpeg') }}" width="142" height="60" />
                            </div>
                            <div class="header-text">
                                @yield('pagetitle')     
                                <br>
                                <div class="header-small">
                                    @yield('report_parameter')    

                                    <div style="float:right;width:100%; text-align: right;">
                                        <button id="export_xls" name="export_xls" type="button" class="btn btn-xs btn-success btn-icon heading-btn"><i class="icon-file-excel"></i> Export Excel</button>
                                    </div>
                                </div>                                                      
                            </div>
                        </div>
                    </header>

                </div>
            </div>             

            @yield('content')    
        </div>            
    </div>
    <!-- END PAGE CONTAINER -->
</body>
</html>