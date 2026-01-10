<?php

    namespace App\Http\Controllers\MoneyChanger;

    use App\Http\Controllers\Controller;
    use Illuminate\Support\Facades\Storage;
    use Illuminate\Support\Facades\Response;

    class FileController extends Controller
    {
        public function servePdf($filename)
        {
            $path = 'sop-pdf/' . $filename; // Adjust path as needed

            if (!Storage::exists($path)) {
                abort(404); // File not found
            }

            return Storage::download($path, $filename, [
                'Content-Type' => 'application/pdf',
            ]);
        }

        public function showPdf($filename)
        {
            $filePath = 'sop-pdf/' . $filename; // Adjust 'pdfs/' to your actual storage path

            if (!Storage::exists($filePath)) {
                abort(404); // File not found
            }

            $pdfContent = Storage::get($filePath);

            return Response::make($pdfContent, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'inline; filename="' . $filename . '"',
            ]);
        }

    }