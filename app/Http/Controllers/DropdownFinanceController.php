<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class DropdownFinanceController extends Controller
{
    public function currency($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Currency, CurrencyID, CurrencyName 
                FROM MC_M_Currency 
                WHERE RecordStatus = 'A' ORDER BY CurrencyName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Currency)] = trim($row->CurrencyID) . ' - ' .trim($row->CurrencyName);
        }
        return $value;
    }

    public function valas_change($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_ValasChange, ValasChangeID, ValasChangeName, ValasChangeNumber
                FROM MC_M_ValasChange 
                WHERE RecordStatus = 'A'
                ORDER BY ValasChangeNumber";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_ValasChange)] = trim($row->ValasChangeName);
        }
        return $value;
    }

    public function valas($connection = 'sqlsrv')
    {
        $sql = "SELECT [IDX_M_Valas],MV.[IDX_M_Currency],MV.[IDX_M_ValasChange],[EffectiveDate],
                    MV.ValasSKU, MV.ValasName, 
                    C.CurrencyID, C.CurrencyName, MVC.ValasChangeID, MVC.ValasChangeName,
                    [BuyValue],[SellValue],
                    MV.[UCreate],MV.[DCreate],MV.[UModified],MV.[DModified],MV.[RecordStatus], 
                    StatusDesc = CASE MV.RecordStatus WHEN 'A' THEN 'Active' ELSE 'Inactive' END
                FROM MC_M_Valas MV
                LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
                LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
                WHERE MV.RecordStatus = 'A'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Valas)] = trim($row->CurrencyID) . ' - ' . trim($row->CurrencyName) . ' - ' . trim($row->ValasChangeName);
        }
        return $value;
    }

    /**
     * Daftar valas dalam bentuk terstruktur untuk dropdown pencarian.
     *
     * Berbeda dengan valas() yang memberi satu baris teks gabungan, di sini
     * kode mata uang, namanya, dan pecahannya dipisah supaya tampilannya bisa
     * dikelompokkan per mata uang dan dicari lewat kode, nama, atau SKU.
     */
    public function valas_option($connection = 'sqlsrv')
    {
        $sql = "SELECT MV.IDX_M_Valas, MV.ValasSKU, MV.ValasName,
                    C.CurrencyID, C.CurrencyName,
                    MVC.ValasChangeName, MVC.ValasChangeNumber
                FROM MC_M_Valas MV WITH(NOLOCK)
                    LEFT JOIN MC_M_Currency C WITH(NOLOCK) ON C.IDX_M_Currency = MV.IDX_M_Currency
                    LEFT JOIN MC_M_ValasChange MVC WITH(NOLOCK) ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
                WHERE MV.RecordStatus = 'A'
                    AND RTRIM(ISNULL(C.RecordStatus,'A')) = 'A'
                ORDER BY C.CurrencyID, MVC.ValasChangeNumber";

        $result = DB::connection($connection)->select($sql);

        $rows = [];

        foreach ($result as $row) {
            $rows[] = [
                'id'      => (int) $row->IDX_M_Valas,
                'kode'    => trim($row->CurrencyID ?? ''),
                'mata'    => trim($row->CurrencyName ?? ''),
                'pecahan' => trim($row->ValasChangeName ?? ''),
                'angka'   => (float) ($row->ValasChangeNumber ?? 0),
                'sku'     => trim($row->ValasSKU ?? ''),
            ];
        }

        return $rows;
    }

    public function transaction_type($connection = 'sqlsrv')
    {
        $sql = "SELECT [IDX_M_TransactionType]
                    ,[TransactionTypeID]
                    ,[TransactionTypeName]
                    ,[RecordStatus]
                FROM [dbo].[MC_M_TransactionType]
                WHERE IDX_M_TransactionType < 3";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_TransactionType)] = trim($row->TransactionTypeName);
        }
        return $value;
    }

}