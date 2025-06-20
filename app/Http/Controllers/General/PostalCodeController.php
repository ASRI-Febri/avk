<?php

namespace App\Http\Controllers\General;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use PDF;

class PostalCodeController extends MyController
{   
    public function search_postal_code(Request $request)
    {
        $page = $request->input('page',10);			
        $search_value = $request->input('q','');

        $sql = "SELECT TOP 200 IDX_M_PostalCode, IDX_M_Country, Province, Info, City, District, Subdistrict, Zip  
                FROM [dbo].[GN_M_PostalCode] 
                WHERE (Subdistrict LIKE '%$search_value%' OR City LIKE '%$search_value%')";
        
        $param = array();
        $records = $this->exec_sql($sql,'record','sqlsrv');

        $items = array();
        $row_array = array();

        // foreach ($records as $row){
        
        //     $row_array['label'] = $row->Province . ', ' . $row->Info . ' ' . $row->City . ', ' . $row->District . ', ' . $row->Subdistrict . ', ' . $row->Zip;				
            
        //     $row_array['IDX_M_PostalCode'] = $row->IDX_M_PostalCode;
        //     $row_array['Province'] = $row->Province;
        //     $row_array['Info'] = $row->Info;
        //     $row_array['City'] = $row->City;
        //     $row_array['District'] = $row->District;
        //     $row_array['Subdistrict'] = $row->Subdistrict; 
        //     $row_array['Zip'] = $row->Zip;            
            
        //     array_push($items, $row_array);	            
        // }

        foreach ($records as $row)
        {
            $row_array['id'] = (double)$row->IDX_M_PostalCode;
            $row_array['text'] = $row->Province . ', ' . $row->Info . ' ' . $row->City . ', ' . $row->District . ', ' . $row->Subdistrict . ', ' . $row->Zip;				            
            
            $row_array['IDX_M_PostalCode'] = (double)$row->IDX_M_PostalCode;
            $row_array['Province'] = $row->Province;
            $row_array['Info'] = $row->Info;
            $row_array['City'] = $row->City;
            $row_array['District'] = $row->District;
            $row_array['Subdistrict'] = $row->Subdistrict; 
            $row_array['Zip'] = $row->Zip;            
            
            array_push($items, $row_array);	            
        }

        $result["results"] = $items;
        $result["pagination"] = array("more" => true);
			
        //echo json_encode($items);

        return response()->json($items); 
    }
}