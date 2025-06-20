<!DOCTYPE html>
<html>
<head>
    <title>@yield('title')</title>
    <!-- Meta-Tags -->
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="utf-8">
    <meta name="keywords" content="PDF Document">    
	<meta name="csrf-token" content="{{ csrf_token() }}">
    <!-- //Meta-Tags -->    

    <!-- CSS FILES -->    
    <link rel="shortcut icon" href="{{ URL::asset('public/logo-tunas-small.png') }}" />
    <link href="{{ URL::asset('public/assets_view/css/pdf.css') }}" rel="stylesheet" type="text/css" media="all"/>
    
    {{-- <style>
    @font-face {
        font-family: "tahoma";
        src: url("{{ storage_path('fonts/tahoma.ttf') }}");
        font-weight: normal;
    }
    @font-face {
        font-family: "tahoma";
        src: url("{{ storage_path('fonts/tahomabd.ttf') }}");
        font-weight: bold;
    }
    </style> --}}

    <style>
        .td-10{
            width: 10%;
        }

        .td-15{
            width: 15%;
        }

        .td-20{
            width: 20%;
        }

        .td-25{
            width: 25%;
        }

        .td-30{
            width: 30%;
        }

        .td-35{
            width: 35%;
        }

        .td-40{
            width: 40%;
        }

        .td-50{
            width: 50%;
        }

        .td-60{
            width: 60%;
        }

        .td-65{
            width: 65%;
        }

        .td-70{
            width: 70%;
        }

        .td-75{
            width: 75%;
        }

        .td-85{
            width: 85%;
        }

        .text-right {
            text-align: right;
        }

        .text-left {
            text-align: left;
        }

        .text-center{
            text-align: center;
        }

        .total {	
            font-size: 11px;
            font-weight: bold;
            color: #000000;	
        }

        br
        {
            clear: left;
            height: 3px;
        }

        .param-key {	
            font-size: 12px;
            font-weight: bold;
            color: #000000;	
            width: 200px;
        }

        .param-value {	
            font-size: 12px;
            font-weight: normal;
            color: #000000;	
            width: 400px;
        }

        .document-title{
            margin-top: 10px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .page-break {
            page-break-after: always;
        }

        table {    
            border: 1px solid #000000;
            width: 100%;
            text-align: left;
            border-collapse: collapse;
        }

        /* tr {
            page-break-inside: avoid;
        } */

        /* .table-nobreak {
            page-break-inside: avoid;
        } */

        th, td {    
            border: 1px solid #000000;
            padding: 5px 4px;  
            font-size: 11px;
	        vertical-align: top;       
        }

        .noborder {
            border: none;
        }

        .nomargin{
            margin: 0;
        }

        .nopadding{
            padding: 0;
        }

        /* header { */
            /* position: fixed;
            top: -60px;
            left: 0px;
            right: 0px;
            height: 50px; */

            /** Extra personal styles **/
            /* background-color: #03a9f4;
            color: white;
            text-align: center;
            line-height: 35px; */
        /* } */

        .footer {                             
            position: fixed; 
            bottom: -10px; 
            left: 0px; 
            right: 0px;
            height: 25px; 
            padding: 0;
            margin: 0;           
            text-align: center;
        }

        .footer p {
            margin-bottom: 0;
            align: center;
        }  
        
        footer  {                             
            position: absolute; 
            bottom: -10px; 
            left: 0px; 
            right: 0px;
            height: 25px; 
            padding: 0;
            margin: 0;           
            text-align: center;
        }

        /* .footer2 :first {
            page-break-before: always;
            position: fixed; 
            bottom: 0px; 
            left: 0px; 
            right: 0px;
            height: 25px; 
            padding: 0; 
            margin: 0;                   
            text-align: center;   
            background-color: #03a9f4;  
            margin-bottom: 0;       
        } */

    </style>
    
</head>
<body>    
    @yield('content')
    {{-- <footer>
        <hr>
        @yield('footer')        
    </footer> --}}
</body>
</html>