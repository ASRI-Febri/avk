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
            
            $group_total_amount = 0;		
            
            $group1 = '';
            $group2 = '';	
            
            $total_amount = 0;		

            echo "<table id=\"table-report\" class=\"minimalistBlack\">";	

            echo "<thead>";										
            echo "<tr>\n";         
                echo "<th width=\"20\">NO</th>\n";                                
                echo "<th width=\"30\">COMPANY</th>\n";      
                echo "<th width=\"50\">PAYMENT DATE</th>\n";
                echo "<th width=\"100\">PAYMENT NO</th>\n";                                
                echo "<th width=\"140\">CASH / BANK</th>\n";
                echo "<th width=\"40\">STATUS</th>\n";   
                echo "<th width=\"300\">NOTES</th>\n";                          			
                echo "<th width=\"120\" style=\"text-align:right;\">TOTAL</th>\n";                                                               				
            echo "</tr>\n";
            echo "</thead>";
            echo "<tbody>";
            
            $group_name = '';
            $group_prev_name = '';                           

            foreach ($records as $row):

                $row_number += 1;			                                   
                
                $total_amount += $row->PaymentAmount;                               

                $group1 = $row->IDX_M_Branch;
                
                if($row_number == 1){
                    $group_name = $row->IDX_M_Branch . ' - '  . $row->BranchName;
                    $group_prev_name = $row->IDX_M_Branch . ' - '  . $row->BranchName;
                } else {
                    $group_name = $row->IDX_M_Branch . ' - '  . $row->BranchName;
                }

                if($group1 <> $group2)
                {
                    if($row_number > 1)
                    {   
                        echo "<tr class=\"text-bold\">\n";
                            echo "<td class=\"$td_class\"></td>";
                            echo "<td class=\"$td_class\"></td>";
                            echo "<td class=\"$td_class\"></td>";
                            echo "<td class=\"$td_class\"></td>";
                            echo "<td class=\"$td_class\"></td>";                                            
                            echo "<td class=\"$td_class\"></td>";
                            echo "<td class=\"$td_class text-right\">SUB TOTAL $group_prev_name ($group_number item) :</td>";                                                                                        
                            echo "<td class=\"$td_class text-right\">" . number_format($group_total,2,'.',',') . "</td>";                                                                                     					
                        echo "</tr>\n";
                        echo "<tr>\n";
                            echo "<td colspan=\"10\">&nbsp;</td>";
                        echo "</tr>\n";

                        $group_prev_name = $group_name; 
                    } 			
                    
                    $$group_number = 0; //Reset Group Number	
                    $group_total_amount = 0;				
                    $group2 = $group1;
                }
                
                $group_number += 1;		
                                                
                $group_total_amount += $row->PaymentAmount;
                
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
                    echo "<td class=\"$td_class text-center center-align\">" . $group_number . "</td>\n";                
                    /*
                    echo "<td class=\"$td_class center-align\">" . 
                        anchor_popup("sales/sales_order_list/view_info/$row->SalesOrderId",$row->SalesOrderId)					 
                        . "</td>\n";
                    */
                    //echo "<td class=\"$td_class\">" . $row->CompanyID . "</td>\n";	
                    
                    if($row->PaymentDate !== NULL){
                        $payment_date = date('d M Y',strtotime($row->PaymentDate));
                    }
                    
                    echo "<td class=\"$td_class text-center\">" .  $row->BranchID . "</td>\n";  
                    echo "<td class=\"$td_class text-center\">" .  $payment_date . "</td>\n";    
                    //echo "<td class=\"$td_class\">" . $row->InvoiceNo . "</td>\n";  
                    echo "<td class=\"$td_class\">" . $row->PaymentID . "</a></td>\n";                                      
                    echo "<td class=\"$td_class\">" . $row->FinancialAccountDesc . "</td>\n";		
                    echo "<td class=\"$td_class text-center\">" . $row->PaymentStatusDesc . "</td>\n";
                    echo "<td class=\"$td_class\">" . $row->RemarkHeader . "</td>\n";
                    echo "<td class=\"$td_class text-right\">" . number_format($row->PaymentAmount,2,'.',',') . "</td>\n"; 
                    
                echo "</tr>\n";
            endforeach;

            echo "<tr class=\"total\">\n";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";                                
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class text-right\">SUB TOTAL $group_prev_name ($group_number item) :</td>";                                                               
                echo "<td class=\"$td_class text-right\">" . number_format($group_total_amount,2,'.',',') . "</td>";                               					
            echo "</tr>\n";
            echo "<tr class=\"total\">\n";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";                                
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class text-right\">TOTAL ($row_number item) :</td>"; 
                echo "<td class=\"$td_class text-right\">" . number_format($total_amount,2,'.',',') . "</td>";                                						
            echo "</tr>\n";
            echo "</tbody>";
            echo "</table>";
            //echo "</div>";		
        }    
    ?>
    <!-- END REPORT DATA -->   

@endsection