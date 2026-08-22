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
use App\File;
use Image;

class PartnerController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/general.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Procurement';
        $this->data['form_title'] = 'Business Partner';
        $this->data['form_remark'] = 'Business Partner atau supplier adalah penjual barang dan jasa kepada perusahaan';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general'; 

        // BREADCRUMB
        $this->data['breads'] = array('Setting & Configuration','Business Partner'); 

        // URL
        $this->data['url_create'] = url('gn-partner/create');
        $this->data['url_search'] = url('gn-partner-list');           
        $this->data['url_update'] = url('gn-partner/update/'); 
        $this->data['url_cancel'] = url('gn-partner'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'Daftar Business Partner';
        $this->data['form_desc'] = 'Daftar Business Partner';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'BarcodeMember', 'Kode Partner', 'Nama Partner', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'No KTP',
            'NPWP', 'No HP', 'Keterangan', 'Alamat', 'ActiveDesc','Status','Action');         

        $this->data['table_footer'] = array('', 'IDX_M_Partner', 'BarcodeMember', 'PartnerID', 'PartnerName', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc','','Action');

        $this->data['array_filter'] = array('PartnerID','PartnerName','BarcodeMember','SingleIdentityNumber','PartnerType','Street');

        // VIEW
        $this->data['view'] = 'general/partner_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['PartnerID'] = $request->input('PartnerID');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['BarcodeMember'] = $request->input('BarcodeMember');  
        $array_filter['SingleIdentityNumber'] = $request->input('SingleIdentityNumber'); 
        $array_filter['PartnerType'] = ''; // SUPPLIER
        $array_filter['Street'] = $request->input('Street');          
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GN_Partner_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Partner', 'BarcodeMember', 'PartnerID', 'PartnerName', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Input Business Partner';
        $this->data['form_desc'] = 'Input Business Partner';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GN_Partner_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Partner = '0';    
            $this->data['fields']->ActiveStatus = 'A';        
            $this->data['fields']->RecordStatus = 'A';
            
            return $this->show_form(0, 'create');
        } else {

            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Update Business Partner';
        $this->data['form_desc'] = 'Update Business Partner';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GN_Partner_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            //$this->data['fields']->PODate = date('Y-m-d', strtotime($this->data['fields']->PODate));
            //$this->data['fields']->POExpectedDate = date('Y-m-d', strtotime($this->data['fields']->POExpectedDate));
            //$this->data['fields']->MeterStart = number_format($this->data['fields']->MeterStart,2,'.',',');
           

            return $this->show_form($id, 'update');
        } 
        else 
        {
            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;        
        $this->data['dd_gender'] = (array) $dd->gender(); 
        $this->data['dd_active_status'] = (array) $dd->active_status();                
                       

        // RECORDS
        if($state !== 'create')
        {
            $param['IDX_M_Partner'] = $this->data['fields']->IDX_M_Partner;
            $this->data['records_address'] = $this->exec_sp('USP_GN_PartnerAddress_List',$param,'list','sqlsrv');   
            $this->data['records_bank'] = $this->exec_sp('USP_GN_PartnerBank_List',$param,'list','sqlsrv');             
        }

        // URL
        $this->data['url_save_header'] = url('/gn-partner/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW  
        $this->data['view'] = 'general/partner_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GN_Partner_Save]';
        $this->sp_update = '[dbo].[USP_GN_Partner_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/gn-partner/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Partner' => 'required',
            'Phone1' => 'required',
            'PartnerName' => 'required',
            'SingleIdentityNumber' => 'required',
            'Email' => 'required|email:rfc,dns',
            'MobilePhone' => 'required',
        ],[
            'IDX_M_Partner.required' => 'Index vendor is required',
            'Phone1.required' => 'No telp belum diisi!',
            'PartnerName.required' => 'Nama belum diisi!',
            'SingleIdentityNumber.required' => 'No KTP belum diisi',
            'Email.required' => 'Alamat email belum diisi!',
            'MobilePhone.required' => 'No HP belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['PartnerID'] = $data['PartnerID'];
            $param['BarcodeMember'] = $data['BarcodeMember'];
            $param['Prefix'] = $data['Prefix'];
            $param['PartnerName'] = $data['PartnerName'];
            $param['PartnerAlias'] = $data['PartnerAlias'];
            $param['Gender'] = $data['Gender'];
            $param['SingleIdentityNumber'] = 'XXX'.$data['SingleIdentityNumber'];
            $param['TaxIdentityNumber'] = 'XXX'.$data['TaxIdentityNumber'];
            $param['DateOfBirth'] = $data['DateOfBirth'];
            $param['PlaceOfBirth'] = $data['PlaceOfBirth'];
            $param['Email'] = $data['Email'];
            $param['Phone1'] = $data['Phone1'];
            $param['Phone2'] = $data['Phone2'];
            $param['FaxNo'] = $data['FaxNo'];
            $param['MobilePhone'] = $data['MobilePhone'];
            $param['Remarks'] = $data['Remarks'];

            $param['IsSupplier'] = isset($_POST['IsSupplier']) ? 'Y' : 'N'; 
            $param['IsCustomer'] = isset($_POST['IsCustomer']) ? 'Y' : 'N'; 
            $param['IsCompany'] = isset($_POST['IsCompany']) ? 'Y' : 'N'; 
            $param['IsMember'] = isset($_POST['IsMember']) ? 'Y' : 'N';

            // @IsDTTOT ditambahkan di stored procedure saat screening DTTOT dibuat.
            // Parameter dikirim posisional, jadi tanpa baris ini seluruh parameter
            // sesudahnya bergeser dan penyimpanan gagal.
            //
            // Form ini belum punya kolomnya sementara SP menimpa nilainya setiap
            // simpan, jadi tanda hasil screening dibaca dulu agar tidak terhapus
            // hanya karena data lain diubah.
            $param['IsDTTOT'] = $this->tanda_dttot($data['IDX_M_Partner']);

            $param['StartDate'] = isset($_POST['StartDate']) ? $_POST['StartDate'] : '';
            $param['EndDate'] = isset($_POST['StartDate']) ? $_POST['StartDate'] : '';
            $param['ARAccount'] = $data['ARAccount'];
            $param['APAccount'] = $data['APAccount'];
            $param['ActiveStatus'] = $data['ActiveStatus'];
            $param['CreditLimit'] = (double)str_replace(',','',$data['CreditLimit']);
            $param['DiscountMember'] = '0.00'; //(double)str_replace(',','',$data['DiscountMember']);
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    /**
     * Tanda hasil screening DTTOT yang tersimpan. Konsumen baru selalu 'N'.
     */
    private function tanda_dttot($idx_partner)
    {
        if ((int) $idx_partner === 0) {
            return 'N';
        }

        $rows = DB::connection('sqlsrv')->select(
            "SELECT IsDTTOT FROM GN_M_Partner WITH(NOLOCK) WHERE IDX_M_Partner = ?",
            [(int) $idx_partner]);

        return ($rows && trim($rows[0]->IsDTTOT ?? '') === 'Y') ? 'Y' : 'N';
    }

    // =========================================================================================
    // LOOKUP & SELECT VENDOR
    // =========================================================================================
    public function show_lookup(Request $request)
    {
        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Select Business Partner';
        $this->data['form_desc'] = 'Select business partner (customer or vendor)';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/gn-partner-list');        

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'BarcodeMember', 'ID', 'Nama', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'KTP',
            'NPWP', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc','Status','Action');         

        $this->data['table_footer'] = array('', 'IDX_M_Partner', 'BarcodeMember', 'PartnerID', 'PartnerName', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc','','Action');

        $this->data['array_filter'] = array('PartnerID','PartnerName','BarcodeMember','SingleIdentityNumber','PartnerType','Street');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        return view('general/m_select_partner_list', $this->data);
    }

    // =========================================================================================
    // INPUT CEPAT KONSUMEN
    // Dipakai form input cepat penjualan/pembelian valas supaya kasir tidak perlu
    // pindah menu hanya untuk mendaftarkan konsumen baru. Yang diminta hanya data
    // wajib; kelengkapan lain diisi belakangan lewat menu Business Partner.
    // =========================================================================================
    public function quick_form(Request $request)
    {
        $this->data['form_desc']    = 'Tambah konsumen baru';
        $this->data['target_index'] = $request->input('target_index', '');
        $this->data['target_name']  = $request->input('target_name', '');
        $this->data['url_save']     = url('/gn-partner-quick-save');
        // Foto KTP memakai endpoint yang sama dengan menu Business Partner:
        // berkas baru bisa diunggah sesudah konsumennya punya IDX.
        $this->data['url_ktp_upload'] = url('/mc-partner-ktp/upload');

        return view('general/m_partner_quick_form', $this->data);
    }

    public function quick_save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PartnerName'          => 'required',
            'SingleIdentityNumber' => 'required',
            'Street'               => 'required',
            'MobilePhone'          => 'required',
        ], [
            'PartnerName.required'          => 'Nama konsumen belum diisi!',
            'SingleIdentityNumber.required' => 'NIK belum diisi!',
            'Street.required'               => 'Alamat belum diisi!',
            'MobilePhone.required'          => 'No handphone belum diisi!',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'flag'    => 'error',
                'message' => implode('<br>', $validator->errors()->all()),
            ]);
        }

        $nama  = trim($request->input('PartnerName'));
        $nik   = trim($request->input('SingleIdentityNumber'));

        // Bentuk nomor identitas diperiksa lebih dulu supaya salah ketik tidak
        // lolos jadi data konsumen. NIK Indonesia selalu 16 digit angka; nomor
        // berhuruf diperlakukan sebagai paspor dan hanya dibatasi panjangnya.
        $pesan_nik = '';

        if (ctype_digit($nik)) {
            if (strlen($nik) !== 16) {
                $pesan_nik = 'NIK harus 16 digit angka. Yang diisi ' . strlen($nik)
                    . ' digit. Untuk paspor, ketik nomornya beserta hurufnya.';
            }
        } elseif (!preg_match('/^[A-Za-z0-9]{6,}$/', $nik)) {
            $pesan_nik = 'Nomor identitas hanya boleh berisi huruf dan angka, minimal 6 karakter.';
        }

        if ($pesan_nik !== '') {
            return response()->json(['flag' => 'error', 'message' => $pesan_nik]);
        }

        $alamat = trim($request->input('Street'));
        $hp    = trim($request->input('MobilePhone'));

        // Tempat/tanggal lahir tidak wajib, tapi kalau diisi bentuk tanggalnya
        // diperiksa supaya yang masuk ke database benar-benar tanggal.
        $tempat_lahir  = trim($request->input('PlaceOfBirth', ''));
        $tanggal_lahir = trim($request->input('DateOfBirth', ''));

        if ($tanggal_lahir !== '') {
            $tanggal = date_create_from_format('Y-m-d', $tanggal_lahir);

            if (!$tanggal || $tanggal->format('Y-m-d') !== $tanggal_lahir) {
                return response()->json([
                    'flag'    => 'error',
                    'message' => 'Tanggal lahir harus berbentuk YYYY-MM-DD, mis. 1990-05-17.',
                ]);
            }

            if ($tanggal->format('Y-m-d') > date('Y-m-d')) {
                return response()->json([
                    'flag'    => 'error',
                    'message' => 'Tanggal lahir tidak boleh melewati hari ini.',
                ]);
            }
        }

        // NIK yang sama berarti orangnya sudah terdaftar. Daripada membuat data
        // kembar, konsumen yang ada langsung dipakai dan kasir diberi tahu.
        $sudah_ada = DB::connection('sqlsrv')->select(
            "SELECT TOP 1 IDX_M_Partner, PartnerID, PartnerName
             FROM GN_M_Partner WITH(NOLOCK)
             WHERE RTRIM(ISNULL(SingleIdentityNumber,'')) = ?
                 AND RTRIM(ISNULL(RecordStatus,'A')) = 'A'
             ORDER BY IDX_M_Partner", [$nik]);

        if ($sudah_ada) {
            return response()->json([
                'flag'         => 'success',
                'sudah_ada'    => true,
                'idx'          => (int) $sudah_ada[0]->IDX_M_Partner,
                'partner_id'   => trim($sudah_ada[0]->PartnerID),
                'partner_name' => trim($sudah_ada[0]->PartnerName),
                'message'      => 'NIK ini sudah terdaftar atas nama <b>'
                    . e(trim($sudah_ada[0]->PartnerName)) . '</b>. Konsumen tersebut yang dipakai.',
            ]);
        }

        // Urutan parameter mengikuti USP_GN_Partner_Save persis, termasuk
        // @IsDTTOT yang berada di antara IsMember dan StartDate.
        $hasil = DB::connection('sqlsrv')->select(
            "EXEC [dbo].[USP_GN_Partner_Save]
                @IDX_M_Partner = 0,
                @PartnerID = '',
                @BarcodeMember = '',
                @Prefix = '',
                @PartnerName = ?,
                @PartnerAlias = '',
                @Gender = '',
                @SingleIdentityNumber = ?,
                @TaxIdentityNumber = '',
                @DateOfBirth = ?,
                @PlaceOfBirth = ?,
                @Email = '',
                @Phone1 = '',
                @Phone2 = '',
                @FaxNo = '',
                @MobilePhone = ?,
                @Remarks = ?,
                @IsSupplier = 'N',
                @IsCustomer = 'Y',
                @IsCompany = 'N',
                @IsMember = 'N',
                @IsDTTOT = 'N',
                @StartDate = NULL,
                @EndDate = NULL,
                @ARAccount = 5,
                @APAccount = 12,
                @ActiveStatus = 'A',
                @CreditLimit = 0,
                @DiscountMember = 0,
                @UserID = ?,
                @RecordStatus = 'A'",
            [$nama, $nik, ($tanggal_lahir !== '' ? $tanggal_lahir : null), $tempat_lahir,
             $hp, 'Input cepat transaksi valas', $this->data['user_id']]);

        $flag = '';
        $idx  = 0;
        foreach ($hasil as $row) {
            $flag = strtolower(trim($row->Result ?? ''));
            $idx  = (int) ($row->ID ?? 0);
        }

        if ($flag !== 'success' || $idx === 0) {
            return response()->json([
                'flag'    => 'error',
                'message' => $this->sweet_alert_message($hasil),
            ]);
        }

        // Alamat disimpan sebagai Alamat KTP dan jadi alamat utama. SP khusus
        // dipakai karena USP_CM_PartnerAddress_Create mewajibkan kode pos,
        // sedangkan input cepat hanya meminta data wajib.
        $hasil_alamat = DB::connection('sqlsrv')->select(
            "EXEC [dbo].[USP_GN_PartnerQuickAddress_Create]
                @IDX_M_Partner = ?, @Street = ?, @Zip = ?, @UserID = ?",
            [$idx, $alamat, trim($request->input('Zip', '')), $this->data['user_id']]);

        // Konsumennya sudah terbentuk, jadi transaksi tetap bisa jalan walau
        // alamatnya gagal tersimpan. Kasir diberi tahu agar bisa melengkapinya.
        $catatan_alamat = '';
        foreach ($hasil_alamat as $row) {
            if (strtolower(trim($row->Result ?? '')) !== 'success') {
                $catatan_alamat = '<br><span class="text-danger">Alamat gagal disimpan ('
                    . e(trim($row->LogDesc ?? '')) . '). Lengkapi lewat menu Business Partner.</span>';
            }
        }

        $baru = DB::connection('sqlsrv')->select(
            "SELECT PartnerID, PartnerName FROM GN_M_Partner WITH(NOLOCK)
             WHERE IDX_M_Partner = ?", [$idx]);

        return response()->json([
            'flag'         => 'success',
            'sudah_ada'    => false,
            'idx'          => $idx,
            'partner_id'   => $baru ? trim($baru[0]->PartnerID) : '',
            'partner_name' => $baru ? trim($baru[0]->PartnerName) : $nama,
            'message'      => 'Konsumen <b>' . e($nama) . '</b> berhasil ditambahkan.' . $catatan_alamat,
        ]);
    }
}