<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

use File;
use Validator;

/**
 * Upload dokumen penjualan / pembelian valas (tab "Upload Dokumen").
 *
 * File disimpan di storage/app/public/<folder>/<id transaksi>/ dengan awalan acak
 * dan hanya dilayani lewat ID baris upload; lokasi file tidak pernah diambil dari
 * request. Controller pemakai mendefinisikan uploadConfig().
 */
trait OrderUploadTrait
{
    private static $uploadExtensions = ['jpg', 'jpeg', 'jfif', 'png', 'pdf'];
    private static $uploadImageExtensions = ['jpg', 'jpeg', 'jfif', 'png'];
    private static $uploadMaxKb = 10240;

    /**
     * @return array table, key (kolom ID upload), parent (kolom ID transaksi),
     *               order_table, folder, form_id, save_sp, list_sp, list_view, description
     */
    abstract protected function uploadConfig();

    public function upload(Request $request)
    {
        $config = $this->uploadConfig();
        $parent = $config['parent'];

        if (!$this->check_permission($this->data['user_id'], $config['form_id']))
        {
            return response()->json(['flag' => 'error', 'message' => 'Anda tidak memiliki akses.']);
        }

        $validator = Validator::make($request->all(), [
            $parent => 'required|integer|min:1',
            'UploadCategory' => 'required',
            'UploadFile' => 'required|file|mimes:jpg,jpeg,png,pdf|max:' . self::$uploadMaxKb,
        ], [
            $parent . '.*' => 'Transaksi tidak valid.',
            'UploadCategory.required' => 'Kategori dokumen belum dipilih!',
            'UploadFile.required' => 'File belum dipilih!',
            'UploadFile.mimes' => 'File harus berformat JPG, PNG atau PDF.',
            'UploadFile.max' => 'Ukuran file maksimal ' . (self::$uploadMaxKb / 1024) . ' MB.',
        ]);

        $file = $request->file('UploadFile');
        $extension = $file ? strtolower($file->getClientOriginalExtension()) : '';

        if ($validator->fails() || !in_array($extension, self::$uploadExtensions))
        {
            $message = $validator->fails() ? implode('<br>', $validator->errors()->all()) : 'File harus berformat JPG, PNG atau PDF.';
            return response()->json(['flag' => 'error', 'message' => $message]);
        }

        $id = (int) $request->input($parent);
        $exists = DB::connection('sqlsrv')->select("SELECT 1 AS X FROM {$config['order_table']} WITH(NOLOCK) WHERE $parent = ?", [$id]);
        if (!$exists)
        {
            return response()->json(['flag' => 'error', 'message' => 'Transaksi tidak ditemukan.']);
        }

        $path = $this->uploadDirectory($config, $id);
        if (!File::isDirectory($path))
        {
            File::makeDirectory($path, 0775, true, true);
        }

        // Awalan acak: nama file tidak bisa ditebak dan upload dengan nama sama tidak saling menimpa.
        $name = preg_replace('/[^\pL\pN ._()-]/u', '_', pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME));
        $stored = bin2hex(random_bytes(6)) . '_' . mb_substr(trim($name) ?: 'file', 0, 150) . '.' . $extension;
        $file->move($path, $stored);

        $param[$parent] = $id;
        $param['UploadCategory'] = 'XXX'.str_replace("'", "''", $request->input('UploadCategory'));
        $param['FilePath'] = 'XXX'.$path;
        $param['FileName'] = 'XXX'.str_replace("'", "''", $stored);
        $param['FileDescription'] = 'XXX'.str_replace("'", "''", $config['description'] . ' - ' . $request->input($config['number_field']));
        $param['UserID'] = 'XXX'.$this->data['user_id'];
        $this->exec_sp($config['save_sp'], $param, 'list', 'sqlsrv');

        $list[$parent] = $id;
        $this->data['records_upload'] = $this->exec_sp($config['list_sp'], $list, 'list', 'sqlsrv');

        return view($config['list_view'], $this->data);
    }

    public function download($id)
    {
        return $this->serveUpload($id, false);
    }

    public function view_file($id)
    {
        return $this->serveUpload($id, true);
    }

    // Nama file untuk ditampilkan, tanpa awalan acak.
    public static function uploadDisplayName($stored)
    {
        return preg_replace('/^[0-9a-f]{12}_/', '', basename($stored));
    }

    public static function isUploadImage($stored)
    {
        return in_array(strtolower(pathinfo($stored, PATHINFO_EXTENSION)), self::$uploadImageExtensions);
    }

    private function serveUpload($id, $inlineImage)
    {
        $config = $this->uploadConfig();

        if (!$this->check_permission($this->data['user_id'], $config['form_id']))
        {
            abort(403);
        }

        $row = DB::connection('sqlsrv')->select(
            "SELECT {$config['parent']} AS ParentID, FileName FROM {$config['table']} WITH(NOLOCK) WHERE {$config['key']} = ?",
            [(int) $id]
        );
        if (!$row)
        {
            abort(404);
        }

        $base = realpath(storage_path('app/public/' . $config['folder']));
        $path = realpath($this->uploadDirectory($config, $row[0]->ParentID) . DIRECTORY_SEPARATOR . basename($row[0]->FileName));
        $extension = strtolower(pathinfo((string) $path, PATHINFO_EXTENSION));

        if (!$base || !$path || strpos($path, $base . DIRECTORY_SEPARATOR) !== 0 || !is_file($path)
            || !in_array($extension, self::$uploadExtensions) || ($inlineImage && !self::isUploadImage($path)))
        {
            abort(404);
        }

        $headers = ['Content-Type' => $extension == 'pdf' ? 'application/pdf' : ($extension == 'png' ? 'image/png' : 'image/jpeg')];

        return $inlineImage
            ? response()->file($path, $headers)
            : response()->download($path, self::uploadDisplayName($path), $headers);
    }

    private function uploadDirectory(array $config, $id)
    {
        return storage_path('app/public/' . $config['folder'] . '/' . (int) $id);
    }
}
