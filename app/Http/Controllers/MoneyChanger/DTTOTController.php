<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use App\Imports\DTTOTImport;
use Maatwebsite\Excel\Facades\Excel;
use PhpOffice\PhpSpreadsheet\Shared\Date as ExcelDate;

/**
 * DTTOT (Daftar Terduga Teroris dan Organisasi Teroris).
 * Daftar nama diupload dari file Excel resmi (renewal periodik).
 * Alur upload: pilih file -> preview tervalidasi -> konfirmasi simpan.
 * Setiap upload MENGGANTI seluruh isi tabel GN_M_DTTOT karena file
 * renewal selalu berisi daftar lengkap terbaru.
 */
class DTTOTController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo'] = url('public/images/logo/general.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'DTTOT';
        $this->data['form_remark'] = 'Daftar Terduga Teroris dan Organisasi Teroris (DTTOT) yang diupload dari file Excel resmi.
            Gunakan daftar ini untuk screening konsumen sebelum bertransaksi.';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'DTTOT');

        // URL
        $this->data['url_create'] = url('mc-dttot/upload');
        $this->data['url_search'] = url('mc-dttot-list');
        $this->data['url_cancel'] = url('mc-dttot');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'Daftar DTTOT';
        $this->data['form_desc'] = 'Daftar DTTOT';

        // BREADCRUMB
        array_push($this->data['breads'], 'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_DTTOT', 'Nama', 'Deskripsi', 'Terduga', 'Kode Densus',
            'Tempat Lahir', 'Tanggal Lahir', 'WN/Asal Negara', 'Alamat', 'File', 'Tanggal Upload');

        $this->data['table_footer'] = array('', 'IDX_M_DTTOT', 'FullName', 'Description', 'SuspectType', 'DensusCode',
            'PlaceOfBirth', 'DateOfBirth', 'Nationality', 'Address', 'FileName', 'UploadDate');

        $this->data['array_filter'] = array('FullName', 'DensusCode');

        // VIEW
        $this->data['view'] = 'money_changer/dttot_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['FullName'] = $request->input('FullName');
        $array_filter['DensusCode'] = $request->input('DensusCode');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GN_DTTOT_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_DTTOT', 'FullName', 'Description', 'SuspectType', 'DensusCode',
            'PlaceOfBirth', 'DateOfBirth', 'Nationality', 'Address', 'FileName', 'UploadDate');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // STEP 1: FORM UPLOAD
    // =========================================================================================
    public function upload(Request $request)
    {
        $this->data['form_sub_title'] = 'Upload File DTTOT';

        array_push($this->data['breads'], 'Upload');

        $this->data['state'] = 'upload';
        $this->data['preview'] = null;
        $this->data['result'] = session('dttot_import_result');

        session()->forget('dttot_import_result');

        $this->data['view'] = 'money_changer/dttot_upload';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 2: PREVIEW (VALIDASI TANPA SIMPAN)
    // =========================================================================================
    public function preview(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file_import' => 'required|file',
        ], [
            'file_import.required' => 'File Excel belum dipilih!',
        ]);

        $this->data['form_sub_title'] = 'Preview Upload DTTOT';
        $this->data['result'] = null;

        array_push($this->data['breads'], 'Preview');

        if ($validator->fails()) {
            $this->data['state'] = 'upload';
            $this->data['preview'] = null;
            $this->data['error'] = implode(' ', $validator->errors()->all());

            $this->data['view'] = 'money_changer/dttot_upload';
            return view($this->data['view'], $this->data);
        }

        $file_name = $request->file('file_import')->getClientOriginalName();

        // BACA FILE (tanpa heading row, posisi kolom file resmi tetap:
        // 0=Nama, 1=Deskripsi, 2=Terduga, 3=Kode Densus, 4=Tempat Lahir,
        // 5=Tanggal Lahir, 6=WN/Asal Negara, 7=Alamat)
        $import = new DTTOTImport;
        Excel::import($import, $request->file('file_import'));
        $rows = $import->rows ?? collect();

        $preview = [];
        $valid_rows = [];

        foreach ($rows as $i => $row) {
            $cells = $row->toArray();

            $name = trim((string) ($cells[0] ?? ''));

            // LEWATI BARIS HEADER & BARIS KOSONG
            if ($name === '' || strtolower($name) === 'nama') {
                continue;
            }

            $errors = [];

            $suspect_type = trim((string) ($cells[2] ?? ''));
            if ($suspect_type === '') {
                $errors[] = 'Kolom Terduga (Orang/Korporasi) kosong';
            }

            $densus_code = trim((string) ($cells[3] ?? ''));
            if ($densus_code === '') {
                $errors[] = 'Kode Densus kosong';
            }

            $item = [
                'row_no' => $i + 1,
                'FullName' => $name,
                'Description' => trim((string) ($cells[1] ?? '')),
                'SuspectType' => $suspect_type,
                'DensusCode' => $densus_code,
                'PlaceOfBirth' => trim((string) ($cells[4] ?? '')),
                'DateOfBirth' => $this->parse_date_text($cells[5] ?? ''),
                'Nationality' => trim((string) ($cells[6] ?? '')),
                'Address' => trim((string) ($cells[7] ?? '')),
                'errors' => $errors,
            ];

            $preview[] = $item;

            if (count($errors) === 0) {
                $valid_rows[] = $item;
            }
        }

        // SIMPAN BARIS VALID DI SESSION UNTUK STEP SAVE
        session([
            'dttot_import_rows' => $valid_rows,
            'dttot_import_file' => $file_name,
        ]);

        $this->data['state'] = 'preview';
        $this->data['preview'] = $preview;
        $this->data['valid_count'] = count($valid_rows);
        $this->data['error_count'] = count($preview) - count($valid_rows);
        $this->data['file_name'] = $file_name;
        $this->data['existing_count'] = $this->existing_count();

        $this->data['view'] = 'money_changer/dttot_upload';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 3: SAVE (REPLACE SELURUH ISI TABEL)
    // =========================================================================================
    public function save(Request $request)
    {
        $rows = session('dttot_import_rows', []);
        $file_name = session('dttot_import_file', '');

        session()->forget(['dttot_import_rows', 'dttot_import_file']);

        if (empty($rows)) {
            session(['dttot_import_result' => [
                'success' => 0, 'failed' => 0,
                'messages' => ['Tidak ada data untuk disimpan. Upload dan preview ulang file Anda.'],
            ]]);
            return redirect(url('/mc-dttot/upload'));
        }

        // KOSONGKAN TABEL: FILE RENEWAL SELALU BERISI DAFTAR LENGKAP TERBARU
        $this->exec_sp('USP_GN_DTTOT_Clear', array(), 'list', 'sqlsrv');

        $success = 0;
        $failed = 0;
        $messages = [];

        foreach ($rows as $item) {
            // ** Param sequence must refer to param sequence in USP_GN_DTTOT_Save **
            $param = [];
            $param['FullName'] = 'XXX' . $this->esc($item['FullName']);
            $param['Description'] = 'XXX' . $this->esc($item['Description']);
            $param['SuspectType'] = 'XXX' . $this->esc($item['SuspectType']);
            $param['DensusCode'] = 'XXX' . $this->esc($item['DensusCode']);
            $param['PlaceOfBirth'] = 'XXX' . $this->esc($item['PlaceOfBirth']);
            $param['DateOfBirth'] = 'XXX' . $this->esc($item['DateOfBirth']);
            $param['Nationality'] = 'XXX' . $this->esc($item['Nationality']);
            $param['Address'] = 'XXX' . $this->esc($item['Address']);
            $param['FileName'] = 'XXX' . $this->esc($file_name);
            $param['UserID'] = 'XXX' . $this->data['user_id'];

            $result = $this->exec_sp('USP_GN_DTTOT_Save', $param, 'list', 'sqlsrv');

            $ok = false;
            foreach ($result as $r) {
                if (isset($r->Result) && strtolower(trim($r->Result)) === 'success') {
                    $ok = true;
                }
            }

            if ($ok) {
                $success++;
            } else {
                $failed++;
                $messages[] = 'Baris ' . $item['row_no'] . ' (' . $item['FullName'] . ') gagal disimpan.';
            }
        }

        session(['dttot_import_result' => [
            'success' => $success,
            'failed' => $failed,
            'messages' => $messages,
        ]]);

        return redirect(url('/mc-dttot/upload'));
    }

    // =========================================================================================
    // SCREENING: COCOKKAN NAMA KONSUMEN DENGAN DAFTAR DTTOT
    // =========================================================================================
    public function screening(Request $request)
    {
        $this->data['form_sub_title'] = 'Screening DTTOT';
        $this->data['form_remark'] = 'Screening otomatis nama konsumen terhadap daftar DTTOT.
            EXACT = nama sama persis dengan nama/alias DTTOT, PARTIAL = nama saling terkandung (minimal 5 karakter).
            Centang konsumen yang akan ditandai IsDTTOT, lalu simpan. Hasil PARTIAL wajib diverifikasi manual
            (bandingkan tanggal lahir, alamat, dan identitas) sebelum ditandai.';

        array_push($this->data['breads'], 'Screening');

        // HASIL PENCOCOKAN
        $this->data['matches'] = $this->exec_sp('USP_GN_DTTOT_Screening', array(), 'list', 'sqlsrv');

        // KONSUMEN YANG SUDAH DITANDAI DTTOT TAPI TIDAK ADA DI HASIL PENCOCOKAN
        // (kandidat untuk dihapus tandanya setelah renewal daftar DTTOT)
        $matched_ids = [];
        foreach ($this->data['matches'] as $row) {
            $matched_ids[$row->IDX_M_Partner] = true;
        }

        $flagged = DB::connection('sqlsrv')->select("
            SELECT IDX_M_Partner, RTRIM(ISNULL(PartnerID,'')) AS PartnerID,
                UPPER(RTRIM(ISNULL(PartnerName,''))) AS PartnerName,
                RTRIM(ISNULL(SingleIdentityNumber,'')) AS SingleIdentityNumber
            FROM GN_M_Partner
            WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A' AND RTRIM(ISNULL(IsDTTOT,'')) = 'Y'
            ORDER BY PartnerName
        ");

        $this->data['unmatched_flagged'] = array_values(array_filter($flagged, function ($row) use ($matched_ids) {
            return !isset($matched_ids[$row->IDX_M_Partner]);
        }));

        $this->data['result'] = session('dttot_screening_result');
        session()->forget('dttot_screening_result');

        $this->data['url_save'] = url('mc-dttot/screening-save');

        $this->data['view'] = 'money_changer/dttot_screening';
        return view($this->data['view'], $this->data);
    }

    public function screening_save(Request $request)
    {
        $marked = array_unique((array) $request->input('mark', []));
        $matched = array_unique((array) $request->input('matched', []));
        $unflag = array_unique((array) $request->input('unflag', []));

        $set_yes = 0;
        $set_no = 0;

        // TANDAI KONSUMEN YANG DICENTANG
        foreach ($marked as $idx) {
            if (!is_numeric($idx)) {
                continue;
            }
            $this->set_dttot_flag($idx, 'Y');
            $set_yes++;
        }

        // HAPUS TANDA: BARIS HASIL MATCH YANG TIDAK DICENTANG
        foreach ($matched as $idx) {
            if (!is_numeric($idx) || in_array($idx, $marked)) {
                continue;
            }
            $this->set_dttot_flag($idx, 'N');
            $set_no++;
        }

        // HAPUS TANDA: KONSUMEN LAMA YANG SUDAH TIDAK ADA DI DAFTAR DTTOT
        foreach ($unflag as $idx) {
            if (!is_numeric($idx)) {
                continue;
            }
            $this->set_dttot_flag($idx, 'N');
            $set_no++;
        }

        session(['dttot_screening_result' => [
            'set_yes' => $set_yes,
            'set_no' => $set_no,
        ]]);

        return redirect(url('/mc-dttot/screening'));
    }

    // =========================================================================================
    // HELPERS
    // =========================================================================================
    private function set_dttot_flag($idx_partner, $flag)
    {
        // ** Param sequence must refer to param sequence in USP_GN_Partner_SetDTTOT **
        $param = [];
        $param['IDX_M_Partner'] = $idx_partner;
        $param['IsDTTOT'] = 'XXX' . $flag;
        $param['UserID'] = 'XXX' . $this->data['user_id'];

        $this->exec_sp('USP_GN_Partner_SetDTTOT', $param, 'list', 'sqlsrv');
    }

    private function existing_count()
    {
        $rows = DB::connection('sqlsrv')->select("SELECT COUNT(*) AS TotalRows FROM GN_M_DTTOT WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A'");

        foreach ($rows as $row) {
            return (int) $row->TotalRows;
        }

        return 0;
    }

    private function parse_date_text($value)
    {
        // Tanggal lahir di file sumber bervariasi: serial date Excel,
        // teks tanggal, atau teks bebas ("01/07/1974 atau 01/01/1973").
        // Disimpan sebagai teks apa adanya, serial date dikonversi dd/mm/yyyy.
        if (is_numeric($value) && $value > 25569) {
            try {
                return ExcelDate::excelToDateTimeObject($value)->format('d/m/Y');
            } catch (\Exception $e) {
                return trim((string) $value);
            }
        }

        return trim((string) $value);
    }

    private function esc($value)
    {
        // exec_sp merangkai parameter ke string EXEC; gandakan kutip tunggal
        // agar teks seperti O'Brien tidak memutus statement SQL
        return str_replace("'", "''", $value);
    }
}
