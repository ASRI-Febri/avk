<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Symfony\Component\HttpFoundation\Response;

// MODEL
use App\Models\Security\Menu;

class MyController extends Controller
{ 
    private $_avatar;

    // PUBLIC VARIABLE
    public $data = array();
    public $img_logo;

    // TABLE NAME
    public $table_name;
    
	//---------------------------------------
	public $sp_getdetail_list;
    public $sp_getinquiry; // FOR DATATABLES
    
    // ARRAY COLUMN AND FILTER FOR DATATABLES
	public $array_column = array();
	public $array_filter = array();

    public function __construct(Request $request)
    {    
        $this->data['title'] = 'Clivax';

        // GET APPLICATION LIST
        //$param['NIK'] = (string)trim(session('user_id'));
        //$this->data['records_application'] = $this->exec_sp('USP_SM_ApplicationByUser_List',$param,'list','sqlsrv');

        date_default_timezone_set("Asia/Jakarta");

        $route_exception = array('register-new-account',            
            'register-new-account/save',
            'sm-forgot-password',
            'login',            
            'login/validate_user',
            'logout',
            'test'
        );

        $uri = $request->path();

        if(in_array($uri, $route_exception) == FALSE)
        {
            $this->middleware(function ($request, $next)
            {
                $token = $request->session()->get('token');               
                
                if(trim($token) == '')
                {
                    return redirect('login');                
                }                

                $this->get_avatar();      
                $this->data['user_index'] = session('user_index');
                $this->data['user_id'] = 'it_febry'; //session('user_id');
                $this->data['user_name'] = session('user_name');

                // $next_url = $request->input('goto');

                // if($next_url !== '')
                // {
                //     return redirect('/home'); 
                // }
                // else 
                // {
                //     return redirect($next_url); 
                // }

                //print $request->url();

                return $next($request);
            });   
        }       
    }

    public function get_avatar()
    {
        //echo public_path('images/user/'.trim(session('user_id')).'.jpg');

        if(file_exists(public_path('img/user/'.trim(session('user_id')).'.jpg'))){    
            //echo 'exist';        
            $this->data['avatar'] = url('public/assets/media/users/'.trim(session('user_id')).'.jpg');
        } else {         
            //echo 'not exist';   
            $this->data['avatar']  = url('public/assets/media/users/default.jpg');
        }

        return $this->data['avatar'];
    }

    public function get_datatables($request, $connection = 'sqlsrv')
    {
        // $iDisplayStart = $this->input->post('start', true);			
        // $iDisplayLength = isset($_POST['length']) ? intval($_POST['length']) : 10;
        // $sSearch = $this->input->post('sSearch', true);
        // $sEcho = $this->input->post('draw', true);	
        
        $iDisplayStart = $request->input('start');			
        $iDisplayLength = $request->input('length',10);
        $sSearch = $request->input('sSearch');
        $sEcho = $request->input('draw');
        
        // Ordering
        $i = 0;
        // $iSortCol = $this->input->get_post('iSortCol_'.$i, true);
        // $sSortDir = $this->input->get_post('sSortDir_'.$i, true);
        
        $iSortCol = $request->input('iSortCol_'.$i);
        $sSortDir = $request->input('sSortDir_'.$i);
        
        //$data['SearchValue'] = trim($this->input->post('sSearch'));
        //$data = $this->input->post(NULL, TRUE); 	             
        
        $data['page'] = ($iDisplayStart + $iDisplayLength) / $iDisplayLength;			
        $data['row'] = $iDisplayLength;			
        
        //$orderByColumnIndex  = $_POST['order'][0]['column'];
        $orderByColumnIndex  = $request->input('order.0.column');
        // $data['sort_by'] = $_POST['columns'][$orderByColumnIndex]['name'];			
        // $data['sort_dir'] = $_POST['order'][0]['dir'];
        
        // Remark by febry, 6 Maret 2023
        //$data['sort_by'] = $request->input('columns')[$orderByColumnIndex]['name'];	

        $data['sort_by'] = $request->input('columns')[$orderByColumnIndex]['data'];	
        $data['sort_dir'] = $request->input('order.0.dir');
        
        // R = Return Records, C = Return Count Records
        $data['return_type'] = 'R'; 			

		// print_r($this->array_filter);
		// print_r($this->array_column);

        foreach ($this->array_filter as $value)
        {
            array_push($data, $value);  
        }        

        //$rResult = $this->datatables_model->get_list($data);		        

        $rResult = $this->exec_sp($this->sp_getinquiry,$data,'list');
        
        $data['return_type'] = 'C';        
        $query_total = $this->exec_sp($this->sp_getinquiry,$data,'list');
        
        foreach($query_total as $row_total)
        {
            $iFilteredTotal = $row_total->TotalRows;
        }		
        
        // Total data set length
        //$iTotal = $this->db->count_all($sTable);
        $iTotal = $iFilteredTotal;
        
        // Output
        $output = array(
            'sEcho' => intval($sEcho),
            'iTotalRecords' => $iTotal,
            'iTotalDisplayRecords' => $iFilteredTotal,
            'aaData' => array()
        );
    
        foreach($rResult as $aRow)
        {
            $row = array();
            
            foreach($this->array_column as $col)
            {					
                $row[$col] = $aRow->$col;
            }
    
            $output['aaData'][] = $row;
        }
    
        echo json_encode($output);

        //return json_encode($output);
    }

    public function get_detail_by_id($data,$connection = 'sqlsrv')
	{
        $param['IDX'] = $data;        
		return $this->exec_sp($this->sp_getdata,$param,'record');
	}

	public function get_list_by_id($data)
	{
		$param['IDX'] = $data;
		return $this->exec_sp($this->sp_getdetail_list,$param,'list');
    }
    
    public function store($state,$data,$custom_next_url = '', $send_email = array('send_email' => false))
	{
		if($state == 'create') { $query = $this->create($data); }
		
		if($state == 'update') { $query = $this->update($data); }
		
		if($state == 'delete') { $query = $this->delete($data);	}

		if($state == 'activate') { $query = $this->activate($data); }
        
        if($state == 'approve') { $query = $this->approve($data); }
        
        if($state == 'reverse_approve') { $query = $this->reverse_approve($data); }
        
        if($state == 'validate') { $query = $this->validate_transaction($data);	}
        
        if($state == 'void') { $query = $this->void_transaction($data); }

        if($state == 'renewal') { $query = $this->renewal($data); }

        if($state == 'termination') { $query = $this->termination($data); }

		// OUTPUT
		if($query){
				
            //$result = $query->row_array();
            $result = (array)$query;

            $flag = '';
            $id = '';
            foreach ($result as $row){
                $flag = $row->Result;
                $id = $row->ID;
            }

            //echo $flag;

            //print_r($result);


			if(strtolower($flag) == 'success')
			{	
                if($send_email['send_email'] == true)
                { 
                    Mail::send($send_email['view'],$send_email['parameter'], 
                        function ($message) use ($send_email)
                        {
                            $message->subject($send_email['subject']);
                            $message->from($send_email['from'], 'Admin');
                            $message->to($send_email['to']);
                            $message->bcc($send_email['bcc']);                           
                        }
                    );
                }

				$obj['flag'] = 'success';
				$obj['message'] = $this->sweet_alert_message($query);
				$obj['id'] = $id;
				$obj['next_action'] = $this->next_action;
				
                if($custom_next_url == ''){
                    $obj['url'] = $this->next_url.'/'.$id;
                }
                else 
                {
                    $obj['url'] = $this->next_url;
                }
			} 
			
            if(strtolower($flag) == 'error')
            {	
				$obj['flag'] = 'error';
				$obj['message'] = $this->sweet_alert_message($query);
				$obj['id'] = $id;
				$obj['url'] = $this->next_url;						
			}
			
		} else {
			
			$obj['flag'] = 'error';
			$obj['message'] = $this->sweet_alert_message($query);
			
		}
		
		echo json_encode($obj);
    }

    private function create($data)
	{
		return $this->exec_sp($this->sp_create,$data,'list');
	}

	private function update($data)
	{
		return $this->exec_sp($this->sp_update,$data,'list');
	}

    private function delete($data)
	{
		//$param['IDX'] = $data;
		return $this->exec_sp($this->sp_delete,$data,'list');
    }
    
    private function approve($data)
	{
		return $this->exec_sp($this->sp_approval,$data,'list');
	}

	private function reverse_approve($data)
	{
		return $this->exec_sp($this->sp_reverse_approval,$data,'list');
	}

	private function validate_transaction($data)
	{
		return $this->exec_sp($this->sp_validate,$data,'list');
	}

	private function void_transaction($data)
	{
		return $this->exec_sp($this->sp_void,$data,'list');
    }
    
    private function renewal($data)
	{
		return $this->exec_sp($this->sp_renewal,$data,'list');
    }
    
    private function termination($data)
	{
		return $this->exec_sp($this->sp_termination,$data,'list');
	}
    
    // =======================================================================================================
    // EXEC SQL SERVER STORED PROCEDURED AND PARAMETERS
    // =======================================================================================================
    public function exec_sp($sp_name,$sp_param,$return_type = 'list',$connection = 'sqlsrv')
	{
		$list_parameter = '';
		foreach ($sp_param as $value)
		{			
			if (is_numeric($value)){
				$list_parameter .= $value . ',';
			} else {
                if(substr($value,0,3) == 'XXX'){
                    $list_parameter .= "'" . substr($value,3,strlen($value)-3) . "',";
                } else {
                    $list_parameter .= "'" . $value . "',";
                }				
			}			
		}		

        //echo $list_parameter;

		$sql = "EXEC $sp_name " . substr($list_parameter,0,-1); 

        //echo $sql;
                
        $result =  DB::connection($connection)->select($sql);
        
        if($return_type == 'list'){
            return $result;	
        } else {
            if($result)
            {
                //$data = $result->row_array();
                $data = $result;			
            } else {		
                
                $pdo = DB::connection($connection)->getPdo();
                
                $stmt = $pdo->query($sql);

                //print_r($stmt->getColumnMeta);

                $colCount = $stmt->columnCount();
                for ($col = 0; $col < $colCount; ++$col) {
                    //echo $col;
                    //echo $stmt->getColumnMeta($col)['name'];
                    //print_r($stmt->getColumnMeta($col));

                    $data[$stmt->getColumnMeta($col)['name']] = '';
                }

                //$stmt->execute();

                //$result = DB::select($sql);                

                //$fields = DB::getSchemaBuilder()->getColumnListing($this->table_name);	
                
                //$fields = DB::getSchemaBuilder()->getColumnType($result, $colName);

                //$schema = DB::getDoctrineSchemaManager();

                //$fields = $sm->listTableColumns('M_COA');


                //foreach ($fields as $field)
                //{ 
                    // if(trim($field->Type) == 'money' || trim($field->Type) == 'decimal' 
                    //     || trim($field->Type) == 'real'){
                    //     $data[$field->Name] = 0;
                    // } else {
                    //     $data[$field->Name] = trim('');			   					   				   	
                    // }

                    //$data[$field] = trim('');
                //} 			
            }	            
            return $data;
        }		
    }
    
    // =======================================================================================================
    // EXEC SQL QUERY, NO PARAMETER.
    // =======================================================================================================
    public function exec_sql($sql,$return_type = 'list',$connection = 'sqlsrv')
	{	        
        $result =  DB::connection($connection)->select($sql);
        
        if($return_type == 'list'){
            return $result;	
        } else {
            if($result)
            {
                //$data = $result->row_array();
                $data = $result;			
            } else {		
                
                $pdo = DB::connection($connection)->getPdo();
                
                $stmt = $pdo->query($sql);

                //print_r($stmt->getColumnMeta);

                $colCount = $stmt->columnCount();
                for ($col = 0; $col < $colCount; ++$col) {
                    //echo $col;
                    //echo $stmt->getColumnMeta($col)['name'];
                    //print_r($stmt->getColumnMeta($col));

                    $data[$stmt->getColumnMeta($col)['name']] = '';
                }                		
            }	            
            return $data;
        }		
	}
    
    public function exec_insert($sql,$return_type = 'list',$connection = 'sqlsrv')
    {
        DB::connection($connection)->insert($sql);
    }

    public function exec_update($sql,$return_type = 'list',$connection = 'sqlsrv')
    {
        DB::connection($connection)->update($sql);
    }

    public function exec_delete($sql,$return_type = 'list',$connection = 'sqlsrv')
    {
        DB::connection($connection)->delete($sql);
    }

    public function exec_statement($sql,$return_type = 'list',$connection = 'sqlsrv')
    {
        DB::connection($connection)->statement($sql);
    }

    // =======================================================================================================
    // EXEC SQL SERVER STORED PROCEDURED AND PARAMETERS
    // =======================================================================================================
    public function getColumnName($sql,$return_type = 'list',$connection = 'sqlsrv')
	{
        //echo $sql;
                
        $result =  DB::connection($connection)->select($sql);
        
        if($return_type == 'list')
        {
            return $result;	
        } 
        else
        {
            if($result)
            {                
                $data = $result;			
            } 
            else 
            {	
                $pdo = DB::connection($connection)->getPdo();
                
                $stmt = $pdo->query($sql);                

                $colCount = $stmt->columnCount();
                for ($col = 0; $col < $colCount; ++$col)
                {
                    $data[$stmt->getColumnMeta($col)['name']] = '';
                }

                //$stmt->execute();

                //$result = DB::select($sql);                

                //$fields = DB::getSchemaBuilder()->getColumnListing($this->table_name);	
                
                //$fields = DB::getSchemaBuilder()->getColumnType($result, $colName);

                //$schema = DB::getDoctrineSchemaManager();

                //$fields = $sm->listTableColumns('M_COA');


                //foreach ($fields as $field)
                //{ 
                    // if(trim($field->Type) == 'money' || trim($field->Type) == 'decimal' 
                    //     || trim($field->Type) == 'real'){
                    //     $data[$field->Name] = 0;
                    // } else {
                    //     $data[$field->Name] = trim('');			   					   				   	
                    // }

                    //$data[$field] = trim('');
                //} 			
            }	            
            return $data;
        }		
    }

    // =======================================================================================================
    // CHECK PERMISSION 
    // =======================================================================================================
    public function check_permission($user_id, $menu_id)
    {
        $sql = "SELECT U.LoginID, MF.FormID
				FROM SM_M_GroupForm MUGF
                LEFT JOIN SM_M_Group MUG ON MUGF.IDX_M_Group = MUG.IDX_M_Group
                LEFT JOIN SM_M_UserGroup MU ON MUGF.IDX_M_Group = MU.IDX_M_Group 
                LEFT JOIN SM_M_User U ON U.IDX_M_User = MU.IDX_M_User 
                INNER JOIN SM_M_Form MF ON MUGF.IDX_M_Form = MF.IDX_M_Form
				WHERE U.LoginID = '$user_id' AND RTRIM(ISNULL(MF.FormID,'')) = '$menu_id'"; 

        $result =  DB::connection('sqlsrv')->select($sql);

        if($result)
        {            
            return TRUE;
        } 
        else 
        {            
            return FALSE;
        }
    }
   
    public function show_no_access($data)
    {
        $this->data['view'] = 'layouts/no_access_form'; 
        $this->data['fields'] = $data;

        return view($this->data['view'], $this->data);
    }

    public function show_no_access_modal($data)
    {
        $this->data['view'] = 'layouts/no_access_modal_form'; 
        $this->data['fields'] = $data;

        return view($this->data['view'], $this->data);
    }

    // =======================================================================================================
    // VALIDATION FROM DATABASE
    // =======================================================================================================
    public function sweet_alert_message($query)
    {			
        $detail_message = '';
        
        if($query)
        {
            foreach ($query as $row):
                $detail_message .= '<span style="display:block;">'.$row->LogDesc.'</span>';
            endforeach;		
        }
        
        return $detail_message . "</div>";
    }

    // =======================================================================================================
    // VALIDATION FROM SUBMIT FORM
    // =======================================================================================================
    public function validation_fails($errors,$id)
    {
        $obj = array();
				
        $obj['flag'] = 'error';
        $obj['id'] = $id;

        $array_messages = '';

        foreach ($errors->all() as $message) {
            $array_messages .= '<span style="display:block;" class="text-danger">'.$message.'</span>';
        }            

        $obj['message'] = $array_messages;           
        
        echo json_encode($obj);	
    }
    // ========================================================================================================

    // =======================================================================================================
    // OTHERS FUNCTION
    // =======================================================================================================
    public function penyebut($nilai)
    {
		$nilai = abs($nilai);
		$huruf = array("", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "delapan", "sembilan", "sepuluh", "sebelas");
		$temp = "";
		if ($nilai < 12) {
			$temp = " ". $huruf[$nilai];
		} else if ($nilai <20) {
			$temp = $this->penyebut($nilai - 10). " belas";
		} else if ($nilai < 100) {
			$temp = $this->penyebut($nilai/10)." puluh". $this->penyebut($nilai % 10);
		} else if ($nilai < 200) {
			$temp = " seratus" . $this->penyebut($nilai - 100);
		} else if ($nilai < 1000) {
			$temp = $this->penyebut($nilai/100) . " ratus" . $this->penyebut($nilai % 100);
		} else if ($nilai < 2000) {
			$temp = " seribu" . $this->penyebut($nilai - 1000);
		} else if ($nilai < 1000000) {
			$temp = $this->penyebut($nilai/1000) . " ribu" . $this->penyebut($nilai % 1000);
		} else if ($nilai < 1000000000) {
			$temp = $this->penyebut($nilai/1000000) . " juta" . $this->penyebut($nilai % 1000000);
		} else if ($nilai < 1000000000000) {
			$temp = $this->penyebut($nilai/1000000000) . " milyar" . $this->penyebut(fmod($nilai,1000000000));
		} else if ($nilai < 1000000000000000) {
			$temp = $this->penyebut($nilai/1000000000000) . " trilyun" . $this->penyebut(fmod($nilai,1000000000000));
		}     
		return $temp;
	}
 
    public function terbilang($nilai)
    {
		if($nilai<0) {
			$hasil = "minus ". trim($this->penyebut($nilai));
		} else {
			$hasil = trim($this->penyebut($nilai));
		}     		
		return $hasil;
    }
    
    public function indonesian_date($tanggal)
    {
        $bulan = array (
            1 =>   'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
            'Juni',
            'Juli',
            'Agustus',
            'September',
            'Oktober',
            'November',
            'Desember'
        );
        $pecahkan = explode('-', $tanggal);
        
        // variabel pecahkan 0 = tanggal
        // variabel pecahkan 1 = bulan
        // variabel pecahkan 2 = tahun
    
        return $pecahkan[2] . ' ' . $bulan[ (int)$pecahkan[1] ] . ' ' . $pecahkan[0];
    }

    public function indonesian_month($tanggal)
    {
        $bulan = array (
            1 =>   'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
            'Juni',
            'Juli',
            'Agustus',
            'September',
            'Oktober',
            'November',
            'Desember'
        );
        $pecahkan = explode('-', $tanggal);
        
        // variabel pecahkan 0 = tanggal
        // variabel pecahkan 1 = bulan
        // variabel pecahkan 2 = tahun
    
        return $bulan[ (int)$pecahkan[1] ];
    }

    /**
     * Copy of Excel's PMT function.
     * Credit: http://thoughts-of-laszlo.blogspot.nl/2012/08/complete-formula-behind-excels-pmt.html
     *
     * @param double $interest        The interest rate for the loan.
     * @param int    $num_of_payments The total number of payments for the loan in months.
     * @param double $PV              The present value, or the total amount that a series of future payments is worth now;
     *                                Also known as the principal.
     * @param double $FV              The future value, or a cash balance you want to attain after the last payment is made.
     *                                If fv is omitted, it is assumed to be 0 (zero), that is, the future value of a loan is 0.
     * @param int    $Type            Optional, defaults to 0. The number 0 (zero) or 1 and indicates when payments are due.
     *                                0 = At the end of period
     *                                1 = At the beginning of the period
     *
     * @return float
     */
    public function PMT($interest, $num_of_payments, $PV, $FV = 0.00, $Type = 0)
    {
        $xp = pow((1+$interest),$num_of_payments);

        return
            ($PV * $interest * $xp / ($xp - 1) + $interest / ($xp - 1) * $FV) *
            ($Type == 0 ? 1 : 1 / ($interest + 1));
    }

    public function get_flat_installment($flat_rate, $principal, $tenor)
    {
        // $tenor_month = $tenor / 12;
        // $tenor_year = $tenor / 12;

        $total_receivable = $principal + ($principal * ($flat_rate / 12 / 100) * $tenor);
        $installment = $total_receivable /  $tenor;
        return $installment;
    }

    public function calculate_rate()
    {
        $advarr = $this->input->post('advarr');
        $principal = (double)str_replace(',','',$this->input->post('principal'));
        $installment = (double)str_replace(',','',$this->input->post('installment'));
        $tenor = (double)str_replace(',','',$this->input->post('tenor'));		
        
        $total_bunga = (($installment * $tenor) - $principal);
        $ar_amount = $installment * $tenor;
        
        if($advarr == 'A'){
            $type = 1;
        } else {
            $type = 0;
        }		
        
        $eff_rate = $this->rate($tenor,$installment,-1*$principal,0,$type);
        
        $data['flat_rate'] = number_format($total_bunga / $principal * 100 / ($tenor / 12),5,'.',',');
        $data['eff_rate'] = number_format($eff_rate,10,'.',',');	
        
        $data['interest_amount'] = number_format($total_bunga,2,'.',',');	
        $data['ar_amount'] = number_format($ar_amount,2,',','.');		
        
        $this->load->view('application/rate_ajax',$data);		
    }
		
    //rate(tenor, angsuran, pokok hutang, future value, type(advance = 1, arrear = 0)
    public function rate($nper, $pmt, $pv, $fv = 0.0, $type = 0, $guess = 0.1) 
    {
        $rate = $guess;
        if (abs($rate) < 0.0000001) {
            $y = $pv * (1 + $nper * $rate) + $pmt * (1 + $rate * $type) * $nper + $fv;
        } else {
            $f = exp($nper * log(1 + $rate));
            $y = $pv * $f + $pmt * (1 / $rate + $type) * ($f - 1) + $fv;
        }
        $y0 = $pv + $pmt * $nper + $fv;
        $y1 = $pv * $f + $pmt * (1 / $rate + $type) * ($f - 1) + $fv;

        // find root by secant method
        $i  = $x0 = 0.0;
        $x1 = $rate;
        while ((abs($y0 - $y1) > 0.0000001) && ($i < 20)) {
            $rate = ($y1 * $x0 - $y0 * $x1) / ($y1 - $y0);
            $x0 = $x1;
            $x1 = $rate;

            if (abs($rate) < 0.0000001) {
                $y = $pv * (1 + $nper * $rate) + $pmt * (1 + $rate * $type) * $nper + $fv;
            } else {
                $f = exp($nper * log(1 + $rate));
                $y = $pv * $f + $pmt * (1 / $rate + $type) * ($f - 1) + $fv;
            }

            $y0 = $y1;
            $y1 = $y;
            ++$i;
        }
        return $rate * 100 * 12;
    }   
        
}

