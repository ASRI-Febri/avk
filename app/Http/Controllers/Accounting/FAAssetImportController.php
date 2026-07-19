<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use App\Imports\FAAssetImport;
use App\Exports\FAAssetTemplateExport;
use Maatwebsite\Excel\Facades\Excel;
use PhpOffice\PhpSpreadsheet\Shared\Date as ExcelDate;

/**
 * Import register aset tetap dari Excel (migrasi saldo awal - Fase 5).
 * Alur: upload -> preview tervalidasi per baris -> konfirmasi simpan.
 * Penyimpanan memakai USP_FA_Asset_Create per baris sehingga seluruh
 * validasi bisnis di stored procedure tetap berlaku.
 */
class FAAssetImportController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo']  = url('public/images/logo/accounting.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'ACCOUNTING';
        $this->data['form_title'] = 'Import Aset (Saldo Awal)';
        $this->data['form_remark'] = 'Migrasi register aset tetap lama dari file Excel. '
            . 'Gunakan template yang disediakan; kolom akum_penyusutan_awal diisi akumulasi penyusutan s/d tanggal migrasi.';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Fixed Asset','Import Aset');

        // URL
        $this->data['url_cancel'] = url('ac-fa-asset');

        parent::__construct($request);
    }

    // =========================================================================================
    // STEP 0: DOWNLOAD TEMPLATE
    // =========================================================================================
    public function template()
    {
        return Excel::download(new FAAssetTemplateExport, 'template_import_aset.xlsx');
    }

    // =========================================================================================
    // STEP 1: FORM UPLOAD
    // =========================================================================================
    public function show(Request $request)
    {
        $this->data['form_sub_title'] = 'Upload File';

        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_company'] = (array) $dd->company();

        $this->data['state'] = 'upload';
        $this->data['preview'] = null;
        $this->data['result'] = session('fa_import_result');

        session()->forget('fa_import_result');

        $this->data['view'] = 'accounting/fa_asset_import';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 2: PREVIEW (VALIDASI TANPA SIMPAN)
    // =========================================================================================
    public function preview(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => 'required',
            'file_import' => 'required|file',
        ], [
            'IDX_M_Company.required' => 'Company belum dipilih!',
            'file_import.required' => 'File Excel belum dipilih!',
        ]);

        $this->data['form_sub_title'] = 'Preview Import';

        $dd = new DropdownController;
        $this->data['dd_company'] = (array) $dd->company();
        $this->data['result'] = null;

        if ($validator->fails()) {
            $this->data['state'] = 'upload';
            $this->data['preview'] = null;
            $this->data['error'] = implode(' ', $validator->errors()->all());

            $this->data['view'] = 'accounting/fa_asset_import';
            return view($this->data['view'], $this->data);
        }

        $company_id = $request->input('IDX_M_Company');

        // BACA FILE
        $import = new FAAssetImport;
        Excel::import($import, $request->file('file_import'));
        $rows = $import->rows ?? collect();

        // MASTER UNTUK MAPPING KODE -> IDX
        $categories = $this->map_master("SELECT IDX_M_AssetCategory AS idx, CategoryCode AS code FROM FA_M_AssetCategory WITH(NOLOCK) WHERE RecordStatus = 'A'");
        $branches   = $this->map_master("SELECT IDX_M_Branch AS idx, BranchID AS code FROM GN_M_Branch WITH(NOLOCK) WHERE RecordStatus = 'A'");
        $departments = $this->map_master("SELECT IDX_M_Department AS idx, DepartmentID AS code FROM GN_M_Department WITH(NOLOCK)");

        $preview = [];
        $valid_rows = [];

        foreach ($rows as $i => $row) {
            $errors = [];

            $nama = trim((string) ($row['nama_aset'] ?? ''));
            if ($nama === '') {
                // baris kosong total dilewati tanpa error
                $all_empty = true;
                foreach ($row as $cell) { if (trim((string) $cell) !== '') { $all_empty = false; break; } }
                if ($all_empty) continue;

                $errors[] = 'Nama aset kosong';
            }

            $kategori_code = strtoupper(trim((string) ($row['kategori'] ?? '')));
            $kategori_idx = $categories[$kategori_code] ?? null;
            if ($kategori_idx === null) $errors[] = 'Kategori "' . $kategori_code . '" tidak terdaftar';

            $cabang_code = strtoupper(trim((string) ($row['cabang'] ?? '')));
            $cabang_idx = $branches[$cabang_code] ?? null;
            if ($cabang_idx === null) $errors[] = 'Cabang "' . $cabang_code . '" tidak terdaftar';

            $dept_code = strtoupper(trim((string) ($row['departemen'] ?? '')));
            $dept_idx = 0;
            if ($dept_code !== '') {
                $dept_idx = $departments[$dept_code] ?? null;
                if ($dept_idx === null) $errors[] = 'Departemen "' . $dept_code . '" tidak terdaftar';
            }

            $tgl_perolehan = $this->parse_date($row['tgl_perolehan'] ?? '');
            if ($tgl_perolehan === null) $errors[] = 'Tanggal perolehan tidak valid (format YYYY-MM-DD)';

            $tgl_pakai = $this->parse_date($row['tgl_mulai_pakai'] ?? '');
            if ($tgl_pakai === null) $errors[] = 'Tanggal mulai pakai tidak valid (format YYYY-MM-DD)';

            if ($tgl_perolehan !== null && $tgl_pakai !== null && $tgl_pakai < $tgl_perolehan) {
                $errors[] = 'Tanggal mulai pakai sebelum tanggal perolehan';
            }

            $harga = $this->parse_number($row['harga_perolehan'] ?? 0);
            if ($harga <= 0) $errors[] = 'Harga perolehan harus > 0';

            $residu = $this->parse_number($row['nilai_residu'] ?? 0);
            if ($residu < 0 || ($harga > 0 && $residu >= $harga)) $errors[] = 'Nilai residu tidak valid';

            $umur = (int) $this->parse_number($row['umur_bulan'] ?? 0);
            if ($umur <= 0) $errors[] = 'Umur bulan harus > 0';

            $metode = strtoupper(trim((string) ($row['metode'] ?? 'SL'))) ?: 'SL';
            if (!in_array($metode, ['SL','DB'])) $errors[] = 'Metode harus SL atau DB';

            $fiscal_group = strtoupper(trim((string) ($row['kelompok_fiskal'] ?? '')));
            if ($fiscal_group !== '' && !in_array($fiscal_group, ['1','2','3','4','BP','BN'])) {
                $errors[] = 'Kelompok fiskal harus 1-4 / BP / BN';
            }

            $metode_fiskal = strtoupper(trim((string) ($row['metode_fiskal'] ?? 'SL'))) ?: 'SL';
            if (!in_array($metode_fiskal, ['SL','DB'])) $errors[] = 'Metode fiskal harus SL atau DB';

            $opening = $this->parse_number($row['akum_penyusutan_awal'] ?? 0);
            if ($opening < 0) $errors[] = 'Akum. penyusutan awal tidak boleh negatif';
            if ($harga > 0 && $opening > ($harga - $residu)) {
                $errors[] = 'Akum. penyusutan awal melebihi dasar penyusutan (harga - residu)';
            }

            $item = [
                'row_no'          => $i + 2, // +2: heading row + index mulai 0
                'kode_aset'       => trim((string) ($row['kode_aset'] ?? '')),
                'nama_aset'       => $nama,
                'keterangan'      => trim((string) ($row['keterangan'] ?? '')),
                'kategori'        => $kategori_code,
                'kategori_idx'    => $kategori_idx,
                'cabang'          => $cabang_code,
                'cabang_idx'      => $cabang_idx,
                'dept_idx'        => $dept_idx ?? 0,
                'tgl_perolehan'   => $tgl_perolehan,
                'tgl_mulai_pakai' => $tgl_pakai,
                'harga_perolehan' => $harga,
                'nilai_residu'    => $residu,
                'umur_bulan'      => $umur,
                'metode'          => $metode,
                'kelompok_fiskal' => $fiscal_group,
                'metode_fiskal'   => $metode_fiskal,
                'akum_awal'       => $opening,
                'no_referensi'    => trim((string) ($row['no_referensi'] ?? '')),
                'errors'          => $errors,
            ];

            $preview[] = $item;

            if (count($errors) === 0) {
                $valid_rows[] = $item;
            }
        }

        // SIMPAN BARIS VALID DI SESSION UNTUK STEP SAVE
        session([
            'fa_import_rows' => $valid_rows,
            'fa_import_company' => $company_id,
        ]);

        $this->data['state'] = 'preview';
        $this->data['preview'] = $preview;
        $this->data['valid_count'] = count($valid_rows);
        $this->data['error_count'] = count($preview) - count($valid_rows);
        $this->data['IDX_M_Company'] = $company_id;

        $this->data['view'] = 'accounting/fa_asset_import';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 3: SAVE (INSERT VIA STORED PROCEDURE PER BARIS)
    // =========================================================================================
    public function save(Request $request)
    {
        $rows = session('fa_import_rows', []);
        $company_id = session('fa_import_company');

        session()->forget(['fa_import_rows', 'fa_import_company']);

        if (empty($rows) || empty($company_id)) {
            session(['fa_import_result' => [
                'success' => 0, 'failed' => 0,
                'messages' => ['Tidak ada data untuk disimpan. Upload dan preview ulang file Anda.'],
            ]]);
            return redirect(url('/ac-fa-asset-import'));
        }

        $success = 0;
        $failed = 0;
        $messages = [];

        foreach ($rows as $item) {
            // ** Param sequence must refer to param sequence in USP_FA_Asset_Create **
            $param = [];
            $param['IDX_M_Company'] = $company_id;
            $param['IDX_M_Branch'] = $item['cabang_idx'];
            $param['IDX_M_Department'] = $item['dept_idx'];
            $param['IDX_M_AssetCategory'] = $item['kategori_idx'];
            $param['AssetCode'] = 'XXX' . $this->esc($item['kode_aset']);
            $param['AssetName'] = 'XXX' . $this->esc($item['nama_aset']);
            $param['AssetDesc'] = 'XXX' . $this->esc($item['keterangan']);
            $param['AcquisitionDate'] = 'XXX' . $item['tgl_perolehan'];
            $param['UsageStartDate'] = 'XXX' . $item['tgl_mulai_pakai'];
            $param['AcquisitionCost'] = $item['harga_perolehan'];
            $param['ResidualValue'] = $item['nilai_residu'];
            $param['UsefulLifeMonth'] = $item['umur_bulan'];
            $param['DeprMethod'] = 'XXX' . $item['metode'];
            $param['FiscalGroup'] = 'XXX' . $item['kelompok_fiskal'];
            $param['FiscalDeprMethod'] = 'XXX' . $item['metode_fiskal'];
            $param['IDX_T_PurchaseInvoice'] = 0;
            $param['ReferenceNo'] = 'XXX' . $this->esc($item['no_referensi']);
            $param['AssetStatus'] = 'XXX' . 'A'; // langsung Aktif agar ikut disusutkan
            $param['OpeningAccumDepr'] = $item['akum_awal'];
            $param['UserID'] = 'XXX' . $this->data['user_id'];
            $param['RecordStatus'] = 'XXX' . 'A';

            $result = $this->exec_sp('[dbo].[USP_FA_Asset_Create]', $param, 'list', 'sqlsrv');

            $ok = false;
            foreach ($result as $r) {
                if (isset($r->Result) && strtolower(trim($r->Result)) === 'success') {
                    $ok = true;
                } elseif (isset($r->LogDesc)) {
                    $messages[] = 'Baris ' . $item['row_no'] . ' (' . $item['nama_aset'] . '): ' . trim($r->LogDesc);
                }
            }

            if ($ok) { $success++; } else { $failed++; }
        }

        session(['fa_import_result' => [
            'success' => $success,
            'failed' => $failed,
            'messages' => $messages,
        ]]);

        return redirect(url('/ac-fa-asset-import'));
    }

    // =========================================================================================
    // HELPERS
    // =========================================================================================
    private function map_master($sql)
    {
        $map = [];
        foreach (DB::connection('sqlsrv')->select($sql) as $row) {
            $map[strtoupper(trim($row->code))] = trim($row->idx);
        }
        return $map;
    }

    private function parse_date($value)
    {
        if (is_numeric($value) && $value > 25569) {
            // Excel serial date
            try {
                return ExcelDate::excelToDateTimeObject($value)->format('Y-m-d');
            } catch (\Exception $e) {
                return null;
            }
        }

        $value = trim((string) $value);
        if ($value === '') return null;

        $ts = strtotime($value);
        return $ts === false ? null : date('Y-m-d', $ts);
    }

    private function parse_number($value)
    {
        $value = str_replace(',', '', trim((string) $value));
        return is_numeric($value) ? (float) $value : -1;
    }

    private function esc($value)
    {
        // exec_sp merangkai parameter ke string EXEC; gandakan kutip tunggal
        // agar teks seperti O'Brien tidak memutus statement SQL
        return str_replace("'", "''", $value);
    }
}
