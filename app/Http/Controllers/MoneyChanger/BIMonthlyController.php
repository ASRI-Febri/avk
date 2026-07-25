<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

/**
 * Laporan Bulanan Bank Indonesia form B0001 (Laporan Kegiatan Usaha Bulanan PVA).
 * Alur: pilih periode -> preview angka hasil hitung sistem (bisa dikoreksi) ->
 * simpan ke MC_T_BIMonthly -> download file txt untuk diupload ke website BI.
 *
 * Format txt mengikuti formula kolom M template Excel BI (77upd5):
 *   Header : sandi(9) + 'M' + tahun(4) + bulan(2) + '01' + 'B0001' + jumlah record(9)
 *   Detail : valuta(3) + produk(1) + 7 angka x 15 digit + kurs x 10000 (9) + saldo akhir Rp (15)
 *   Nama file: {tahun}{bulan}0001.txt, pemisah baris LF+CR (sesuai output Excel BI)
 */
class BIMonthlyController extends MyController
{
    const SANDI_PELAPOR = '777249834';
    const FORM_CODE = 'B0001';
    const REPORT_NO = '01';

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

        $this->data['form_title'] = 'Laporan Bulanan BI';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'Laporan Bulanan BI');

        parent::__construct($request);
    }

    protected function period_desc($period)
    {
        if (strlen($period) != 6) {
            return $period;
        }

        $year = substr($period, 0, 4);
        $month = substr($period, 4, 2);

        return isset($this->month_names[$month]) ? $this->month_names[$month] . ' ' . $year : $period;
    }

    // =========================================================================================
    // STEP 1: FORM PILIH PERIODE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Laporan Bulanan BI (Form B0001)';
        $this->data['form_remark'] = 'Pilih bulan dan tahun periode laporan. Angka diambil dari hasil Perhitungan HPP
            periode tersebut (saldo awal, pembelian, penjualan, saldo akhir per jenis valuta) sehingga konsisten
            dengan closing bulanan, jurnal, neraca, dan laba rugi. Proses Perhitungan HPP terlebih dahulu sebelum
            membuat laporan ini. Angka bisa dikoreksi sebelum disimpan, lalu file txt di-download untuk diupload
            ke website Bank Indonesia.';
        $this->data['state'] = 'create';

        array_push($this->data['breads'], 'Periode');

        if ($access == TRUE) {
            $this->data['dd_month'] = $this->month_names;

            $years = [];
            for ($y = (int) date('Y'); $y >= (int) date('Y') - 5; $y--) {
                $years[$y] = $y;
            }
            $this->data['dd_year'] = $years;

            // DEFAULT: BULAN LALU (LAPORAN BULANAN DIBUAT SETELAH BULAN BERAKHIR)
            $this->data['PeriodMonth'] = date('m', strtotime('first day of last month'));
            $this->data['PeriodYear'] = date('Y', strtotime('first day of last month'));

            $this->data['url_preview'] = url('mc-bi-monthly/preview');

            $this->data['view'] = 'money_changer/bi_monthly_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // STEP 2: PREVIEW / EDIT GRID
    // =========================================================================================
    public function preview(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PeriodMonth' => ['required', 'regex:/^(0[1-9]|1[0-2])$/'],
            'PeriodYear' => ['required', 'regex:/^\d{4}$/'],
        ], [
            'PeriodMonth.required' => 'Bulan belum dipilih!',
            'PeriodMonth.regex' => 'Bulan tidak valid!',
            'PeriodYear.required' => 'Tahun belum dipilih!',
            'PeriodYear.regex' => 'Tahun tidak valid!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('PeriodYear') . $request->input('PeriodMonth');
        $recalc = $request->input('recalc', '0') == '1';

        // SUMBER DATA: TERSIMPAN (BILA ADA) ATAU HITUNG DARI TRANSAKSI
        $saved = $this->get_saved_rows($period);
        $has_saved = count($saved) > 0;

        $this->data['has_cogs'] = null;

        if ($has_saved && !$recalc) {
            $this->data['records'] = $saved;
            $this->data['source'] = 'saved';
        } else {
            $param['ReportPeriod'] = 'XXX' . $period;
            $this->data['records'] = $this->exec_sp('USP_MC_BIMonthly_Preview', $param, 'list', 'sqlsrv');
            $this->data['source'] = 'computed';

            // STATUS SUMBER: 1 = angka dari hasil HPP periode ini (konsisten neraca/LR)
            foreach ($this->data['records'] as $row) {
                $this->data['has_cogs'] = (int) $row->HasCOGS;
                break;
            }
        }

        $this->data['form_sub_title'] = 'Preview Laporan Bulanan BI';
        $this->data['ReportPeriod'] = $period;
        $this->data['PeriodDesc'] = $this->period_desc($period);
        $this->data['has_saved'] = $has_saved;
        $this->data['txt_name'] = $this->txt_filename($period);

        $this->data['url_save'] = url('mc-bi-monthly/save');
        $this->data['url_preview'] = url('mc-bi-monthly/preview');
        $this->data['url_download'] = url('mc-bi-monthly/download') . '?ReportPeriod=' . $period;
        $this->data['url_cancel'] = url('mc-bi-monthly');

        $this->data['result'] = session('bi_monthly_result');
        session()->forget('bi_monthly_result');

        array_push($this->data['breads'], 'Preview');

        $this->data['view'] = 'money_changer/bi_monthly_preview';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // STEP 3: SIMPAN GRID (REPLACE PERIODE)
    // =========================================================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ReportPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'ReportPeriod.required' => 'Periode belum diisi!',
            'ReportPeriod.regex' => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('ReportPeriod');
        $rows = (array) $request->input('rows', []);

        // HAPUS DATA PERIODE LALU SIMPAN ULANG BARIS YANG DICENTANG
        $param_clear['ReportPeriod'] = 'XXX' . $period;
        $this->exec_sp('USP_MC_BIMonthly_Clear', $param_clear, 'list', 'sqlsrv');

        $total = 0;
        foreach ($rows as $row) {
            if (empty($row['include']) || empty($row['CurrencyID'])) {
                continue;
            }

            $currency = strtoupper(substr(trim($row['CurrencyID']), 0, 3));
            if (!preg_match('/^[A-Z]{3}$/', $currency)) {
                continue;
            }

            // ** Param sequence must refer to param sequence in USP_MC_BIMonthly_Save **
            $param = [];
            $param['ReportPeriod'] = 'XXX' . $period;
            $param['CurrencyID'] = 'XXX' . $currency;
            $param['ProductType'] = 'XXX' . '1';
            $param['OpeningForeign'] = $this->num($row['OpeningForeign'] ?? 0);
            $param['OpeningIDR'] = $this->num($row['OpeningIDR'] ?? 0);
            $param['BuyForeign'] = $this->num($row['BuyForeign'] ?? 0);
            $param['BuyIDR'] = $this->num($row['BuyIDR'] ?? 0);
            $param['SellForeign'] = $this->num($row['SellForeign'] ?? 0);
            $param['SellIDR'] = $this->num($row['SellIDR'] ?? 0);
            $param['MiddleRate'] = $this->num($row['MiddleRate'] ?? 0);
            $param['UserID'] = 'XXX' . $this->data['user_id'];

            $this->exec_sp('USP_MC_BIMonthly_Save', $param, 'list', 'sqlsrv');
            $total++;
        }

        session(['bi_monthly_result' => [
            'saved' => $total,
        ]]);

        // KEMBALI KE PREVIEW (MENAMPILKAN DATA TERSIMPAN + TOMBOL DOWNLOAD)
        return redirect(url('/mc-bi-monthly/edit') . '?ReportPeriod=' . $period);
    }

    // =========================================================================================
    // EDIT: TAMPILKAN KEMBALI DATA TERSIMPAN (GET, DIPAKAI SETELAH SAVE)
    // =========================================================================================
    public function edit(Request $request)
    {
        $period = $request->input('ReportPeriod', '');

        if (!preg_match('/^\d{6}$/', $period)) {
            return redirect(url('/mc-bi-monthly'));
        }

        $request->merge([
            'PeriodYear' => substr($period, 0, 4),
            'PeriodMonth' => substr($period, 4, 2),
            'recalc' => '0',
        ]);

        return $this->preview($request);
    }

    // =========================================================================================
    // STEP 4: DOWNLOAD FILE TXT
    // =========================================================================================
    public function download(Request $request)
    {
        $period = $request->input('ReportPeriod', '');

        if (!preg_match('/^\d{6}$/', $period)) {
            return redirect(url('/mc-bi-monthly'));
        }

        $rows = $this->get_saved_rows($period);

        if (count($rows) == 0) {
            session(['bi_monthly_result' => ['error' => 'Belum ada data tersimpan untuk periode ini. Simpan data terlebih dahulu.']]);
            return redirect(url('/mc-bi-monthly/edit') . '?ReportPeriod=' . $period);
        }

        $content = $this->build_txt($period, $rows);
        $filename = $this->txt_filename($period);

        return response($content, 200, [
            'Content-Type' => 'text/plain; charset=us-ascii',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ]);
    }

    // =========================================================================================
    // GENERATOR TXT (FORMAT B0001, IDENTIK DENGAN OUTPUT EXCEL BI)
    // =========================================================================================
    private function build_txt($period, $rows)
    {
        // Pemisah baris LF+CR (0A 0D) sesuai byte hasil generate Excel BI.
        $eol = "\n\r";

        $year = substr($period, 0, 4);
        $month = substr($period, 4, 2);

        // HEADER: sandi(9) + M + tahun(4) + bulan(2) + no laporan(2) + form(5) + record(9)
        $header = str_pad(self::SANDI_PELAPOR, 9, '0', STR_PAD_LEFT)
            . 'M' . $year . $month . self::REPORT_NO . self::FORM_CODE
            . str_pad((string) count($rows), 9, '0', STR_PAD_LEFT);

        $lines = [$header];

        foreach ($rows as $row) {
            // DETAIL: valuta(3) + produk(1) + 7 x 15 digit + kurs x 10000 (9) + saldo akhir Rp (15)
            $lines[] = str_pad(substr(trim($row->CurrencyID) . '   ', 0, 3), 3)
                . substr(trim($row->ProductType) . ' ', 0, 1)
                . $this->pad15($row->OpeningForeign)
                . $this->pad15($row->OpeningIDR)
                . $this->pad15($row->BuyForeign)
                . $this->pad15($row->BuyIDR)
                . $this->pad15($row->SellForeign)
                . $this->pad15($row->SellIDR)
                . $this->pad15($row->ClosingForeign)
                . str_pad((string) round($row->MiddleRate * 10000), 9, '0', STR_PAD_LEFT)
                . $this->pad15($row->ClosingIDR);
        }

        return implode($eol, $lines) . $eol;
    }

    private function pad15($value)
    {
        return str_pad((string) round((float) $value), 15, '0', STR_PAD_LEFT);
    }

    private function txt_filename($period)
    {
        // Formula M3 template BI: tahun(4) + bulan(2) + RIGHT("0001",4)
        return $period . substr(self::FORM_CODE, 1) . '.txt';
    }

    // =========================================================================================
    // HELPERS
    // =========================================================================================
    private function get_saved_rows($period)
    {
        $param['ReportPeriod'] = 'XXX' . $period;
        return (array) $this->exec_sp('USP_MC_BIMonthly_List', $param, 'list', 'sqlsrv');
    }

    private function num($value)
    {
        $value = str_replace(',', '', trim((string) $value));
        return is_numeric($value) ? (float) $value : 0;
    }
}
