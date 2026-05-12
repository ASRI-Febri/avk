<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Http\Request;
use App\Http\Controllers\MyController;
use App\Services\OcrService;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;

/**
 * NotaScanController
 *
 * Menangani upload gambar nota jual/beli, pemrosesan OCR via Anthropic Claude,
 * serta penyimpanan hasil ekstraksi ke tabel header dan detail.
 *
 * Stored Procedures yang dibutuhkan (buat di SQL Server):
 * -------------------------------------------------------
 *
 * -- Header
 * CREATE TABLE T_MC_NotaScan (
 *   IDX_T_MC_NotaScan   INT IDENTITY(1,1) PRIMARY KEY,
 *   TipeTransaksi       CHAR(1)       NOT NULL,   -- J=Jual, B=Beli
 *   TanggalNota         DATE,
 *   NoNota              VARCHAR(100),
 *   Keterangan          VARCHAR(500),
 *   FileName            VARCHAR(255),
 *   FilePath            VARCHAR(1000),
 *   OCRRawText          NVARCHAR(MAX),
 *   Status              CHAR(1)       NOT NULL DEFAULT 'D',  -- D=Draft
 *   RecordStatus        CHAR(1)       NOT NULL DEFAULT 'A',
 *   UCreate             VARCHAR(50),
 *   DCreate             DATETIME,
 *   UModified           VARCHAR(50),
 *   DModified           DATETIME
 * )
 *
 * -- Detail
 * CREATE TABLE T_MC_NotaScanDetail (
 *   IDX_T_MC_NotaScanDetail  INT IDENTITY(1,1) PRIMARY KEY,
 *   IDX_T_MC_NotaScan        INT NOT NULL,
 *   Nomor                    INT,
 *   KeteranganValas          VARCHAR(100),
 *   NilaiValas               DECIMAL(18,2),
 *   NilaiTukar               DECIMAL(18,4),
 *   TotalNilai               DECIMAL(18,2),
 *   UCreate                  VARCHAR(50),
 *   DCreate                  DATETIME,
 *   FOREIGN KEY (IDX_T_MC_NotaScan) REFERENCES T_MC_NotaScan(IDX_T_MC_NotaScan)
 * )
 *
 * -- USP_MC_NotaScan_Save (@IDX_T_MC_NotaScan, @TipeTransaksi, @TanggalNota,
 *      @NoNota, @Keterangan, @FileName, @FilePath, @OCRRawText, @UserID)
 *   Returns: Result (success/error), ID (new IDX), LogDesc
 *
 * -- USP_MC_NotaScan_Info (@IDX)
 *   Returns: single record T_MC_NotaScan
 *
 * -- USP_MC_NotaScan_List (@page, @row, @sort_by, @sort_dir, @return_type,
 *      @SearchText, @TipeTransaksi, @DateFrom, @DateTo)
 *   Returns: list + TotalRows untuk DataTables
 *
 * -- USP_MC_NotaScanDetail_Save (@IDX_T_MC_NotaScan, @IDX_T_MC_NotaScanDetail,
 *      @Nomor, @KeteranganValas, @NilaiValas, @NilaiTukar, @TotalNilai, @UserID)
 *   Returns: Result (success/error), ID
 *
 * -- USP_MC_NotaScanDetail_List (@IDX_T_MC_NotaScan)
 *   Returns: list detail rows
 *
 * -- USP_MC_NotaScanDetail_Delete (@IDX_T_MC_NotaScanDetail, @UserID)
 *   Returns: Result, LogDesc
 *
 * -- USP_MC_NotaScanDetail_DeleteAll (@IDX_T_MC_NotaScan, @UserID)
 *   Hapus semua detail sebelum re-insert (dipakai saat update)
 */
class NotaScanController extends MyController
{
    public $sp_getinquiry = 'USP_MC_NotaScan_List';

    public $array_column = [
        'RowNumber', 'TipeTransaksi', 'TanggalNota',
        'NoNota', 'Keterangan', 'FileName', 'StatusDesc', 'Action',
    ];

    public $array_filter = ['SearchText', 'TipeTransaksi', 'DateFrom', 'DateTo'];

    public function __construct(Request $request)
    {
        $this->data['logo']           = 'Money Changer';
        $this->data['form_title']     = 'Scan Nota';
        $this->data['form_sub_title'] = 'OCR Nota Jual / Beli Valas';
        $this->data['navbar']         = 'navigation.navbar_money_changer';
        $this->data['sidebar']        = 'navigation.sidebar_money_changer';
        $this->data['breads']         = ['Transaksi', 'Scan Nota'];
        $this->data['url_create']     = url('mc-nota-scan/create');
        $this->data['url_inquiry']    = url('mc-nota-scan');
        $this->data['url_search']     = url('mc-nota-scan-list');

        parent::__construct($request);
    }

    // ============================================================
    // LIST
    // ============================================================
    public function inquiry()
    {
        $this->data['table_header'] = [
            '#', 'Tipe', 'Tanggal Nota', 'No Nota', 'Keterangan', 'File', 'Status', 'Action',
        ];
        $this->data['table_footer']  = ['', '', '', '', '', '', '', ''];
        $this->data['form_remark']   = 'Daftar nota yang sudah di-scan dan diproses OCR.';
        $this->data['array_filter']  = $this->array_filter;

        return view('money_changer.nota_scan_list', $this->data);
    }

    public function inquiry_data(Request $request)
    {
        $this->array_filter = [
            $request->input('SearchText', ''),
            $request->input('TipeTransaksi', ''),
            $request->input('DateFrom', ''),
            $request->input('DateTo', ''),
        ];

        $this->get_datatables($request);
    }

    // ============================================================
    // CREATE FORM
    // ============================================================
    public function create()
    {
        $fields = (object)[
            'IDX_T_MC_NotaScan' => 0,
            'TipeTransaksi'     => '',
            'TanggalNota'       => date('Y-m-d'),
            'NoNota'            => '',
            'NamaKonsumen'      => '',
            'NoKTP'             => '',
            'NoTelp'            => '',
            'SumberDana'        => '',
            'TujuanTransaksi'   => '',
            'Keterangan'        => '',
            'FileName'          => '',
            'FilePath'          => '',
            'OCRRawText'        => '',
            'Status'            => 'D',
            'RecordStatus'      => 'A',
        ];

        $this->data['state']           = 'create';
        $this->data['fields']          = $fields;
        $this->data['records_detail']  = [];
        $this->data['url_save_header'] = url('mc-nota-scan/save');

        $dd = new DropdownFinanceController;        
        $this->data['dd_tipe'] = (array) $dd->transaction_type();

        // $this->data['dd_tipe']         = [
        //     ['value' => 'J', 'text' => 'Jual (SO)'],
        //     ['value' => 'B', 'text' => 'Beli (PO)'],
        // ];

        return view('money_changer.nota_scan_form', $this->data);
    }

    // ============================================================
    // UPDATE FORM
    // ============================================================
    public function update($id)
    {
        $param['IDX'] = $id;
        $records = $this->exec_sp('USP_MC_NotaScan_Info', $param, 'list');

        if (empty($records)) {
            return redirect($this->data['url_inquiry']);
        }

        $fields = $records[0];

        $param_detail['IDX_T_MC_NotaScan'] = $id;
        $records_detail = $this->exec_sp('USP_MC_NotaScanDetail_List', $param_detail, 'list');

        $this->data['state']           = 'update';
        $this->data['fields']          = $fields;
        $this->data['records_detail']  = $records_detail;
        $this->data['url_save_header'] = url('mc-nota-scan/save');
        $this->data['dd_tipe']         = [
            ['value' => 'J', 'text' => 'Jual (SO)'],
            ['value' => 'B', 'text' => 'Beli (PO)'],
        ];

        return view('money_changer.nota_scan_form', $this->data);
    }

    // ============================================================
    // SCAN (OCR)
    // Upload gambar → proses OCR → return JSON hasil ekstraksi
    // ============================================================
    public function scan(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ScanFile' => 'required|file|mimes:jpeg,jpg,png,gif,webp|max:10240',
        ], [
            'ScanFile.required' => 'File gambar wajib diupload.',
            'ScanFile.mimes'    => 'Format file harus jpeg, jpg, png, gif, atau webp.',
            'ScanFile.max'      => 'Ukuran file maksimal 10 MB.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'flag'    => 'error',
                'message' => implode('<br>', $validator->errors()->all()),
            ]);
        }

        $file      = $request->file('ScanFile');
        $extension = strtolower($file->getClientOriginalExtension());
        $filename  = 'nota_' . date('YmdHis') . '_' . uniqid() . '.' . $extension;
        $directory = storage_path('app/public/upload-nota-scan');

        if (!File::isDirectory($directory)) {
            File::makeDirectory($directory, 0777, true, true);
        }

        $file->move($directory, $filename);
        $fullPath = $directory . '/' . $filename;

        $ocr    = new OcrService();
        $result = $ocr->extractNotaData($fullPath);

        if (!$result['success']) {
            return response()->json([
                'flag'    => 'error',
                'message' => $result['message'],
            ]);
        }

        return response()->json([
            'flag'      => 'success',
            'data'      => $result['data'],
            'raw'       => $result['raw'],
            'file_name' => $filename,
            'file_path' => $fullPath,
        ]);
    }

    // ============================================================
    // SAVE (Header + Detail)
    // ============================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'TipeTransaksi' => 'required|in:J,B',
            'TanggalNota'   => 'required|date',
        ], [
            'TipeTransaksi.required' => 'Tipe transaksi wajib dipilih.',
            'TipeTransaksi.in'       => 'Tipe transaksi tidak valid.',
            'TanggalNota.required'   => 'Tanggal nota wajib diisi.',
            'TanggalNota.date'       => 'Format tanggal nota tidak valid.',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_MC_NotaScan', 0));
        }

        // Bersihkan karakter yang bisa merusak query SP
        $ocrRawText = str_replace("'", '"', $request->input('OCRRawText', ''));
        // Potong jika terlalu panjang
        if (mb_strlen($ocrRawText) > 4000) {
            $ocrRawText = mb_substr($ocrRawText, 0, 4000);
        }

        // --- Simpan header ---
        $param_header = [
            $request->input('IDX_T_MC_NotaScan', 0),
            $request->input('TipeTransaksi'),
            $request->input('TanggalNota'),
            $request->input('NoNota', ''),
            $request->input('NamaKonsumen', ''),
            $request->input('NoKTP', ''),
            $request->input('NoTelp', ''),
            $request->input('SumberDana', ''),
            $request->input('TujuanTransaksi', ''),
            $request->input('Keterangan', ''),
            $request->input('FileName', ''),
            $request->input('FilePath', ''),
            $ocrRawText,
            'XXX' . $this->data['user_id'],
        ];

        $result_header = $this->exec_sp('USP_MC_NotaScan_Save', $param_header, 'list');

        $flag    = '';
        $new_idx = 0;
        foreach ($result_header as $row) {
            $flag    = $row->Result ?? '';
            $new_idx = $row->ID    ?? 0;
        }

        if (strtolower($flag) !== 'success') {
            $obj = [
                'flag'    => 'error',
                'message' => $this->sweet_alert_message($result_header),
            ];
            echo json_encode($obj);
            return;
        }

        // --- Hapus semua detail lama (re-insert) ---
        $param_del = [
            $new_idx,
            'XXX' . $this->data['user_id'],
        ];
        $this->exec_sp('USP_MC_NotaScanDetail_DeleteAll', $param_del, 'list');

        // --- Simpan detail rows ---
        $details = json_decode($request->input('detail_json', '[]'), true);

        if (is_array($details)) {
            foreach ($details as $detail) {
                $nilaiValas = (float)($detail['nilai_valas'] ?? 0);
                $nilaiTukar = (float)($detail['nilai_tukar'] ?? 0);
                $totalNilai = (float)($detail['total_nilai'] ?? 0);

                if ($totalNilai == 0 && $nilaiValas > 0 && $nilaiTukar > 0) {
                    $totalNilai = $nilaiValas * $nilaiTukar;
                }

                $param_detail = [
                    $new_idx,
                    0,  // IDX_T_MC_NotaScanDetail = 0 karena delete-all dulu
                    (int)($detail['nomor'] ?? 0),
                    $detail['keterangan_valas'] ?? '',
                    $nilaiValas,
                    $nilaiTukar,
                    $totalNilai,
                    $detail['catatan_detail'] ?? '',
                    'XXX' . $this->data['user_id'],
                ];

                $this->exec_sp('USP_MC_NotaScanDetail_Save', $param_detail, 'list');
            }
        }

        $obj = [
            'flag'        => 'success',
            'message'     => '<span>Data berhasil disimpan.</span></div>',
            'id'          => $new_idx,
            'next_action' => 'update',
            'url'         => url('mc-nota-scan/update') . '/' . $new_idx,
        ];

        echo json_encode($obj);
    }
}
