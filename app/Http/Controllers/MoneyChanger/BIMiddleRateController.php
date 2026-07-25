<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use App\Imports\BIKursImport;
use Maatwebsite\Excel\Facades\Excel;

/**
 * Kurs tengah Bank Indonesia per akhir bulan.
 * Upload file Excel "Kurs Transaksi" hasil download website BI, sistem
 * menghitung kurs tengah = (kurs jual + kurs beli) / 2 dan menyimpannya
 * per tanggal akhir bulan yang dipilih user. Data ini menjadi sumber kurs
 * pada Laporan Bulanan BI (form B0001).
 */
class BIMiddleRateController extends MyController
{
    protected $month_names = [
        '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
        '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
        '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
    ];

    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'AVK';

        $this->data['form_title'] = 'Kurs Tengah BI';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'Kurs Tengah BI');

        // URL
        $this->data['url_cancel'] = url('mc-bi-middle-rate');

        parent::__construct($request);
    }

    protected function period_dropdown()
    {
        $this->data['dd_month'] = $this->month_names;

        $years = [];
        for ($y = (int) date('Y'); $y >= (int) date('Y') - 5; $y--) {
            $years[$y] = $y;
        }
        $this->data['dd_year'] = $years;
    }

    // =========================================================================================
    // STEP 1: FORM UPLOAD + DAFTAR KURS TERSIMPAN
    // =========================================================================================
    public function upload(Request $request)
    {
        $this->data['form_sub_title'] = 'Upload Kurs Tengah BI (Akhir Bulan)';

        array_push($this->data['breads'], 'Upload');

        $this->period_dropdown();

        // DEFAULT: BULAN LALU (KURS AKHIR BULAN UNTUK LAPORAN BULANAN)
        $this->data['PeriodMonth'] = date('m', strtotime('first day of last month'));
        $this->data['PeriodYear'] = date('Y', strtotime('first day of last month'));

        $this->data['state'] = 'upload';
        $this->data['preview'] = null;
        $this->data['result'] = session('bi_rate_result');
        session()->forget('bi_rate_result');

        // KURS TERSIMPAN: TANGGAL YANG DIMINTA (?ViewDate=) ATAU TERBARU
        $view_date = $request->input('ViewDate', '');
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $view_date)) {
            $view_date = '';
        }

        $param['RateDate'] = 'XXX' . $view_date;
        $this->data['saved_rates'] = (array) $this->exec_sp('USP_MC_BIMiddleRate_List', $param, 'list', 'sqlsrv');

        $this->data['saved_dates'] = (array) DB::connection('sqlsrv')->select("
            SELECT RateDate, COUNT(*) AS TotalCurrency, MAX(RTRIM(ISNULL([FileName],''))) AS [FileName]
            FROM MC_T_BIMiddleRate
            WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A'
            GROUP BY RateDate
            ORDER BY RateDate DESC
        ");

        $this->data['view'] = 'money_changer/bi_middle_rate';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 2: PREVIEW (VALIDASI TANPA SIMPAN)
    // =========================================================================================
    public function preview(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PeriodMonth' => ['required', 'regex:/^(0[1-9]|1[0-2])$/'],
            'PeriodYear' => ['required', 'regex:/^\d{4}$/'],
            'file_import' => 'required|file',
        ], [
            'PeriodMonth.required' => 'Bulan belum dipilih!',
            'PeriodYear.required' => 'Tahun belum dipilih!',
            'file_import.required' => 'File Excel belum dipilih!',
        ]);

        $this->data['form_sub_title'] = 'Preview Kurs Tengah BI';
        $this->data['result'] = null;

        array_push($this->data['breads'], 'Preview');

        $this->period_dropdown();
        $this->data['saved_rates'] = [];
        $this->data['saved_dates'] = [];

        if ($validator->fails()) {
            $this->data['state'] = 'upload';
            $this->data['preview'] = null;
            $this->data['error'] = implode(' ', $validator->errors()->all());
            $this->data['PeriodMonth'] = $request->input('PeriodMonth', date('m'));
            $this->data['PeriodYear'] = $request->input('PeriodYear', date('Y'));

            $this->data['view'] = 'money_changer/bi_middle_rate';
            return view($this->data['view'], $this->data);
        }

        // TANGGAL AKHIR BULAN DARI PERIODE YANG DIPILIH USER
        $rate_date = date('Y-m-t', strtotime($request->input('PeriodYear') . '-' . $request->input('PeriodMonth') . '-01'));
        $file_name = $request->file('file_import')->getClientOriginalName();

        // BACA FILE (tanpa heading row; kolom file BI tetap:
        // 0=NO, 1=Mata Uang, 2=Nilai, 3=Kurs Jual, 4=Kurs Beli)
        $import = new BIKursImport;
        Excel::import($import, $request->file('file_import'));
        $rows = $import->rows ?? collect();

        $preview = [];
        $valid_rows = [];
        $title_date = '';

        foreach ($rows as $i => $row) {
            $cells = $row->toArray();

            $col_a = trim((string) ($cells[0] ?? ''));
            $currency = strtoupper(trim((string) ($cells[1] ?? '')));

            // TANGGAL DARI JUDUL "Kurs Transaksi 31-Mar-2026" UNTUK CROSS-CHECK
            if ($title_date === '' && stripos($col_a, 'Kurs Transaksi') !== false) {
                $ts = strtotime(trim(str_ireplace('Kurs Transaksi', '', $col_a)));
                if ($ts !== false) {
                    $title_date = date('Y-m-d', $ts);
                }
                continue;
            }

            // HANYA BARIS DATA: MATA UANG 3 HURUF
            if (!preg_match('/^[A-Z]{3}$/', $currency)) {
                continue;
            }

            $unit = (int) $this->num($cells[2] ?? 1);
            $sell = $this->num($cells[3] ?? 0);
            $buy = $this->num($cells[4] ?? 0);

            $errors = [];
            if ($unit <= 0) {
                $errors[] = 'Nilai tidak valid';
            }
            if ($sell <= 0 || $buy <= 0) {
                $errors[] = 'Kurs jual/beli tidak valid';
            }

            $item = [
                'row_no' => $i + 1,
                'CurrencyID' => $currency,
                'RateUnit' => max($unit, 1),
                'SellRate' => $sell,
                'BuyRate' => $buy,
                'MiddleRate' => ($sell + $buy) / 2,
                'errors' => $errors,
            ];

            $preview[] = $item;

            if (count($errors) === 0) {
                $valid_rows[] = $item;
            }
        }

        // SIMPAN BARIS VALID DI SESSION UNTUK STEP SAVE
        session([
            'bi_rate_rows' => $valid_rows,
            'bi_rate_date' => $rate_date,
            'bi_rate_file' => $file_name,
        ]);

        $this->data['state'] = 'preview';
        $this->data['preview'] = $preview;
        $this->data['valid_count'] = count($valid_rows);
        $this->data['error_count'] = count($preview) - count($valid_rows);
        $this->data['file_name'] = $file_name;
        $this->data['RateDate'] = $rate_date;
        $this->data['TitleDate'] = $title_date;
        $this->data['date_mismatch'] = ($title_date !== '' && $title_date !== $rate_date);
        $this->data['existing_count'] = $this->existing_count($rate_date);

        $this->data['view'] = 'money_changer/bi_middle_rate';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 3: SAVE (REPLACE PER TANGGAL)
    // =========================================================================================
    public function save(Request $request)
    {
        $rows = session('bi_rate_rows', []);
        $rate_date = session('bi_rate_date', '');
        $file_name = session('bi_rate_file', '');

        session()->forget(['bi_rate_rows', 'bi_rate_date', 'bi_rate_file']);

        if (empty($rows) || $rate_date === '') {
            session(['bi_rate_result' => [
                'success' => 0, 'failed' => 0, 'date' => '',
                'messages' => ['Tidak ada data untuk disimpan. Upload dan preview ulang file Anda.'],
            ]]);
            return redirect(url('/mc-bi-middle-rate'));
        }

        // KOSONGKAN KURS TANGGAL INI LALU SIMPAN ULANG DARI FILE
        $param_clear['RateDate'] = $rate_date;
        $this->exec_sp('USP_MC_BIMiddleRate_Clear', $param_clear, 'list', 'sqlsrv');

        $success = 0;
        $failed = 0;
        $messages = [];

        foreach ($rows as $item) {
            // ** Param sequence must refer to param sequence in USP_MC_BIMiddleRate_Save **
            $param = [];
            $param['RateDate'] = $rate_date;
            $param['CurrencyID'] = 'XXX' . $item['CurrencyID'];
            $param['RateUnit'] = $item['RateUnit'];
            $param['SellRate'] = $item['SellRate'];
            $param['BuyRate'] = $item['BuyRate'];
            $param['FileName'] = 'XXX' . str_replace("'", "''", $file_name);
            $param['UserID'] = 'XXX' . $this->data['user_id'];

            $result = $this->exec_sp('USP_MC_BIMiddleRate_Save', $param, 'list', 'sqlsrv');

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
                $messages[] = 'Baris ' . $item['row_no'] . ' (' . $item['CurrencyID'] . ') gagal disimpan.';
            }
        }

        session(['bi_rate_result' => [
            'success' => $success,
            'failed' => $failed,
            'date' => $rate_date,
            'messages' => $messages,
        ]]);

        return redirect(url('/mc-bi-middle-rate') . '?ViewDate=' . $rate_date);
    }

    // =========================================================================================
    // HELPERS
    // =========================================================================================
    private function existing_count($rate_date)
    {
        $rows = DB::connection('sqlsrv')->select(
            "SELECT COUNT(*) AS TotalRows FROM MC_T_BIMiddleRate WHERE RateDate = ? AND RTRIM(ISNULL(RecordStatus,'')) = 'A'",
            [$rate_date]
        );

        foreach ($rows as $row) {
            return (int) $row->TotalRows;
        }

        return 0;
    }

    private function num($value)
    {
        $value = str_replace(',', '', trim((string) $value));
        return is_numeric($value) ? (float) $value : 0;
    }
}
