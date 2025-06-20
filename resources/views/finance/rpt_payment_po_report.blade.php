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
            
            $group_paymentamount = 0;	
            $group_invoiceamount = 0;	
            $group_invoiceamountnopph = 0;	
            $group_poamount = 0;	
            
            $group1 = '';
            $group2 = '';		
            
            $total_paymentamount = 0;
            $total_invoiceamount = 0;
            $total_invoiceamountnopph = 0;
            $total_poamount = 0;

            echo "<table id=\"table-report\" class=\"minimalistBlack\">";	

            echo "<thead>";										
            echo "<tr>\n";         
                echo "<th>NO</th>\n";                                
                echo "<th width=300 px>PO DESCRIPTION</th>\n";     
                echo "<th width=100 px>INV NO</th>\n";    
                echo "<th width=500 px>INV DESCRIPTION</th>\n";
                echo "<th width=90 px style=\"text-align:right;\">INV AMOUNT</th>\n";
                echo "<th width=90 px style=\"text-align:right;\">INV AMOUNT WITHOUT PPH</th>\n";
                echo "<th width=90 px style=\"text-align:right;\">AMOUNT PPH</th>\n";
                echo "<th width=150 px>PAYMENT ID</th>\n";
                echo "<th width=150 px>PDC NO</th>\n";
                echo "<th width=500 px>PAYMENT DESCRIPTION</th>\n";
                echo "<th width=90 px style=\"text-align:right;\">PAYMENT AMOUNT</th>\n";
                echo "<th width=90 px style=\"text-align:right;\">OS INV - PAYMENT </th>\n";
                echo "<th width=90 px style=\"text-align:right;\">OS PO - INV WITHOUT PPH</th>\n";
            echo "</tr>\n";
            echo "</thead>";
            echo "<tbody>";
            
            $group_name = '';
            $group_prev_name = '';
            $journal_date = '';
            
            $group_invoice = '';
            $group_prev_invoice = '';

            foreach ($records as $row):
                $row_number += 1;			
                    
                $total_paymentamount += $row->PaymentAmount;
                $total_invoiceamount += $row->InvoiceAmount;
                $total_invoiceamountnopph += $row->InvoiceAmountNoPPH;
                $total_poamount += $row->POAmount;

                $group1 = $row->PONumber;
                
                if($row_number == 1){
                    $group_name = $row->PONumber;
                    $group_prev_name = $row->PONumber;
                    $group_invoice = $row->InvoiceNo;
                    $group_prev_invoice = $row->InvoiceNo;
                } else {
                    $group_name = $row->PONumber;
                    $group_invoice = $row->InvoiceNo;
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
                        echo "<td class=\"$td_class text-right\">PO AMOUNT :</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_poamount,2,'.',',') . "</td>"; 
                        echo "<td class=\"$td_class text-right\">SUB TOTAL INVOICE :</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamount,2,'.',',') . "</td>";    
                        echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamountnopph,2,'.',',') . "</td>";      
                        echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamountnopph-$group_invoiceamount,2,'.',',') . "</td>";     
                        echo "<td class=\"$td_class\"></td>";
                        echo "<td class=\"$td_class\"></td>";
                        // echo "<td class=\"$td_class text-right\">SUB TOTAL PAYMENT $group_prev_name :</td>";
                        echo "<td class=\"$td_class text-right\">SUB TOTAL PAYMENT :</td>";
                        echo "<td class=\"$td_class text-right\">" . number_format($group_paymentamount,2,'.',',') . "</td>";                                                                                        					
                        echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamount-$group_paymentamount,2,'.',',') . "</td>";    
                        echo "<td class=\"$td_class text-right\">" . number_format($group_poamount-$group_invoiceamountnopph,2,'.',',') . "</td>"; 
                        // echo "<td class=\"$td_class text-right\">" . number_format($group_poamount-$group_invoiceamountnopph,2,'.',',') . "</td>"; 
                        echo "</tr>\n";
                        echo "<tr>\n";
                            echo "<td colspan=\"13\">&nbsp;</td>";
                        echo "</tr>\n";
                        //echo "</tbody>";
                        //echo "</table>";

                        $group_prev_name = $group_name;
                        $group_prev_invoice = $group_invoice;
                        
                    } 			
                    
                    $group_number = 0; //Reset Group Number		
                    
                    $group_paymentamount = 0;				
                    $group_invoiceamount = 0;	
                    $group_invoiceamountnopph = 0;	
                    $group_poamount = 0;	
            
                    $group2 = $group1;
                }
                
                $group_number += 1;		
                                    
                $group_paymentamount += $row->PaymentAmount;
                $group_invoiceamount += $row->InvoiceAmount;
                $group_invoiceamountnopph += $row->InvoiceAmountNoPPH;
                $group_poamount = $row->POAmount;
                
                $td_class="tdgrid";
                    
                if($row_number % 2 == 1)
                {
                    $td_class="active";
                }
                else
                {
                    $td_class="";
                }
            

                if ($row->PONumber !== NULL && $group_number == 1) {
                    echo "<tr>\n";
                    echo "<td colspan='13' class=\"$td_class\" style=\"font-weight: bold;\">Partner: $row->PartnerName, No: $row->PONumber, Amount: Rp " . number_format($row->POAmount,2,'.',',') . "</td>";
                    echo "</tr>\n";
                }
                echo "<tr>\n";

                if ($group_invoice == $group_prev_invoice && $group_number !== 1) {

                    $group_invoiceamount = $group_invoiceamount - $row->InvoiceAmount;
                    $group_invoiceamountnopph = $group_invoiceamountnopph - $row->InvoiceAmountNoPPH;
                    $total_invoiceamount = $total_invoiceamount - $row->InvoiceAmount;
                    $total_invoiceamountnopph = $total_invoiceamountnopph - $row->InvoiceAmountNoPPH;

                    echo "<tr>\n";                
                    echo "<td class=\"$td_class center-align\">" . $group_number . "</td>\n";                
                    
                    // if($row->PODate !== NULL){
                    //     $PODate = date('d M Y',strtotime($row->PODate));
                    // }
                    
                    // if($row->POApproveDate !== NULL){
                    //     $POApproveDate = date('d M Y',strtotime($row->POApproveDate));
                    // }
                    
                    // echo "<td class=\"$td_class\">" .  $PODate . "</td>\n";    
                    // echo "<td class=\"$td_class\">" .  $POApproveDate . "</td>\n";  
                    echo "<td class=\"$td_class\"></td>";
                    echo "<td class=\"$td_class\"></td>";
                    echo "<td class=\"$td_class\"></td>";
                    echo "<td class=\"$td_class\"></td>";
                    echo "<td class=\"$td_class\"></td>";
                    echo "<td class=\"$td_class\"></td>";
                    echo "<td class=\"$td_class\">" . $row->PaymentID . "</td>\n";   
                    echo "<td class=\"$td_class\">" . $row->PDCNo . "</td>\n";   
                    echo "<td class=\"$td_class\">" . $row->PaymentDescription . "</td>\n";
                    echo "<td class=\"$td_class text-right\">" . number_format($row->PaymentAmount,2,'.',',') . "</td>\n";
                    
                    echo "</tr>\n";
                }
                else
                {
                    echo "<tr>\n";                
                    echo "<td class=\"$td_class center-align\">" . $group_number . "</td>\n";                
                    
                    // if($row->PODate !== NULL){
                    //     $PODate = date('d M Y',strtotime($row->PODate));
                    // }
                    
                    // if($row->POApproveDate !== NULL){
                    //     $POApproveDate = date('d M Y',strtotime($row->POApproveDate));
                    // }
                    
                    // echo "<td class=\"$td_class\">" .  $PODate . "</td>\n";    
                    // echo "<td class=\"$td_class\">" .  $POApproveDate . "</td>\n";  
                    echo "<td class=\"$td_class\">" . $row->PODescription . "</td>\n";	
                    echo "<td class=\"$td_class\">" . $row->InvoiceNo . "</a></td>\n";  
                    echo "<td class=\"$td_class\">" . $row->InvoiceDescription . "</td>\n";
                    echo "<td class=\"$td_class text-right\">" . number_format($row->InvoiceAmount,2,'.',',') . "</td>\n";
                    echo "<td class=\"$td_class text-right\">" . number_format($row->InvoiceAmountNoPPH,2,'.',',') . "</td>\n";
                    echo "<td class=\"$td_class text-right\">" . number_format($row->InvoiceAmountNoPPH-$row->InvoiceAmount,2,'.',',') . "</td>\n";
                    echo "<td class=\"$td_class\">" . $row->PaymentID . "</td>\n";   
                    echo "<td class=\"$td_class\">" . $row->PDCNo . "</td>\n";   
                    echo "<td class=\"$td_class\">" . $row->PaymentDescription . "</td>\n";
                    echo "<td class=\"$td_class text-right\">" . number_format($row->PaymentAmount,2,'.',',') . "</td>\n";
                    
                    echo "</tr>\n";
                }
            endforeach;

            echo "<tr class=\"total\">\n";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class text-right\">PO AMOUNT :</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($group_poamount,2,'.',',') . "</td>";   
                echo "<td class=\"$td_class text-right\">SUB TOTAL INVOICE :</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamount,2,'.',',') . "</td>"; 
                echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamountnopph,2,'.',',') . "</td>"; 
                echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamountnopph-$group_invoiceamount,2,'.',',') . "</td>"; 
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                // echo "<td class=\"$td_class text-right\">SUB TOTAL PAYMENT $group_prev_name :</td>";
                echo "<td class=\"$td_class text-right\">SUB TOTAL PAYMENT :</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($group_paymentamount,2,'.',',') . "</td>";                                					
                echo "<td class=\"$td_class text-right\">" . number_format($group_invoiceamount-$group_paymentamount,2,'.',',') . "</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($group_poamount-$group_invoiceamountnopph,2,'.',',') . "</td>";        
                // echo "<td class=\"$td_class text-right\">" . number_format($group_poamount-$group_invoiceamountnopph,2,'.',',') . "</td>"; 
            echo "</tr>\n";
            echo "<tr class=\"total\">\n";
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class text-right\">GRAND TOTAL PO AMOUNT :</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($total_poamount,2,'.',',') . "</td>";  
                echo "<td class=\"$td_class text-right\">GRAND TOTAL INVOICE :</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($total_invoiceamount,2,'.',',') . "</td>";    
                echo "<td class=\"$td_class text-right\">" . number_format($total_invoiceamountnopph,2,'.',',') . "</td>";    
                echo "<td class=\"$td_class text-right\">" . number_format($total_invoiceamountnopph-$total_invoiceamount,2,'.',',') . "</td>";    
                echo "<td class=\"$td_class\"></td>";
                echo "<td class=\"$td_class\"></td>";
                // echo "<td class=\"$td_class text-right\">GRAND TOTAL PAYMENT($row_number item) :</td>";
                echo "<td class=\"$td_class text-right\">GRAND TOTAL PAYMENT :</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($total_paymentamount,2,'.',',') . "</td>";                                 						
                echo "<td class=\"$td_class text-right\">" . number_format($total_invoiceamount-$total_paymentamount,2,'.',',') . "</td>";
                echo "<td class=\"$td_class text-right\">" . number_format($total_poamount-$total_invoiceamountnopph,2,'.',',') . "</td>";     
                // echo "<td class=\"$td_class text-right\">" . number_format($total_poamount-$total_invoiceamountnopph,2,'.',',') . "</td>";   
            echo "</tr>\n";
            echo "</tbody>";
            echo "</table>";
            //echo "</div>";		
        }    
    ?>
    <!-- END REPORT DATA -->   

@endsection