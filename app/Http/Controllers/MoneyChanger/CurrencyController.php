<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownLoanController;

use Maatwebsite\Excel\Facades\Excel;
use Validator;
use PDF;
use App\File;
use Image;


class CurrencyController extends MyController
{
    // Acuan kurs display = Rate Beli/Jual pada MC_M_Currency, yang diperbarui
    // lewat tool import kurs Bank Panin (lihat import_kurs / import_kurs_save).

    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = 'Currency';
        
        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Setting','Currency'); 

        // URL
        $this->data['url_create'] = url('mc-currency/create');
        $this->data['url_search'] = url('mc-currency-list');           
        $this->data['url_update'] = url('mc-currency/update/');        
        $this->data['url_cancel'] = url('mc-currency'); 

        
        parent::__construct($request);
    }

    public function display_kurs(Request $request)
    {
        $param['page'] = 1;
        $param['row'] = 100;
        $param['sort_by'] = 'SortPriority';
        $param['sort_dir'] = 'ASC';
        $param['return_type'] = 'R';
        $param['CurrencyName'] = '';
        $param['CurrencyID'] = '';
        $this->data['records'] = $this->exec_sp('USP_MC_Currency_List',$param,'list','sqlsrv');

        $this->data['view'] = 'money_changer/display_kurs';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // DISPLAY KURS - VERSI TV (full screen, auto-refresh, paginasi otomatis)
    // =========================================================================================
    // Kurs yang ditampilkan diambil langsung dari MC_M_Currency (Rate Beli/Jual),
    // yang diperbarui lewat tool import kurs Bank Panin.
    private function kurs_records()
    {
        $param['page'] = 1;
        $param['row'] = 100;
        $param['sort_by'] = 'SortPriority';
        $param['sort_dir'] = 'ASC';
        $param['return_type'] = 'R';
        $param['CurrencyName'] = '';
        $param['CurrencyID'] = '';

        $rows = $this->exec_sp('USP_MC_Currency_List', $param, 'list', 'sqlsrv');

        // Hanya tampilkan mata uang aktif dengan kurs valid (rapi untuk layar TV).
        $out = [];
        foreach ($rows as $r) {
            $buy  = (float) $r->BuyRate;
            $sell = (float) $r->SellRate;

            if ($sell <= 0 && $buy <= 0) {
                continue;
            }

            $out[] = [
                'CurrencyID'   => strtoupper(trim($r->CurrencyID)),
                'CurrencyName' => trim($r->CurrencyName),
                'CountryName'  => trim($r->CountryName),
                'IconFlag'     => trim($r->IconFlag),
                'SellRate'     => $sell,
                'BuyRate'      => $buy,
            ];
        }
        return $out;
    }

    public function display_kurs_tv(Request $request)
    {
        $this->data['records']  = $this->kurs_records();
        $this->data['url_data'] = url('mc-display-kurs-tv-data');
        $this->data['view'] = 'money_changer/display_kurs_tv';
        return view($this->data['view'], $this->data);
    }

    // Board kurs sederhana (kurs_valas) - juga membaca Rate Beli/Jual dari MC_M_Currency.
    public function display_kurs_valas(Request $request)
    {
        return view('kurs_valas', ['records' => $this->kurs_records()]);
    }

    public function display_kurs_tv_data(Request $request)
    {
        return response()->json([
            'server_time' => date('c'),
            'rows'        => $this->kurs_records(),
        ]);
    }

    // =========================================================================================
    // IMPORT KURS (paste tabel kurs bank -> update Rate Beli/Jual MC_M_Currency)
    // =========================================================================================
    // Situs bank diproteksi (Akamai dll.) sehingga tidak bisa di-scrape dari server.
    // Operator menyalin tabel kurs dari situs bank lalu menempelnya di sini.
    // Alur tiap sumber: paste -> preview (parse saja) -> konfirmasi -> simpan.

    // Konfigurasi tiap sumber bank.
    private function kurs_source($key)
    {
        if ($key === 'bca') {
            return [
                'key'         => 'bca',
                'name'        => 'Bank BCA',
                'url'         => 'https://www.bca.co.id/id/informasi/kurs',
                'parser'      => \App\Services\BcaKursParser::class,
                'options'     => ['erate' => 'e-Rate', 'tt' => 'TT Counter', 'banknotes' => 'Bank Notes'],
                'default'     => 'erate',
                'note'        => 'Default e-Rate (angka ke-1 & ke-2 tiap baris). Format angka: 18.000,00',
                'placeholder' => "USD  18.000,00  18.020,00  17.850,00  18.125,00  17.785,00  18.060,00  ...",
                'base'        => '/mc-currency-import-kurs-bca',
            ];
        }

        return [
            'key'         => 'panin',
            'name'        => 'Bank Panin',
            'url'         => 'https://www.panin.co.id/id/kurs',
            'parser'      => \App\Services\PaninKursParser::class,
            'options'     => ['tt' => 'TT Counter', 'special' => 'Spesial Rate'],
            'default'     => 'tt',
            'note'        => 'Default TT Counter (angka ke-3 & ke-4 tiap baris). Format angka: 17.990,00 / 18,030.00',
            'placeholder' => "USD  17,990.00  18,020.00  17,980.00  18,030.00  ...",
            'base'        => '/mc-currency-import-kurs',
        ];
    }

    // ----- PANIN -----
    public function import_kurs(Request $request)          { return $this->kurs_import_show($this->kurs_source('panin')); }
    public function import_kurs_preview(Request $request)  { return $this->kurs_import_preview($this->kurs_source('panin'), $request); }
    public function import_kurs_save(Request $request)     { return $this->kurs_import_save($this->kurs_source('panin'), $request); }

    // ----- BCA -----
    public function import_kurs_bca(Request $request)         { return $this->kurs_import_show($this->kurs_source('bca')); }
    public function import_kurs_bca_preview(Request $request) { return $this->kurs_import_preview($this->kurs_source('bca'), $request); }
    public function import_kurs_bca_save(Request $request)    { return $this->kurs_import_save($this->kurs_source('bca'), $request); }

    // Langkah 1: form paste (state edit / hasil simpan dari redirect).
    private function kurs_import_show($cfg)
    {
        $this->kurs_import_header($cfg);

        $this->data['state']   = 'edit';
        $this->data['pasted']  = '';
        $this->data['rateset'] = session('import_rateset_' . $cfg['key'], $cfg['default']);
        $this->data['preview'] = null;
        $this->data['result']  = session('import_result_' . $cfg['key']);

        $this->data['view'] = 'money_changer/import_kurs';
        return view($this->data['view'], $this->data);
    }

    // Langkah 2: parse saja (TANPA tulis DB) lalu tampilkan preview untuk dikonfirmasi.
    private function kurs_import_preview($cfg, $request)
    {
        $this->kurs_import_header($cfg);

        $pasted  = (string) $request->input('pasted', '');
        $rateset = $this->valid_rateset($cfg, $request->input('rateset'));

        $this->data['pasted']  = $pasted;
        $this->data['rateset'] = $rateset;
        $this->data['result']  = null;
        $this->data['view']    = 'money_changer/import_kurs';

        if (trim($pasted) === '') {
            $this->data['state']   = 'edit';
            $this->data['preview'] = null;
            $this->data['error']   = 'Teks kurs masih kosong. Tempel tabel kurs dari situs ' . $cfg['name'] . ' terlebih dahulu.';
            return view($this->data['view'], $this->data);
        }

        $parserClass = $cfg['parser'];
        $parser = new $parserClass();
        $parsed = $parser->parse($pasted, $rateset, $this->currency_codes());

        $this->data['state']   = 'preview';
        $this->data['preview'] = [
            'rateset'  => $rateset,
            'parsed'   => $parsed,             // akan disimpan
            'skipped'  => $parser->skipped(),  // kode tak ada di master aktif
            'unparsed' => $parser->unparsed(), // baris gagal diurai angkanya
        ];

        return view($this->data['view'], $this->data);
    }

    // Langkah 3: simpan ke MC_M_Currency (parse ulang teks yang sudah dipratinjau).
    private function kurs_import_save($cfg, $request)
    {
        $pasted  = (string) $request->input('pasted', '');
        $rateset = $this->valid_rateset($cfg, $request->input('rateset'));

        if (trim($pasted) === '') {
            return redirect($cfg['base'])
                ->with('import_rateset_' . $cfg['key'], $rateset)
                ->with('import_result_' . $cfg['key'], ['error' => 'Teks kurs masih kosong. Tempel tabel kurs dari situs ' . $cfg['name'] . ' terlebih dahulu.']);
        }

        $parserClass = $cfg['parser'];
        $parser = new $parserClass();
        $parsed = $parser->parse($pasted, $rateset, $this->currency_codes());

        $updated = [];
        $notfound = [];
        foreach ($parsed as $row) {
            $param = [
                'CurrencyID' => $row['currency'],
                'BuyRate'    => $row['buy'],
                'SellRate'   => $row['sell'],
                'UserID'     => 'XXX' . $this->data['user_id'],
            ];
            $res = $this->exec_sp('USP_MC_Currency_UpdateRate', $param, 'list', 'sqlsrv');

            $ok = !empty($res) && isset($res[0]->Result) && $res[0]->Result === 'success'
                && (int) ($res[0]->Affected ?? 0) > 0;

            if ($ok) {
                $updated[] = $row;
            } else {
                $notfound[] = $row['currency'];
            }
        }

        $result = [
            'rateset'  => $rateset,
            'updated'  => $updated,
            'notfound' => array_values(array_unique(array_merge($notfound, $parser->skipped()))),
            'unparsed' => $parser->unparsed(),
        ];

        return redirect($cfg['base'])
            ->with('import_rateset_' . $cfg['key'], $rateset)
            ->with('import_result_' . $cfg['key'], $result);
    }

    // Pastikan pilihan kolom kurs valid untuk sumber terkait.
    private function valid_rateset($cfg, $value)
    {
        return array_key_exists((string) $value, $cfg['options']) ? (string) $value : $cfg['default'];
    }

    private function kurs_import_header($cfg)
    {
        $this->data['title']          = 'Import Kurs ' . $cfg['name'];
        $this->data['form_title']     = 'Import Kurs';
        $this->data['form_sub_title'] = 'Update Kurs dari ' . $cfg['name'];
        $this->data['form_remark']    = 'Salin tabel kurs dari situs ' . $cfg['name'] . ' lalu tempel di sini untuk memperbarui Rate Beli/Jual mata uang.';

        $this->data['source_name']      = $cfg['name'];
        $this->data['source_url']       = $cfg['url'];
        $this->data['rate_options']     = $cfg['options'];
        $this->data['rateset_note']     = $cfg['note'];
        $this->data['paste_placeholder'] = $cfg['placeholder'];
        $this->data['url_preview']      = url($cfg['base'] . '/preview');
        $this->data['url_save']         = url($cfg['base'] . '/save');
        $this->data['url_cancel']       = url('mc-currency');

        array_push($this->data['breads'], 'Import Kurs ' . $cfg['name']);
    }

    // Daftar kode mata uang AKTIF di master (untuk validasi parser & preview).
    private function currency_codes()
    {
        $param['page'] = 1;
        $param['row'] = 100;
        $param['sort_by'] = 'SortPriority';
        $param['sort_dir'] = 'ASC';
        $param['return_type'] = 'R';
        $param['CurrencyName'] = '';
        $param['CurrencyID'] = '';

        $rows = $this->exec_sp('USP_MC_Currency_List', $param, 'list', 'sqlsrv');

        $codes = [];
        foreach ($rows as $r) {
            if (isset($r->RecordStatus) && strtoupper(trim($r->RecordStatus)) !== 'A') {
                continue;
            }
            $codes[] = strtoupper(trim($r->CurrencyID));
        }
        return $codes;
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request, $status = '')
    {       
        $this->data['form_id'] = 'CF-LO-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;
        
        $this->data['form_sub_title'] = 'Daftar Currency';
        $this->data['form_remark'] = 'Daftar mata uang yang digunakan untuk transaksi jual beli valuta asing';    
        
        if($status !== '')
        {
            $this->data['url_search'] = url('mc-currency-list');
        }        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_Currency','Kode Mata Uang','Nama Mata Uang','Country ID',
                '','Nama Negara','Rate Beli','Rate Jual','RecordStatus','Status','Action');         

            $this->data['table_footer'] = array('','','CurrencyID','CurrencyName','',
                '','','','','','','Action');

            $this->data['array_filter'] = array('CurrencyName','CurrencyID','CountryName');

            // VIEW
            $this->data['view'] = 'money_changer/currency_list';  
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
        $array_filter['CurrencyName'] = $request->input('CurrencyName');
        $array_filter['CurrencyID'] = $request->input('CurrencyID');  
        $array_filter['CountryName'] = $request->input('CountryName');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_Currency_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Currency','CurrencyID','CurrencyName','CountryID',
            'IconFlag','CountryName','BuyRate','SellRate','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-FA-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Currency';
        $this->data['form_sub_title'] = 'Input Currency';
        $this->data['form_desc'] = 'Create Currency';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_Currency_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Currency = 0;        
            $this->data['fields']->RecordStatus = 'A';

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
        $this->data['form_id'] = 'FM-FA-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Currency';
        $this->data['form_sub_title'] = 'Update Currency';
        $this->data['form_desc'] = 'Update Currency';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_Currency_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];   
            
            $this->data['fields']->BuyRate = number_format($this->data['fields']->BuyRate, 4, '.',',');
            $this->data['fields']->SellRate = number_format($this->data['fields']->SellRate, 4, '.',',');

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
        $dd = new DropdownController;                
        $this->data['dd_country'] = (array) $dd->country();   
        $this->data['dd_record_status'] = (array) $dd->active_status();        

        // URL
        $this->data['url_save_header'] = url('/mc-currency/save');       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Keterangan Currency';        
        $this->data['view'] = 'money_changer/currency_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_Currency_Save]';
        $this->sp_update = '[dbo].[USP_MC_Currency_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-currency/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Currency' => 'required',
            'IDX_M_Country' => 'required',
            'CurrencyID' => 'required',
            'CurrencyName' => 'required',
            'Symbol' => 'required',       
            'BuyRate' => 'required',
            'SellRate' => 'required',  
            'SalesAccount' => 'required',       
            'PurchaseAccount' => 'required',
            'COGSAccount' => 'required',
        ],[
            'IDX_M_Country.required' => 'Kode negara belum diisi!',
            'CurrencyName.required' => 'Nama mata uang belum diisi!',
            'CurrencyID.required' => 'Kode mata uang belum diisi!',
            'Symbol.required' => 'Simbol mata uang belum diisi!',
            'BuyRate.required' => 'Rate beli belum diisi!',
            'SellRate.required' => 'Rate jual belum diisi!',
            'SalesAccount.required' => 'Sales Account belum diisi!',
            'PurchaseAccount.required' => 'Purchase Account belum diisi!',
            'COGSAccount.required' => 'COGS Account belum diisi!',

        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_Currency'));
        } 
        else 
        {
            $data = $request->all();
            
            $state = $data['state'];

            $data['Rounding'] = '0.00';
            $data['Accuracy'] = '0';
            
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_Country'] = $data['IDX_M_Country'];
            $param['CurrencyID'] = $data['CurrencyID'];
            $param['CurrencyName'] = $data['CurrencyName'];
            $param['Symbol'] = $data['Symbol'];
            $param['Remarks'] = '';
            $param['Rounding'] = (double)str_replace(',','',$data['Rounding']);
            $param['Accuracy'] = (double)str_replace(',','',$data['Accuracy']);
            $param['BuyRate'] = (double)str_replace(',','',$data['BuyRate']);
            $param['SellRate'] = (double)str_replace(',','',$data['SellRate']);
            $param['IconFlag'] = $data['IconFlag'];
            $param['SortPriority'] = (double)str_replace(',','',$data['SortPriority']);
            $param['SalesAccount'] = $data['SalesAccount'];
            $param['PurchaseAccount'] = $data['PurchaseAccount'];
            $param['COGSAccount'] = $data['COGSAccount'];

            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = $data['RecordStatus'];            

            return $this->store($state, $param);
        }
    }

}