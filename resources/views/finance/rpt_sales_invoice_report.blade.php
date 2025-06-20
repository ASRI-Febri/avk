@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content') 

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">Report Date</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr> 
                <tr>
                    <td class="param-key">Branch</td>
                    <td class="param-value">: {{ $BranchDesc }}</td>
                </tr>
                <tr>
                    <td class="param-key">Partner</td>
                    <td class="param-value">: {{ $fields['PartnerDesc'] }}</td>
                </tr>
            </table>
        </div>
        {{-- <div style="float:left;width:30%; text-align: right;">
            <button id="export_xls" name="export_xls" type="button" class="btn btn-xs btn-success btn-icon heading-btn"><i class="icon-file-excel"></i> Export Excel</button>
        </div> --}}
        
    </div>
    <br/>        
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <?php
        if (!$records)
        {
            echo "<div class=\"text-danger text-bold\">Data Not Found!</div>";
        }
    ?>

    <br/>

    <?php
        //echo "<br/>";		
        if($records)
        {
            //echo "<div class=\"table-responsive\">";
            
        $row_number = 0;
        $group_number = 0;	
        
        $group_bb = 0;
        $group_dpp = 0;
        $group_ppn = 0;
        $group_db = 0;
        $group_cr = 0;
        $group_eb = 0;
        $group_os = 0;
        $group_os_fp = 0;
        $group_total_amount = 0;		
        
        $group1 = '';
        $group2 = '';		
        
        $total_bb = 0;
        $total_dpp = 0;
        $total_ppn = 0;
        $total_invoice = 0;
        $total_paid = 0;
        $total_os = 0;
        $total_os = 0;
        $total_os_fp = 0;
        $total_amount = 0;		

        echo "<table id=\"table-report\" class=\"minimalistBlack\">";	

        echo "<thead>";										
        echo "<tr>\n";         
            echo "<th>NO</th>\n";                                
            echo "<th>INVOICE DATE</th>\n";
            echo "<th>INVOICE NO</th>\n";
            echo "<th>CUSTOMER</th>\n";
            // echo "<th>SALES PERSON</th>\n";
            // echo "<th>TAX INVOICE NO</th>\n";   
            echo "<th>NOTES</th>\n";                                			
            echo "<th style=\"text-align:right;\">DPP</th>\n";
            echo "<th style=\"text-align:right;\">PPN</th>\n";
            echo "<th style=\"text-align:right;\">TOTAL</th>\n";
            echo "<th style=\"text-align:right;\">PAID</th>\n";
            echo "<th style=\"text-align:right;\">OUTSTANDING</th>\n";                                				
        echo "</tr>\n";
        echo "</thead>";
        echo "<tbody>";
        
        $group_name = '';
        $group_prev_name = '';
        $journal_date = '';

        foreach ($records as $row):
            $row_number += 1;			
                
            $total_dpp += $row->TotalDPP;
            $total_ppn += $row->TotalPPN;
            $total_invoice += $row->TotalInvoice;
            $total_paid += $row->ReceiveAmount;
            $total_os += ($row->TotalInvoice - $row->ReceiveAmount);
            //$total_os += $row->Outstanding;
            //$total_os_fp += $row->OutstandingFP;			
            //$total_amount += $row->SaldoAktual;

            $group1 = $row->IDX_M_Branch;
            
            if($row_number == 1){
                $group_name = $row->IDX_M_Branch;
                $group_prev_name = $row->IDX_M_Branch;
            } else {
                $group_name = $row->IDX_M_Branch;
            }

            if(trim($group_name) <> trim($group_prev_name)){   
                //echo 'diff';                                 
                //$group_prev_name = $group_name;                                                                                                
            } 

            if($group1 <> $group2)
            {
                if($row_number > 1)
                {   
                    echo "<tr class=\"total\">\n";
                        echo "<td class=\"$td_class\"></td>";
                        echo "<td class=\"$td_class\"></td>";
                        echo "<td class=\"$td_class\"></td>";
                        // echo "<td class=\"$td_class\"></td>";
                        // echo "<td class=\"$td_class\"></td>";
                        echo "<td class=\"$td_class\"></td>";
                        echo "<td class=\"$td_class text-right\">SUB TOTAL $group_prev_name ($group_number item) :</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_dpp,2,'.',',') . "</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_ppn,2,'.',',') . "</td>";                                               
                        echo "<td class=\"$td_class text-right\">" . number_format($group_db,2,'.',',') . "</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_cr,2,'.',',') . "</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_os,2,'.',',') . "</td>";                                            					
                    echo "</tr>\n";
                    echo "<tr>\n";
                        echo "<td colspan=\"10\">&nbsp;</td>";
                    echo "</tr>\n";
                    //echo "</tbody>";
                    //echo "</table>";

                    $group_prev_name = $group_name; 
                    
                } 			
                
                $group_number = 0; //Reset Group Number		
                
                $group_bb = 0;
                $group_dpp = 0;
                $group_ppn = 0;
                $group_db = 0;
                $group_cr = 0;
                $group_eb = 0;
                $group_os = 0;
                $group_os_fp = 0;				
                $group_total_amount = 0;				
        
                $group2 = $group1;
            }
            
            $group_number += 1;		
                                
            $group_dpp += $row->TotalDPP;
            $group_ppn += $row->TotalPPN;
            $group_db += $row->TotalInvoice;
            $group_cr += $row->ReceiveAmount;
            
            $group_os += ($row->TotalInvoice - $row->ReceiveAmount);
            //$group_os_fp += $row->OutstandingFP;		
            //$group_total_amount += $row->SaldoAktual;
            
            $td_class="tdgrid";
                
            if($row_number % 2 == 1)
            {
                $td_class="active";
            }
            else
            {
                $td_class="";
            }

            echo "<tr>\n";                
                echo "<td class=\"$td_class center-align\">" . $group_number . "</td>\n";                
                /*
                echo "<td class=\"$td_class center-align\">" . 
                    anchor_popup("sales/sales_order_list/view_info/$row->SalesOrderId",$row->SalesOrderId)					 
                    . "</td>\n";
                */
                //echo "<td class=\"$td_class\">" . $row->CompanyID . "</td>\n";	
                
                if($row->InvoiceDate !== NULL){
                    $invoice_date = date('d M Y',strtotime($row->InvoiceDate));
                }
                
                echo "<td class=\"$td_class\">" .  $invoice_date . "</td>\n";    
                //echo "<td class=\"$td_class\">" . $row->InvoiceNo . "</td>\n";  
                echo "<td class=\"$td_class\">" . $row->InvoiceNo . "</a></td>\n";  
                echo "<td class=\"$td_class\">" . $row->PartnerName . "</td>\n";   
                // echo "<td class=\"$td_class\">" . $row->SalesPersonName . "</td>\n"; 

                /*
                echo "<td class=\"$td_class\">" . 
                    '<a href="#" class="text-default display-inline-block">
                        <span class="text-semibold">' . $row->InvoiceNo  . '</span>
                        <span class="display-block text-muted text-semibold text-info">' . $invoice_date . '</span>                                            
                    </a>'
                . "</td>\n";	
                */

                // echo "<td class=\"$td_class\">" . $row->TaxInvoiceNo . "</td>\n";	
                echo "<td class=\"$td_class\">" . $row->RemarkHeader . "</td>\n";		
                echo "<td class=\"$td_class text-right\">" . number_format($row->TotalDPP,2,'.',',') . "</td>\n";
                echo "<td class=\"$td_class text-right\">" . number_format($row->TotalPPN,2,'.',',') . "</td>\n";
                echo "<td class=\"$td_class text-right\">" . number_format($row->TotalInvoice,2,'.',',') . "</td>\n";
                echo "<td class=\"$td_class text-right\">" . number_format($row->ReceiveAmount,2,'.',',') . "</td>\n";
                //echo "<td class=\"$td_class text-right\">" . number_format($row->BBalanceAmount,2,'.',',') . "</td>\n"; 
                echo "<td class=\"$td_class text-right\">" . number_format($row->TotalInvoice - $row->ReceiveAmount,2,'.',',') . "</td>\n"; 
                
            echo "</tr>\n";
        endforeach;

        echo "<tr class=\"total\">\n";
            echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class\"></td>";
            // echo "<td class=\"$td_class\"></td>";
            // echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class text-right\">SUB TOTAL $group_prev_name ($group_number item) :</td>";      
            echo "<td class=\"$td_class text-right\">" . number_format($group_dpp,2,'.',',') . "</td>";
            echo "<td class=\"$td_class text-right\">" . number_format($group_ppn,2,'.',',') . "</td>";                            
            echo "<td class=\"$td_class text-right\">" . number_format($group_db,2,'.',',') . "</td>";
            echo "<td class=\"$td_class text-right\">" . number_format($group_cr,2,'.',',') . "</td>";
            echo "<td class=\"$td_class text-right\">" . number_format($group_os,2,'.',',') . "</td>";                               					
        echo "</tr>\n";
        echo "<tr class=\"total\">\n";
            echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class\"></td>";
            // echo "<td class=\"$td_class\"></td>";
            // echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class\"></td>";
            echo "<td class=\"$td_class text-right\">TOTAL ($row_number item) :</td>";       
            echo "<td class=\"$td_class text-right\">" . number_format($total_dpp,2,'.',',') . "</td>";
            echo "<td class=\"$td_class text-right\">" . number_format($total_ppn,2,'.',',') . "</td>";                         
            echo "<td class=\"$td_class text-right\">" . number_format($total_invoice,2,'.',',') . "</td>";
            echo "<td class=\"$td_class text-right\">" . number_format($total_paid,2,'.',',') . "</td>";
            echo "<td class=\"$td_class text-right\">" . number_format($total_os,2,'.',',') . "</td>";                                						
        echo "</tr>\n";
        echo "</tbody>";
        echo "</table>";
        //echo "</div>";		
        }    
    ?>
    <!-- END REPORT DATA -->   

@endsection