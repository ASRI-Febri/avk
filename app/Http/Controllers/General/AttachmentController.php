<?php

namespace App\Http\Controllers\General;

use Illuminate\Http\Request;
use App\Http\Controllers\MyController;

use Validator;

/**
 * Lampiran (PDF / gambar) data pendukung transaksi, dipakai bersama oleh beberapa
 * form lewat partial general.attachment_panel. File disimpan di
 * storage/app/attachment/<SourceType>/<SourceID>/ dengan nama acak dan hanya
 * dilayani lewat ID lampiran, bukan path dari request.
 */
class AttachmentController extends MyController
{
    const EXTENSIONS = ['pdf', 'jpg', 'jpeg', 'png'];
    const IMAGE_EXTENSIONS = ['jpg', 'jpeg', 'png'];
    const MAX_KB = 10240;

    // Hak akses per jenis transaksi; null = tanpa cek form (mengikuti halaman transaksinya).
    const SOURCES = [
        'FP' => ['read' => 'FM-FP-R', 'write' => 'FM-FP-U'],
        'JE' => ['read' => null, 'write' => null],
    ];

    const CATEGORIES = [
        'Bukti Transfer' => 'Bukti Transfer / Pembayaran',
        'Invoice'        => 'Invoice / Nota / Kwitansi',
        'Lainnya'        => 'Dokumen Pendukung Lainnya',
    ];

    public function list(Request $request)
    {
        $type = (string) $request->input('type');
        if (!$this->allowed($type, 'read'))
        {
            return response('<div class="text-danger">Anda tidak memiliki akses.</div>');
        }

        $param['SourceType'] = 'XXX'.$type;
        $param['SourceID'] = (int) $request->input('id');

        return view('general.attachment_list', [
            'records_attachment' => $this->exec_sp('USP_GN_Attachment_List', $param, 'list', 'sqlsrv'),
            'can_write' => $this->allowed($type, 'write'),
            'image_extensions' => self::IMAGE_EXTENSIONS,
        ]);
    }

    public function upload(Request $request)
    {
        $type = (string) $request->input('SourceType');
        $id = (int) $request->input('SourceID');

        if (!$this->allowed($type, 'write'))
        {
            return response()->json(['flag' => 'error', 'message' => 'Anda tidak memiliki akses.']);
        }

        $validator = Validator::make($request->all(), [
            'SourceID' => 'required|integer|min:1',
            'Category' => 'required|in:' . implode(',', array_keys(self::CATEGORIES)),
            'Description' => 'nullable|max:500',
            'files' => 'required|array',
            'files.*' => 'file|mimes:' . implode(',', self::EXTENSIONS) . '|max:' . self::MAX_KB,
        ], [
            'Category.required' => 'Kategori lampiran belum dipilih!',
            'files.required' => 'File belum dipilih!',
            'files.*.mimes' => 'File harus berformat PDF, JPG atau PNG.',
            'files.*.max' => 'Ukuran file maksimal ' . (self::MAX_KB / 1024) . ' MB.',
        ]);

        if ($validator->fails())
        {
            return response()->json(['flag' => 'error', 'message' => implode('<br>', $validator->errors()->all())]);
        }

        $messages = [];
        foreach ($request->file('files') as $file)
        {
            $extension = strtolower($file->getClientOriginalExtension());
            $stored = date('YmdHis') . '_' . bin2hex(random_bytes(6)) . '.' . $extension;
            $size = $file->getSize();
            $file->move($this->directory($type, $id), $stored);

            $param['SourceType'] = 'XXX'.$type;
            $param['SourceID'] = $id;
            $param['Category'] = 'XXX'.$this->esc($request->input('Category'));
            $param['FileName'] = 'XXX'.$this->esc(mb_substr($file->getClientOriginalName(), 0, 255));
            $param['StoredName'] = 'XXX'.$stored;
            $param['FileSize'] = $size;
            $param['Description'] = 'XXX'.$this->esc((string) $request->input('Description'));
            $param['UserID'] = 'XXX'.$this->data['user_id'];

            $result = $this->exec_sp('USP_GN_Attachment_Save', $param, 'list', 'sqlsrv');
            $result = end($result);

            if (strtolower($result->Result) != 'success')
            {
                @unlink($this->directory($type, $id) . '/' . $stored);
                return response()->json(['flag' => 'error', 'message' => $result->LogDesc]);
            }
            $messages[] = $result->LogDesc;
        }

        return response()->json(['flag' => 'success', 'message' => implode('<br>', $messages)]);
    }

    public function view($id)
    {
        return $this->serve($id, false);
    }

    public function download($id)
    {
        return $this->serve($id, true);
    }

    public function delete(Request $request)
    {
        $attachment = $this->find((int) $request->input('IDX_T_Attachment'));
        if (!$attachment || !$this->allowed($attachment->SourceType, 'write'))
        {
            return response()->json(['flag' => 'error', 'message' => 'Lampiran tidak ditemukan atau Anda tidak memiliki akses.']);
        }

        $param['IDX_T_Attachment'] = $attachment->IDX_T_Attachment;
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        $result = $this->exec_sp('USP_GN_Attachment_Delete', $param, 'list', 'sqlsrv');
        $result = end($result);

        return response()->json(['flag' => $result->Result, 'message' => $result->LogDesc]);
    }

    private function serve($id, $download)
    {
        $attachment = $this->find((int) $id);
        if (!$attachment || !$this->allowed($attachment->SourceType, 'read'))
        {
            abort(404);
        }

        $path = $this->directory($attachment->SourceType, $attachment->SourceID) . '/' . basename($attachment->StoredName);
        if (!is_file($path))
        {
            abort(404);
        }

        return $download
            ? response()->download($path, $attachment->FileName)
            : response()->file($path, ['Content-Disposition' => 'inline; filename="' . addslashes($attachment->FileName) . '"']);
    }

    private function find($id)
    {
        $param['IDX_T_Attachment'] = $id;
        $result = $this->exec_sp('USP_GN_Attachment_Info', $param, 'list', 'sqlsrv');

        return $result ? $result[0] : null;
    }

    private function allowed($type, $access)
    {
        if (!isset(self::SOURCES[$type]))
        {
            return false;
        }
        $form = self::SOURCES[$type][$access];

        return $form === null || $this->check_permission($this->data['user_id'], $form);
    }

    private function directory($type, $id)
    {
        return storage_path('app/attachment/' . $type . '/' . (int) $id);
    }

    // exec_sp menyusun EXEC dengan literal string tanpa escape.
    private function esc($value)
    {
        return str_replace("'", "''", $value);
    }
}
