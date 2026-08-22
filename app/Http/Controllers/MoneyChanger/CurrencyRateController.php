<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\MyController;

/**
 * Update Kurs — satu layar untuk mengubah Rate Beli/Jual seluruh mata uang.
 *
 * Nilai baru ditulis ke master MC_M_Currency, sedangkan nilai sebelumnya
 * dipindahkan ke MC_T_CurrencyRateHistory oleh USP_MC_CurrencyRate_Save,
 * sehingga kurs yang berlaku saat transaksi lama dibuat tetap bisa ditelusuri.
 * Baris yang rate-nya tidak diubah dilewati, bukan ditulis ulang.
 */
class CurrencyRateController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'Update Kurs';

        $this->data['form_title'] = 'Update Kurs';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'Update Kurs');

        // URL
        $this->data['url_save'] = url('/mc-currency-rate/save');
        $this->data['url_cancel'] = url('/mc-currency-rate');

        parent::__construct($request);
    }

    // =========================================================================================
    // FORM UPDATE KURS (semua mata uang dalam satu layar)
    // =========================================================================================
    public function edit(Request $request)
    {
        $this->data['form_sub_title'] = 'Update Rate Beli / Rate Jual';
        $this->data['form_remark'] = 'Ubah rate yang perlu diperbarui lalu simpan. '
            . 'Rate lama otomatis tersimpan sebagai riwayat.';

        $this->data['records'] = $this->currency_records();
        $this->data['history'] = $this->history_records(0, 30);
        $this->data['result'] = session('currency_rate_result');

        $this->data['view'] = 'money_changer/currency_rate_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SIMPAN: master diperbarui, nilai lama masuk riwayat (di dalam stored procedure)
    // =========================================================================================
    public function save(Request $request)
    {
        $idx_list  = (array) $request->input('IDX_M_Currency', []);
        $buy_list  = (array) $request->input('BuyRate', []);
        $sell_list = (array) $request->input('SellRate', []);

        // Rate saat form dibuka, dipakai untuk mendeteksi kurs yang berubah di
        // database saat form masih terbuka (mis. import kurs berjalan bersamaan).
        $buy_awal  = (array) $request->input('BuyRateAwal', []);
        $sell_awal = (array) $request->input('SellRateAwal', []);

        $tersimpan = [];
        $tidak_berubah = 0;
        $gagal = [];
        $bentrok = [];

        $master = [];
        foreach ($this->currency_records() as $row) {
            $master[(int) $row->IDX_M_Currency] = $row;
        }

        foreach ($idx_list as $i => $idx) {
            $idx = (int) $idx;

            if ($idx === 0 || !isset($master[$idx])) {
                continue;
            }

            $kode = trim($master[$idx]->CurrencyID);
            $buy  = $this->num($buy_list[$i] ?? '');
            $sell = $this->num($sell_list[$i] ?? '');

            if ($buy === null || $sell === null) {
                $gagal[] = $kode . ': rate harus berupa angka.';
                continue;
            }

            if ($buy < 0 || $sell < 0) {
                $gagal[] = $kode . ': rate tidak boleh negatif.';
                continue;
            }

            // Yang tidak disentuh operator tidak perlu diproses sama sekali.
            $buy_lama  = (float) $master[$idx]->BuyRate;
            $sell_lama = (float) $master[$idx]->SellRate;

            if ($this->sama($buy, $buy_lama) && $this->sama($sell, $sell_lama)) {
                $tidak_berubah++;
                continue;
            }

            // Nilai di database sudah berbeda dari yang tampil saat form dibuka:
            // perubahan orang lain tidak boleh tertimpa diam-diam.
            $buy_form  = $this->num($buy_awal[$i] ?? '');
            $sell_form = $this->num($sell_awal[$i] ?? '');

            if ($buy_form !== null && $sell_form !== null
                && (!$this->sama($buy_form, $buy_lama) || !$this->sama($sell_form, $sell_lama))) {
                $bentrok[] = $kode;
                continue;
            }

            $param = [
                'IDX_M_Currency' => $idx,
                'BuyRate'        => $buy,
                'SellRate'       => $sell,
                'ChangeSource'   => 'XXXMANUAL',
                'UserID'         => 'XXX' . $this->data['user_id'],
            ];

            $res = $this->exec_sp('[dbo].[USP_MC_CurrencyRate_Save]', $param, 'list', 'sqlsrv');
            $hasil = !empty($res) ? trim($res[0]->Result ?? '') : 'error';

            if ($hasil === 'success') {
                $tersimpan[] = [
                    'CurrencyID'  => $kode,
                    'OldBuyRate'  => $buy_lama,
                    'OldSellRate' => $sell_lama,
                    'NewBuyRate'  => $buy,
                    'NewSellRate' => $sell,
                ];
            } elseif ($hasil === 'nochange') {
                $tidak_berubah++;
            } else {
                $gagal[] = $kode . ': ' . (!empty($res) ? trim($res[0]->LogDesc ?? 'gagal disimpan.') : 'gagal disimpan.');
            }
        }

        return redirect('/mc-currency-rate')->with('currency_rate_result', [
            'tersimpan'     => $tersimpan,
            'tidak_berubah' => $tidak_berubah,
            'gagal'         => $gagal,
            'bentrok'       => $bentrok,
        ]);
    }

    // =========================================================================================
    // RIWAYAT SATU MATA UANG (dibuka dari layar update kurs)
    // =========================================================================================
    public function history(Request $request, $id = 0)
    {
        $this->data['form_sub_title'] = 'Riwayat Perubahan Kurs';
        $this->data['form_remark'] = 'Daftar perubahan Rate Beli/Jual beserta nilai sebelum dan sesudahnya.';

        array_push($this->data['breads'], 'Riwayat');

        $this->data['records'] = [];
        $this->data['history'] = $this->history_records((int) $id, 200);
        $this->data['currency'] = null;

        foreach ($this->currency_records() as $row) {
            if ((int) $row->IDX_M_Currency === (int) $id) {
                $this->data['currency'] = $row;
            }
        }

        $this->data['view'] = 'money_changer/currency_rate_history';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // HELPER
    // =========================================================================================
    // Mata uang aktif beserta rate yang sedang berlaku, urut sesuai display kurs.
    private function currency_records()
    {
        return DB::connection('sqlsrv')->select("
            SELECT
                 CU.IDX_M_Currency
                ,CurrencyID   = RTRIM(ISNULL(CU.CurrencyID,''))
                ,CurrencyName = RTRIM(ISNULL(CU.CurrencyName,''))
                ,CountryName  = RTRIM(ISNULL(CO.CountryName,''))
                ,IconFlag     = RTRIM(ISNULL(CU.IconFlag,''))
                ,BuyRate      = ISNULL(CU.BuyRate,0)
                ,SellRate     = ISNULL(CU.SellRate,0)
                ,CU.DModified
                ,UModified    = RTRIM(ISNULL(CU.UModified,''))
            FROM MC_M_Currency CU WITH(NOLOCK)
                LEFT JOIN GN_M_Country CO WITH(NOLOCK) ON CO.IDX_M_Country = CU.IDX_M_Country
            WHERE ISNULL(CU.Recordstatus,'A') = 'A'
            ORDER BY ISNULL(CU.SortPriority,0), CU.CurrencyID
        ");
    }

    private function history_records($idx_currency = 0, $row = 30)
    {
        $param['IDX_M_Currency'] = (int) $idx_currency;
        $param['Row'] = (int) $row;

        return (array) $this->exec_sp('[dbo].[USP_MC_CurrencyRate_History_List]', $param, 'list', 'sqlsrv');
    }

    // Angka boleh diketik 18.000,50 / 18,000.50 / 18000.5; yang tidak berbentuk
    // angka dikembalikan null supaya ditolak, bukan diam-diam jadi 0.
    private function num($value)
    {
        $value = trim((string) $value);

        if ($value === '') {
            return null;
        }

        $koma = strrpos($value, ',');
        $titik = strrpos($value, '.');

        if ($koma !== false && ($titik === false || $koma > $titik)) {
            // Gaya Indonesia: 18.000,50
            $value = str_replace('.', '', $value);
            $value = str_replace(',', '.', $value);
        } elseif ($koma === false && preg_match('/^\d{1,3}(\.\d{3})+$/', $value)) {
            // 18.000 tanpa desimal: titik di sini pemisah ribuan, bukan desimal
            $value = str_replace('.', '', $value);
        } else {
            $value = str_replace(',', '', $value);
        }

        return is_numeric($value) ? (float) $value : null;
    }

    // Perbandingan pada ketelitian kolom rate (decimal 18,4).
    private function sama($a, $b)
    {
        return abs($a - $b) < 0.00005;
    }
}
