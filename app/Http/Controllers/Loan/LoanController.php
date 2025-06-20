<?php

namespace App\Http\Controllers\Loan;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownLoanController;

use Maatwebsite\Excel\Facades\Excel;


class LoanController extends MyController
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'Loan';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = 'Pinjaman';
        
        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_loan';     
        $this->data['sidebar'] = 'navigation.sidebar_loan'; 

        // BREADCRUMB
        $this->data['breads'] = array('Loan','Transaction','Pinjaman'); 

        // URL
        $this->data['url_create'] = url('cf-loan-create');
        $this->data['url_search'] = url('cf-loan-list');           
        $this->data['url_update'] = url('cf-loan-update/');
        $this->data['url_payment'] = url('cf-loan-payment/'); 
        $this->data['url_cancel'] = url('cf-loan'); 

        
        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request, $status = '')
    {       
        $this->data['form_id'] = 'CF-LO-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;
        
        $this->data['form_sub_title'] = 'Daftar Pinjaman';
        $this->data['form_remark'] = 'Daftar pinjaman berdasarkan hak akses cabang dari setiap user ID';    
        
        if($status !== '')
        {
            $this->data['url_search'] = url('cf-loan-list/' .$status);
        }        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_T_Contract','Kode Cabang','Nama Cabang','No Pinjaman','Tgl Pinjaman','Tgl Cair','Kode Anggota', 
                'Nama Anggota','Nama Marketing','Jumlah Pencairan', 'Sisa Piutang', 'Tenor','Angsuran','cont_status','Status Pinjaman','Aging','Pencairan','Action');         

            $this->data['table_footer'] = array('', '','','branch_desc','cont_contract_no','','','', 
                'cust_name','mkt_name','', '', '','','','','','','Action');

            $this->data['array_filter'] = array('branch_desc','cont_contract_no','cust_name','mkt_name');

            // VIEW
            $this->data['view'] = 'loan/loan_list';  
            return view($this->data['view'], $this->data);
            
        } 
        else
        {
            return $this->show_no_access($this->data);
        }  
    }

    public function inquiry_data(Request $request, $status = '')
    { 
        // FILTER FOR STORED PROCEDURE
        $array_filter['branch_desc'] = $request->input('branch_desc');
        $array_filter['cont_contract_no'] = $request->input('cont_contract_no');  
        $array_filter['cust_name'] = $request->input('cust_name');         
        $array_filter['mkt_name'] = $request->input('mkt_name');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id'];
        $array_filter['Status'] = $status;
        $array_filter['Aging'] = 0;         

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CF_Loan_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_Contract','cont_branch_id','branch_desc','cont_contract_no','cont_sales_date','cont_commence_date','cust_id', 
            'cust_name','mkt_name','cont_commence_amount', 'os_receivable', 'cont_tenor','cont_installment','cont_status','StatusDesc','Aging','DisbursmentStatus');

        return $this->get_datatables($request); 
    }

    public function inquiry_data_by_branch($branch_id='999', Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['cust_branch_id'] = $branch_id;
        $array_filter['cont_contract_no'] = $request->input('cont_contract_no');  
        $array_filter['cust_name'] = $request->input('cust_name');         
        $array_filter['mkt_name'] = $request->input('mkt_name');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id'];
        $array_filter['Status'] = $status;
        $array_filter['Aging'] = 0;   
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CF_Loan_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_Contract','cont_branch_id','branch_desc','cont_contract_no','cont_sales_date','cont_commence_date','cust_id', 
            'cust_name','mkt_name','cont_commence_amount', 'os_receivable', 'cont_tenor','cont_installment','cont_status','StatusDesc','Aging');

        return $this->get_datatables($request);  
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'CF-LO-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Pinjaman';
        $this->data['form_sub_title'] = 'Input Pinjaman';
        $this->data['form_desc'] = 'Input Pinjaman';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_Contract = 0;        
            $this->data['fields']->RecordStatus = 'A';            
            $this->data['fields']->CustomerName = '';
            $this->data['fields']->cust_name_label = '';            
            $this->data['fields']->cont_status = 'P';

            $this->data['fields']->cont_flag_ktp = 0; 
            $this->data['fields']->cont_flag_ktp_penjamin = 0; 
            $this->data['fields']->cont_flag_kk = 0;
            $this->data['fields']->cont_flag_domisili = 0;
            $this->data['fields']->cont_flag_pbb = 0;
            $this->data['fields']->cont_flag_faktur_mobil = 0;
            $this->data['fields']->cont_flag_faktur_motor = 0;
            $this->data['fields']->cont_flag_stnk = 0;
            $this->data['fields']->cont_flag_stnk_expired = 0;
            $this->data['fields']->cont_flag_other_amount = 0;
            $this->data['fields']->cont_total_deposit = 0;
            $this->data['fields']->cont_customer_deposit = 0;            

            return $this->show_form(0, 'create');
        } else {

            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'CF-LO-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Pinjaman';
        $this->data['form_sub_title'] = 'Update Pinjaman';
        $this->data['form_desc'] = 'Update Pinjaman';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];
            
            // DEFAULT VALUE & FORMAT
            $this->data['fields']->cont_collateral_amount = number_format($this->data['fields']->cont_collateral_amount,0,'.',',');
            $this->data['fields']->cont_admin_fee = number_format($this->data['fields']->cont_admin_fee,0,'.',',');
            $this->data['fields']->cont_commence_amount = number_format($this->data['fields']->cont_commence_amount,0,'.',',');
            $this->data['fields']->cont_installment = number_format($this->data['fields']->cont_installment,0,'.',',');            
            $this->data['fields']->TotalReceivable = number_format($this->data['fields']->TotalReceivable,0,'.',',');
            $this->data['fields']->TotalInterest = number_format($this->data['fields']->TotalInterest,0,'.',',');

            // DEFAULT VALUE & FORMAT FOR DEPOSIT
            $this->data['fields']->cont_flag_ktp = number_format($this->data['fields']->cont_flag_ktp,0,'.',',');
            $this->data['fields']->cust_name_label = $this->data['fields']->cont_cust_id . ' - ' . $this->data['fields']->cust_name; 

            return $this->show_form($id, 'update');
        } 
        else 
        {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownLoanController;        
        $this->data['dd_loan_type'] = (array) $dd->loan_type('');
        $this->data['dd_payment_type'] = (array) $dd->payment_type_cf('');
        $this->data['dd_brand'] = (array) $dd->brand_cf();
        $this->data['dd_brand_item'] = (array) $dd->brand_item_cf($this->data['fields']->cont_brand_id);        
        $this->data['dd_faktur_flag'] = array('' => '--PILIH--','Y' => 'ADA','N' => 'TIDAK ADA');        
        $this->data['dd_tenor'] = (array) $dd->tenor_month_cf();
        $this->data['dd_stnk_expired'] = (array) $dd->stnk_expired();
        $this->data['dd_upload_category'] = (array) $dd->upload_category();

        // URL
        $this->data['url_save_header'] = url('/cf-loan/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';
        
        // RECORDS
        if($state !== 'create')
        {      
            $this->data['dd_branch'] = (array) $dd->branch_code_specific($this->data['fields']->cont_branch_id);
            $this->data['dd_marketing'] = (array) $dd->marketing_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_mediator'] = (array) $dd->mediator_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_collector'] = (array) $dd->collector_cf($this->data['fields']->cont_branch_id);

            // RECORDS
            $param['BranchID'] = $this->data['fields']->cont_branch_id;
            $param['ContractNo'] = $this->data['fields']->cont_contract_no;   
            $this->data['records_installment'] = $this->exec_sp('USP_CF_Loan_Schedule_List',$param,'list','sqlsrv');                     
            $this->data['records_payment'] = $this->exec_sp('USP_CF_Loan_Payment_List',$param,'list','sqlsrv');

            $param_journal['IDX_T_Contract'] = $this->data['fields']->IDX_T_Contract;
            $param_journal['ContractNo'] = $this->data['fields']->cont_contract_no;  
            $this->data['records_journal'] = $this->exec_sp('USP_CF_Loan_Journal_List',$param_journal,'list','sqlsrv');

            $param_upload['IDX_T_Contract'] = $this->data['fields']->IDX_T_Contract;            
            $this->data['records_upload'] = $this->exec_sp('USP_CF_Loan_Upload_List',$param_upload,'list','sqlsrv');
        }
        else 
        {
            $this->data['dd_branch'] = (array) $dd->branch_code($this->data['user_id']);
            $this->data['dd_marketing'] = (array) $dd->marketing_cf('');
            $this->data['dd_mediator'] = (array) $dd->mediator_cf('');
            $this->data['dd_collector'] = (array) $dd->collector_cf('');
            $this->data['dd_brand_item'] = (array) $dd->brand_item_cf('XXX'); 
        }

        // VIEW        
        $this->data['form_remark'] = 'Detail informasi pinjaman, pembayaran angsuran, jaminan dan journal accounting';        
        
        $this->data['view'] = 'loan/loan_readonly_form';

        if($this->data['fields']->cont_status == 'P')
        {
            $this->data['view'] = 'loan/loan_form';
        }

        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CF_Loan_Save]';
        $this->sp_update = '[dbo].[USP_CF_Loan_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/cf-loan-update');

        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required',
            'cont_branch_id' => 'required',
            'IDX_M_Customer' => 'required',
            'cont_mkt_id' => 'required',
            'cont_type' => 'required',
            'cont_collateral_amount' => 'required',
            'cont_tenor' => 'required',
            'IDX_M_Customer' => 'required',
            'IDX_M_Customer' => 'required',
            'IDX_M_Customer' => 'required',
            'IDX_M_Customer' => 'required',
        ],[
            'IDX_T_Contract.required' => 'Invalid index',
            'cont_branch_id.required' => 'Cabang belum diisi',
            'IDX_M_Customer.required' => 'Anggota belum diisi',
            'cont_mkt_id.required' => 'Marketing belum diisi',
            'cont_type.required' => 'Jenis pinjaman belum diisi',
            'cont_collateral_amount.required' => 'Nilai jaminan belum diisi',
            'cont_tenor.required' => 'Tenor belum diisi',
            'cust_telp.required' => 'No telp belum diisi',
            'cust_hp.required' => 'No HP belum diisi',
            'cust_address_domisili.required' => 'Alamat domisili belum diisi',
            'cust_rt_domisili.required' => 'RT domisili belum diisi',
            'cust_rw_domisili.required' => 'RW domisili belum diisi',
            'cust_kelurahan_domisili.required' => 'Kelurahan domisili belum diisi',
            'cust_kecamatan_domisili.required' => 'Kecamatan domisili belum diisi',
            'cust_kota_domisili.required' => 'Kota domisili belum diisi',
            'cust_kodepos_domisili.required' => 'Kodepos domisili belum diisi',
            'cust_occupation.required' => 'Pekerjaan belum diisi',
            'cust_occupation_address.required' => 'Alamat tempat kerja belum diisi',
            'cust_ibukandung.required' => 'Nama ibu kandung belum diisi',
            'cust_status_rumah.required' => 'Status rumah belum diisi',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];              

            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];   
            $param['IDX_M_DocumentType'] = isset($_POST['IDX_M_DocumentType']) ? $_POST['IDX_M_DocumentType'] : '0'; 
            $param['IDX_M_CollectorExternal'] = isset($_POST['IDX_M_CollectorExternal']) ? $_POST['IDX_M_CollectorExternal'] : '0';
            $param['cont_branch_id'] = $data['cont_branch_id'];
            $param['cont_contract_no'] = $data['cont_contract_no'];
            $param['cont_cust_id'] = $data['cont_cust_id'];
            $param['cont_mkt_id'] = $data['cont_mkt_id'];
            $param['cont_med_id'] = $data['cont_med_id'];
            $param['cont_type'] = $data['cont_type'];
            $param['cont_collateral_desc'] = $data['cont_collateral_desc'];
           
            $param['cont_collateral_amount'] = (double)str_replace(',','',$data['cont_collateral_amount']);
            $param['cont_admin_fee'] = (double)str_replace(',','',$data['cont_admin_fee']);
            $param['cont_customer_deposit'] = 0; //(double)str_replace(',','',$data['cont_customer_deposit']);
            $param['cont_commence_amount'] = (double)str_replace(',','',$data['cont_commence_amount']);
            $param['cont_tenor'] = (double)str_replace(',','',$data['cont_tenor']);

            $param['cont_tenor_type'] = 'M'; //$data['cont_tenor_type'];
            $param['cont_flat_rate'] = (double)str_replace(',','',$data['cont_flat_rate']);
            $param['cont_eff_rate'] = (double)str_replace(',','',$data['cont_flat_rate'] * 2); //(double)str_replace(',','',$data['cont_eff_rate']);

            $param['cont_process_date'] = date('Y-m-d');; //$data['cont_process_date'];
            $param['cont_sales_date'] = $data['cont_sales_date'];
            $param['cont_commence_date'] = $data['cont_commence_date'];
            $param['cont_status'] = $data['cont_status'];

            $param['cont_installment'] = (double)str_replace(',','',$data['cont_installment_update']);

            $param['cont_bpkb_no'] = $data['cont_bpkb_no'];
            $param['cont_bpkb_name'] = $data['cont_bpkb_name'];
            $param['cont_bpkb_address'] = $data['cont_bpkb_address'];

            $param['cont_brand_id'] = $data['cont_brand_id'];
            $param['cont_brand_item'] = $data['cont_brand_item'];
            $param['cont_vehicle_year'] = $data['cont_vehicle_year'];
            $param['cont_chasis_no'] = $data['cont_chasis_no'];
            $param['cont_engine_no'] = $data['cont_engine_no'];
            $param['cont_vehicle_color'] = $data['cont_vehicle_color'];
            $param['cont_no_polisi'] = $data['cont_no_polisi'];
            $param['cont_collateral_no'] = isset($_POST['cont_collateral_no']) ? $_POST['cont_collateral_no'] : '0';
            $param['cont_collector_id'] = isset($_POST['cont_collector_id']) ? $_POST['cont_collector_id'] : '0';
            $param['cont_pmt_type'] = $data['cont_pmt_type'];
            $param['cont_faktur_flag'] = $data['cont_faktur_flag'];
            $param['cont_faktur_no'] = $data['cont_faktur_no'];

            $param['cont_address'] = $data['cont_address'];
            $param['cont_rt'] = $data['cont_rt'];
            $param['cont_rw'] = $data['cont_rw'];
            $param['cont_kelurahan'] = $data['cont_kelurahan'];
            $param['cont_kecamatan'] = $data['cont_kecamatan'];
            $param['cont_kodepos'] = $data['cont_kodepos'];
            $param['cont_kota'] = $data['cont_kota'];
            $param['cont_telp'] = $data['cont_telp'];
            $param['cont_hp'] = $data['cont_hp'];

            $param['cont_flag_ktp'] = (double)str_replace(',','',$data['cont_flag_ktp_amount']);
            $param['cont_flag_ktp_penjamin'] = (double)str_replace(',','',$data['cont_flag_ktp_penjamin_amount']);
            $param['cont_flag_kk'] = (double)str_replace(',','',$data['cont_flag_kk_amount']);
            $param['cont_flag_domisili'] = (double)str_replace(',','',$data['cont_flag_domisili_amount']);
            $param['cont_flag_pbb'] = (double)str_replace(',','',$data['cont_flag_pbb_amount']);
            $param['cont_flag_faktur_mobil'] = (double)str_replace(',','',$data['cont_flag_faktur_mobil_amount']);
            $param['cont_flag_faktur_motor'] = (double)str_replace(',','',$data['cont_flag_faktur_motor_amount']);
            $param['cont_flag_stnk'] = (double)str_replace(',','',$data['cont_flag_stnk_amount']);
            $param['cont_flag_stnk_expired'] = (double)str_replace(',','',$data['cont_flag_stnk_expired']);
            $param['cont_flag_other_notes'] = $data['cont_flag_other_notes'];
            $param['cont_flag_other_amount'] = (double)str_replace(',','',$data['cont_flag_other_amount']);
            $param['cont_total_deposit'] = (double)str_replace(',','',$data['cont_total_deposit']);
            $param['cont_expense_mediator'] = (double)str_replace(',','',$data['cont_expense_mediator']);

            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // UPLOAD FILE
    // =========================================================================================    
    public function upload(Request $request)
    {
        // $this->validate($request, [
        //     'UploadFile' => 'required',            	
        // ]);

        $validator = Validator::make($request->all(), [
            'UploadFile' => 'required',
        ],[
            'IDX_T_Contract.required' => 'Invalid index',
        ]);
        
        if($validator->fails())
        {
            echo 'error';
            return $this->validation_fails($validator->errors(),$request->input('UploadFile'));            	

        } else {

            $data = $request->all();

            //$path = 'upload-doc/upload-agent';
            $path = storage_path("app/public/upload-pinjaman" . "/" . $request->cont_contract_no);

            //echo $path;

            if(!File::isDirectory($path)){
                File::makeDirectory($path, 0777, true, true);
            }

            //echo $path;

            if (!empty($_FILES['UploadFile']['name']))
			{
                $UploadFile = $request->file('UploadFile');

                // Get filename with the extension
                $filenameWithExt = $UploadFile->getClientOriginalName();

                //Get just filename
                $filename = pathinfo($filenameWithExt, PATHINFO_FILENAME);

                $extension = $UploadFile->getClientOriginalExtension();

                // Filename to store
                $fileNameToStore = $filename.'.'.$extension;

                // UPLOAD TO PATH
                $UploadFile->move($path, $fileNameToStore);

                $param_upload['IDX_T_Contract'] = $request->IDX_T_Contract;
                $param_upload['UploadCategory'] = $request->UploadCategory;
                $param_upload['FilePath'] = $path;
                $param_upload['FileName'] = $fileNameToStore;
                $param_upload['FileDescription'] = 'Test Upload';
                $param_upload['UserID'] = 'XXX'.$this->data['user_id'];
                $this->data['records_upload'] = $this->exec_sp('USP_CF_Loan_Upload_Save',$param_upload,'list','sqlsrv');

                // $sql = "INSERT INTO [dbo].[tr_contract_upload]
                //         ([IDX_T_Contract]
                //         ,[UploadCategory]
                //         ,[FilePath]
                //         ,[FileName]
                //         ,[FileDescription]
                //         ,[DCreate]
                //         ,[UCreate]           
                //         ,[RecordStatus])
                //     VALUES()";

                // $this->exec_insert($sql);
            }          
            
            

            $this->data['dir_network'] = $path;

            //$this->sp_getdata = 'dbo.[USP_SL_Agent_Info]';
            //$this->data['fields'] = $this->get_detail_by_id($data['IDX_M_Agent'])[0];            

            return view('loan.loan_upload_list', $this->data);
        }

    }

    public function download(Request $request)
    {
        $data = $request->all();

        $filepath = $request->query('filepath');

        //echo 'file path '.$filepath;

        //$dir_network = storage_path('app/public/upload-pinjaman' . '/' . $request->cont_contract_no .'\'');

        //echo '<br/>';
        //echo 'dir network '.$dir_network;
        
        //foreach (glob($dir_network.$filepath."*") as $filename) {
        foreach (glob($filepath."*") as $filename) {

            //echo "foreach";
            
            $mimeType = $this->getMimeType($filename);            

            $headers = array(
                //'Content-Disposition' => 'attachment',
                //'Content-Type' => File::mimeType($filename),
                'Content-Type' => $mimeType,
            );

            return response()->download($filename, null, $headers); 
        }
    }

    public function delete_file(Request $request)
    {
        $filepath = $request->query('filepath');

        if (Storage::exists($filePath)) {
            Storage::delete($filePath);
            echo "File deleted successfully.";
        } else {
            echo "File does not exist.";
        }
    }

    protected function getMimeType($extension)
    {
        $mimeTypes = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'pdf' => 'application/pdf',
            'PDF' => 'application/pdf',
            // Add other MIME types as needed
        ];

        return $mimeTypes[$extension] ?? 'application/octet-stream'; // Default MIME type
    }

    // =========================================================================================
    // APPROVE
    // =========================================================================================
    public function approve(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Approval Loan';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Loan';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->cont_sales_date));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-approve');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_approval_form';
            $this->data['submit_title'] = 'Approve';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_approve(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['UserID'] = 'XXX'.$data['ApprovalBy']; 

            return $this->store($state,$param);
        }   
    }    

    // =========================================================================================
    // JOURNAL APPROVE
    // =========================================================================================
    public function journal_approve(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Journal Approval';
        $this->data['form_sub_title'] = 'Create Journal';        
        $this->data['form_desc'] = 'Create approval journal';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->cont_commence_date));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-journal-approve');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_journal_approval_form';
            $this->data['submit_title'] = 'Create Journal';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_journal_approve(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required',
            'cont_sales_date' => 'required',
            'cont_commence_date' => 'required',
            'cont_contract_no' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Approve_Journal_Manual]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['cont_contract_no'] = $data['cont_contract_no'];
            $param['cont_sales_date'] = date('Y-m-d',strtotime($data['cont_sales_date']));            
            $param['UserID'] = 'XXX'.$this->data['user_id'];

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // LOAN DISBURSMENT / PENCAIRAN DANA
    // =========================================================================================
    public function disbursment(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Pencairan Pinjaman';
        $this->data['form_sub_title'] = 'Pencairan Dana';        
        $this->data['form_desc'] = 'Pencairan Pinjaman';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];    
            
            // DROPDOWN
            $dd = new DropdownController;                       
            $this->data['dd_financial_account'] = (array) $dd->financial_account(''); 

            // DEFAULT VALUE                                  
            $this->data['fields']->IDX_T_LoanDisbursment = '0';
            $this->data['fields']->IDX_M_FinancialAccount = $this->data['fields']->DefaultFinancialAccount; 
            $this->data['fields']->DisbursmentNotes = '';
            $this->data['fields']->DisbursmentStatus = 'D';
            $this->data['fields']->DisbursmentAmount = number_format($this->data['fields']->cont_commence_amount,2,'.',',');           
            $this->data['fields']->DisbursmentDate = date('Y-m-d');
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-disbursment');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_disbursment_form';
            $this->data['submit_title'] = 'Pencairan Dana';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_disbursment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required',
            'IDX_M_FinancialAccount' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Disbursment]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_LoanDisbursment'] = $data['IDX_T_LoanDisbursment'];
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];            
            $param['DisbursmentDate'] = date('Y-m-d',strtotime($data['DisbursmentDate']));
            $param['DisbursmentAmount'] = (double)str_replace(',','',$data['DisbursmentAmount']);
            $param['cont_expense_mediator'] = (double)str_replace(',','',$data['cont_expense_mediator']);
            $param['DisbursmentNotes'] = $data['DisbursmentNotes'];
            $param['DisbursmentStatus'] = isset($data['DisbursmentStatus']) ? $data['DisbursmentStatus'] : 'D';
            $param['UserID'] = 'XXX'.$this->data['user_id'];

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // JOURNAL APPROVE
    // =========================================================================================
    public function journal_disbursment(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Journal Pencairan';
        $this->data['form_sub_title'] = 'Create Journal Pencairan';        
        $this->data['form_desc'] = 'Buat Pencairan journal';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];         

            // DROPDOWN
            $dd = new DropdownController;                       
            $this->data['dd_financial_account'] = (array) $dd->financial_account(''); 

            // DEFAULT VALUE                                  
            $this->data['fields']->IDX_T_LoanDisbursment = '0'; 
            $this->data['fields']->DisbursmentAmount = number_format($this->data['fields']->DisbursmentAmount,2,'.',','); 
            $this->data['fields']->DisbursmentNotes = '';               
            // $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->cont_commence_date));
            // $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-journal-disbursment');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_journal_disbursment_form';
            $this->data['submit_title'] = 'Create Journal';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_journal_disbursment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required',
            'IDX_M_FinancialAccount' => 'required',
            'cont_contract_no' => 'required', 
            'DisbursmentDate' => 'required',                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Disbursment_Journal_Manual]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            //$param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];
            $param['ContractNo'] = $data['cont_contract_no'];
            $param['DisbursmentDate'] = date('Y-m-d',strtotime($data['DisbursmentDate']));            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // REVERSE
    // =========================================================================================
    public function reverse(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Reverse Loan';
        $this->data['form_sub_title'] = 'Reverse';        
        $this->data['form_desc'] = 'Reverse Loan';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->cont_sales_date));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-reverse');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_reverse_form';
            $this->data['submit_title'] = 'Reverse';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_reverse(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Reverse]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // SHOW INFORMATION
    // =========================================================================================
    public function show_info(Request $request)
    {
        
    }

    // =========================================================================================
    // VOID/CANCEL
    // =========================================================================================
    public function cancel_payment(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Void Loan';
        $this->data['form_sub_title'] = 'Void';        
        $this->data['form_desc'] = 'Void Loan';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->VoidReason = '';           
            $this->data['fields']->VoidDate = date('Y-m-d',strtotime($this->data['fields']->ApprovalDate));
            $this->data['fields']->VoidBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-cancel');            

            // VIEW                          
            $this->data['view'] = 'loan/loan_cancel_form';
            $this->data['submit_title'] = 'Void';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_cancel(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Void]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['VoidDate'] = $data['VoidDate'];
            $param['VoidReason'] = $data['VoidReason'];
            $param['UserID'] = 'XXX'.$data['VoidBy']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // INPUT OTHER EXPENSE
    // =========================================================================================
    public function other_expense(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Additional Cost';
        $this->data['form_sub_title'] = 'Additional Cost';        
        $this->data['form_desc'] = 'Additional Cost';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];         

            // DEFAULT VALUE   
            $this->data['fields']->cont_expense_mediator = '0.00';
            
            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-other-expense');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_other_expense_form';
            $this->data['submit_title'] = 'Add Other Expense';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_other_expense(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_OtherExpense]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['cont_expense_mediator'] = (double)str_replace(',','',$data['cont_expense_mediator']);
            $param['UserID'] = 'XXX'.$this->data['user_id'];

            return $this->store($state,$param);
        }   
    }
  
    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Loan';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Loan';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];        
                  
            // RECORDS
            $param['IDX_T_Contract'] = $request->IDX_T_Contract;   
            $this->data['records_detail'] = $this->exec_sp('USP_CF_LoanDetail_List',$param,'list','sqlsrv');       

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'loan/financialreceive_duplicate_form';
            $this->data['submit_title'] = 'Duplicate';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_duplicate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_Contract' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    public function calculate_installment(Request $request)
    {
        $flatrate = (double) $request->flatrate;
        $principal = (double) str_replace(',','',$request->principal);			
        $tenor = (double) str_replace(',','',$request->tenor);	
        $tenor_type = trim($request->tenor_type);
        $commence_date = trim($request->commence_date);	
        $tenor_type = 'M';	
        
        //Tenor Harian
        if($tenor_type == 'D'){
            $daily_rate = $flatrate / 30;
            $total_bunga = round($principal * $daily_rate * $tenor / 100,0);				
        }
        
        //Tenor Bulanan
        if($tenor_type == 'M'){
            $total_bunga = round($principal * $flatrate * $tenor / 100,0);				
        }						
        
        $total_ar = $principal + $total_bunga;			
        $cont_installment = round($total_ar / $tenor,0);	
        
        $data['total_ar'] = $cont_installment * $tenor;
        $data['principal'] = $principal;
        $data['total_bunga'] = ($cont_installment * $tenor) - $principal;
        $data['cont_installment'] = $cont_installment;		
        
        return view('ajax/calculate_installment',$data);        
    }

    public function generate_installment(Request $request)
    {
        $flatrate = (double) $request->flatrate;
        $principal = (double) str_replace(',','',$request->principal);			
        $tenor = (double) str_replace(',','',$request->tenor);	
        $tenor_type = trim($request->tenor_type);
        $commence_date = trim($request->commence_date);	
        $tenor_type = 'M';	
        $cont_sales_date = $request->cont_sales_date;
        
        $installment_update = (double)str_replace(',','',$request->installment_update);
        
        $param['principal'] = $principal;
        $param['tenor'] = $tenor;
        $param['tenor_type'] = $tenor_type;
        $param['flatrate'] = $flatrate;
        $param['cont_sales_date'] = $cont_sales_date;
        $param['installment_update'] = $installment_update;   
        $data['records'] = $this->exec_sp('USP_GenerateAmortizationFlatRate',$param,'list','sqlsrv');        
        
        return view('ajax/amortization',$data);                
    }

    // =========================================================================================
    // INSTALLMENT PAYMENT
    // =========================================================================================
    public function payment(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Pembayaran Angsuran';
        $this->data['form_sub_title'] = 'Pembayaran';        
        $this->data['form_desc'] = 'Pembayaran Angsuran';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];       
            
            // DROPDOWN
            $dd = new DropdownController;        
            $this->data['dd_marketing'] = (array) $dd->marketing_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_payment_type'] = (array) $dd->payment_type_cf('');
            $this->data['dd_collector'] = (array) $dd->collector_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_kwitansi'] = (array) $dd->activeKwitansiByContract($this->data['fields']->cont_branch_id, $this->data['fields']->cont_contract_no);
            $this->data['dd_tenor'] = (array) $dd->tenor_month_cf();            

            // DEFAULT VALUE                                  
            $this->data['fields']->IDX_T_FinancialReceive = '0'; 
            $this->data['fields']->pmt_id = ''; 
            $this->data['fields']->pmt_receipt_no = '';           
            $this->data['fields']->pmt_receipt_no_manual = '';           
            $this->data['fields']->pmt_type = '';            
            $this->data['fields']->pmt_period_amount = '0';
            $this->data['fields']->pmt_remark = '';
            $this->data['fields']->jumlah_periode = '1'; 
            $this->data['fields']->late_charge_amount = '0.00'; 
            $this->data['fields']->pmt_amount = number_format($this->data['fields']->cont_installment,2,'.',','); 
            $this->data['fields']->pmt_date = date('Y-m-d');            

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-payment');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_payment_form';
            $this->data['submit_title'] = 'Bayar';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_payment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialReceive' => 'required',
            'IDX_T_Contract' => 'required',                                 
            'pmt_branch_id' => 'required', 
            'pmt_contract_no' => 'required',                                 
            'pmt_period' => 'required',                                 
            'pmt_period_amount' => 'required',                                 
            'pmt_date' => 'required', 
            'pmt_type' => 'required',                                 
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_FinancialReceive_Save]'; 
            $this->next_action = 'reload';
            
            $state = 'approve';
            
            $data = $request->all();

            // REDIRECT TO CURRENT CONTRACT AFTER SAVE
            $this->next_url = url("/cf-loan-update" . '/' . $data['IDX_T_Contract']);
            
            $param['IDX_T_FinancialReceive'] = $data['IDX_T_FinancialReceive'];
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['pmt_branch_id'] = $data['pmt_branch_id'];
            $param['pmt_id'] = $data['pmt_id'];
            $param['pmt_contract_no'] = $data['pmt_contract_no'];
            $param['pmt_period'] = $data['pmt_period'];
            $param['pmt_period_amount'] = $data['pmt_period_amount'];
            $param['pmt_date'] = date('Y-m-d',strtotime($data['pmt_date']));
            $param['pmt_allocation'] = 'A';
            $param['pmt_amount'] = (double)str_replace(',','',$data['pmt_amount']);
            $param['pmt_status'] = 'A';
            $param['pmt_receipt_no'] = $data['pmt_receipt_no'];
            $param['pmt_receipt_no_manual'] = $data['pmt_receipt_no_manual'];
            $param['late_charge_amount'] = (double)str_replace(',','',$data['late_charge_amount']);
            $param['pmt_type'] = $data['pmt_type'];
            $param['pmt_collector'] = $data['pmt_collector'];
            $param['pmt_remark'] = $data['pmt_remark'];           

            $param['UserID'] = 'XXX'.$this->data['user_id']; 
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param, $this->next_url);
        }   
    }

    // =========================================================================================
    // PENALTY PAYMENT
    // =========================================================================================
    public function penalty_payment(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Pembayaran Denda';
        $this->data['form_sub_title'] = 'Pembayaran';        
        $this->data['form_desc'] = 'Pembayaran Denda';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];       
            
            // DROPDOWN
            $dd = new DropdownController;        
            $this->data['dd_marketing'] = (array) $dd->marketing_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_payment_type'] = (array) $dd->payment_type_cf('');
            $this->data['dd_collector'] = (array) $dd->collector_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_kwitansi'] = (array) $dd->activeKwitansiByContract($this->data['fields']->cont_branch_id, $this->data['fields']->cont_contract_no);
            $this->data['dd_tenor'] = (array) $dd->tenor_month_cf();            

            // DEFAULT VALUE                                  
            $this->data['fields']->IDX_T_FinancialReceive = '0'; 
            $this->data['fields']->pmt_id = ''; 
            $this->data['fields']->pmt_receipt_no = '';           
            $this->data['fields']->pmt_receipt_no_manual = '';           
            $this->data['fields']->pmt_type = '';            
            $this->data['fields']->pmt_period_amount = '0';
            $this->data['fields']->pmt_remark = '';
            $this->data['fields']->jumlah_periode = '1'; 
            $this->data['fields']->late_charge_amount = '0.00'; 
            $this->data['fields']->late_charge_amount = number_format($this->data['fields']->TotalPenaltyAmount - $this->data['fields']->TotalPenaltyPaid,2,'.',','); 
            // $this->data['fields']->TotalPenaltyAmount = number_format($this->data['fields']->TotalPenaltyAmount,2,'.',','); 
            // $this->data['fields']->TotalPenaltyPaid = number_format($this->data['fields']->TotalPenaltyPaid,2,'.',','); 
            $this->data['fields']->pmt_date = date('Y-m-d');            

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-penalty-payment');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_penalty_payment_form';
            $this->data['submit_title'] = 'Bayar';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_penalty_payment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialReceive' => 'required',
            'IDX_T_Contract' => 'required',                                 
            'pmt_branch_id' => 'required', 
            'pmt_contract_no' => 'required', 
            'pmt_date' => 'required', 
            'pmt_type' => 'required',                                 
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_Loan_PenaltyPayment_Save]'; 
            $this->next_action = 'reload';
            

            $state = 'approve';
            
            $data = $request->all();

            // REDIRECT TO CURRENT CONTRACT AFTER SAVE
            $this->next_url = url("/cf-loan-update" . '/' . $data['IDX_T_Contract']);
            
            $param['IDX_T_FinancialReceive'] = $data['IDX_T_FinancialReceive'];
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['pmt_branch_id'] = $data['pmt_branch_id'];
            $param['pmt_id'] = $data['pmt_id'];
            $param['pmt_contract_no'] = $data['pmt_contract_no'];
            $param['pmt_period'] = '1';
            $param['pmt_period_amount'] = '1';
            $param['pmt_date'] = date('Y-m-d',strtotime($data['pmt_date']));
            $param['pmt_allocation'] = 'D';
            $param['pmt_amount'] = (double)str_replace(',','',$data['late_charge_amount']);
            $param['pmt_status'] = 'A';
            $param['pmt_receipt_no'] = $data['pmt_receipt_no'];
            $param['pmt_receipt_no_manual'] = $data['pmt_receipt_no_manual'];
            $param['late_charge_amount'] = (double)str_replace(',','',$data['late_charge_amount']);
            $param['pmt_type'] = $data['pmt_type'];
            $param['pmt_collector'] = $data['pmt_collector'];
            $param['pmt_remark'] = $data['pmt_remark'];           

            $param['UserID'] = 'XXX'.$this->data['user_id']; 
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param, $this->next_url);
        }   
    }

    // =========================================================================================
    // TERMINATION
    // =========================================================================================
    public function termination(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Pembayaran Angsuran';
        $this->data['form_sub_title'] = 'Pembayaran';        
        $this->data['form_desc'] = 'Pembayaran Angsuran';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_Contract)[0];       
            
            // DROPDOWN
            $dd = new DropdownController;        
            $this->data['dd_marketing'] = (array) $dd->marketing_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_payment_type'] = (array) $dd->payment_type_cf('');
            $this->data['dd_collector'] = (array) $dd->collector_cf($this->data['fields']->cont_branch_id);
            $this->data['dd_kwitansi'] = (array) $dd->activeKwitansiByContract($this->data['fields']->cont_branch_id, $this->data['fields']->cont_contract_no);
            $this->data['dd_tenor'] = (array) $dd->tenor_month_cf();            

            // DEFAULT VALUE                                  
            $this->data['fields']->IDX_T_FinancialReceive = '0'; 
            $this->data['fields']->pmt_id = ''; 
            $this->data['fields']->pmt_receipt_no = '';           
            $this->data['fields']->pmt_receipt_no_manual = '';           
            $this->data['fields']->pmt_type = '';            
            $this->data['fields']->pmt_period_amount = '0';
            $this->data['fields']->pmt_remark = '';
            $this->data['fields']->jumlah_periode = '1'; 
            $this->data['fields']->late_charge_amount = '0.00'; 
            $this->data['fields']->pmt_amount = number_format($this->data['fields']->cont_installment,2,'.',','); 
            $this->data['fields']->pmt_date = date('Y-m-d');            

            // URL
            $this->data['url_save_modal'] = url('/cf-loan/save-termination');            

            // VIEW                          
            $this->data['view'] = 'loan/m_loan_termination_form';
            $this->data['submit_title'] = 'Bayar';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_termination(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialReceive' => 'required',
            'IDX_T_Contract' => 'required',                                 
            'pmt_branch_id' => 'required', 
            'pmt_contract_no' => 'required',                                 
            'pmt_period' => 'required',                                 
            'pmt_period_amount' => 'required',                                 
            'pmt_date' => 'required', 
            'pmt_type' => 'required',                                 
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_Contract'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CF_LoanTermination_Save]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/cf-loan-update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialReceive'] = $data['IDX_T_FinancialReceive'];
            $param['IDX_T_Contract'] = $data['IDX_T_Contract'];
            $param['pmt_branch_id'] = $data['pmt_branch_id'];
            $param['pmt_id'] = $data['pmt_id'];
            $param['pmt_contract_no'] = $data['pmt_contract_no'];
            $param['pmt_period'] = $data['pmt_period'];
            $param['pmt_period_amount'] = $data['pmt_period_amount'];
            $param['pmt_date'] = date('Y-m-d',strtotime($data['pmt_date']));
            $param['pmt_allocation'] = 'A';
            $param['pmt_amount'] = (double)str_replace(',','',$data['pmt_amount']);
            $param['pmt_status'] = 'A';
            $param['pmt_receipt_no'] = $data['pmt_receipt_no'];
            $param['pmt_receipt_no_manual'] = $data['pmt_receipt_no_manual'];
            $param['late_charge_amount'] = (double)str_replace(',','',$data['late_charge_amount']);
            $param['pmt_type'] = $data['pmt_type'];
            $param['pmt_collector'] = $data['pmt_collector'];
            $param['pmt_remark'] = $data['pmt_remark'];           

            $param['UserID'] = 'XXX'.$this->data['user_id']; 
            $param['RecordStatus'] = 'A';

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // LOOKUP & SELECT CONTRACT
    // =========================================================================================
    public function show_lookup(Request $request)
    {
        $this->data['form_title'] = 'Pinjaman';
        $this->data['form_sub_title'] = 'Pilih Pinjaman';
        $this->data['form_desc'] = 'Pilih Pinjaman';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/cf-loan-by-branch-list' . '/' . $request->cont_branch_id);        

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Customer','cust_branch_id','Cabang','Kode',
            'Nama','KTP','Alamat','Telp','HP','Status','Action');         

        $this->data['table_footer'] = array('','','','branch_desc','',
            'cust_name','cust_ktp','cust_address','','','','Action');

        $this->data['array_filter'] = array('branch_desc','cust_name','cust_ktp','cust_address');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        return view('loan/m_select_contract_list', $this->data);
    }

    // DOWNLOAD PDF 
    public function ar_eksternal($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_Contract'] = $id;
        $data['ar_type'] = 'eksternal';        

        return $this->generate_pdf($data,'stream');
    }

    public function ar_internal($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_Contract'] = $id;
        $data['ar_type'] = 'internal';        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        // $data['img_logo_w'] = '142';
        // $data['img_logo_h'] = '60';
        // $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_CF_Loan_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_Contract'])[0];
        
        $data['show_action'] = FALSE;

        // RECORDS
        $param['BranchID'] = $data['fields']->cont_branch_id;
        $param['ContractNo'] = $data['fields']->cont_contract_no;   
        $data['records_installment'] = $this->exec_sp('USP_RptAmortization',$param,'list','sqlsrv'); 

        

        if($data['ar_type'] == 'eksternal')
        {
            $pdf = PDF::loadView('loan/ar_eksternal_pdf', $data)->setPaper('a4', 'landscape');
        }
        else 
        {
            $pdf = PDF::loadView('loan/ar_internal_pdf', $data)->setPaper('a4', 'landscape');
        }        

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream($data['fields']->cont_contract_no.'.pdf');
        }

        if ($return_type == 'download')
        {            
            return $pdf->download($data['fields']->cont_contract_no.'.pdf');   
        }

        if ($return_type == 'email')
        {
            \Storage::put('public/temp/loan-'.$data['fields']->cont_contract_no.'.pdf', $pdf->output());
            
            //echo storage_path().'/app/public/temp/invoice.pdf';

            return storage_path().'/app/public/temp/loan-'.$data['fields']->cont_contract_no.'.pdf'; 
        }
    }
}