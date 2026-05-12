<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;
use Illuminate\Support\Facades\Log;

class OcrService
{
    protected $client;
    protected $apiKey;
    protected $model;

    public function __construct()
    {
        $this->client = new Client(['timeout' => 120]);
        $this->apiKey = config('services.anthropic.api_key');
        $this->model  = config('services.anthropic.model', 'claude-haiku-4-5-20251001');
    }

    /**
     * Ekstrak data terstruktur dari gambar nota transaksi valuta asing.
     *
     * @param  string $imagePath  Path absolut ke file gambar
     * @return array  ['success' => bool, 'data' => array, 'raw' => string, 'message' => string]
     */
    public function extractNotaData(string $imagePath): array
    {
        if (empty($this->apiKey)) {
            return $this->errorResult('ANTHROPIC_API_KEY belum dikonfigurasi di file .env');
        }

        if (!file_exists($imagePath)) {
            return $this->errorResult('File gambar tidak ditemukan: ' . $imagePath);
        }

        $imageData = base64_encode(file_get_contents($imagePath));
        $mimeType  = $this->detectMimeType($imagePath);

        $prompt = <<<EOT
Kamu adalah asisten OCR untuk nota transaksi valuta asing (money changer).
Ekstrak data dari gambar nota ini dan kembalikan HANYA JSON valid tanpa penjelasan tambahan.

Format JSON yang diharapkan:
{
  "tipe_transaksi": "J atau B (J=Jual ke konsumen, B=Beli dari konsumen/supplier)",
  "tanggal_nota": "YYYY-MM-DD (kosong string jika tidak terbaca)",
  "no_nota": "nomor nota/kwitansi (kosong string jika tidak ada)",
  "nama_konsumen": "nama lengkap konsumen (kosong string jika tidak ada)",
  "no_ktp": "nomor identitas KTP/passport/SIM konsumen (kosong string jika tidak ada)",
  "no_telp": "nomor telepon konsumen (kosong string jika tidak ada)",
  "sumber_dana": "sumber dana misal: Tabungan, Gaji, Bisnis, Investasi (kosong string jika tidak ada)",
  "tujuan_transaksi": "tujuan transaksi misal: Perjalanan, Bisnis, Pendidikan (kosong string jika tidak ada)",
  "keterangan": "keterangan tambahan singkat",
  "detail": [
    {
      "nomor": 1,
      "keterangan_valas": "kode mata uang dan deskripsi pecahan misal: PHP 100x3+50x1",
      "nilai_valas": 100.00,
      "nilai_tukar": 16000,
      "total_nilai": 1600000,
      "catatan_detail": "catatan tambahan untuk baris ini (kosong string jika tidak ada)"
    }
  ]
}

Aturan:
- tipe_transaksi: "J" jika nota bertulisan Jual/Sell, "B" jika Beli/Buy
- Jika ada beberapa baris valuta, sertakan semua dalam array detail
- total_nilai = nilai_valas * nilai_tukar (hitung otomatis jika tidak tertulis)
- Nomor urut di kolom detail dimulai dari 1
- Jika kolom tidak ditemukan gunakan nilai kosong string atau angka 0
- Kembalikan HANYA JSON, tidak ada teks lain sebelum atau sesudah
EOT;

        try {
            $response = $this->client->post('https://api.anthropic.com/v1/messages', [
                'headers' => [
                    'x-api-key'         => $this->apiKey,
                    'anthropic-version' => '2023-06-01',
                    'content-type'      => 'application/json',
                ],
                'json' => [
                    'model'      => $this->model,
                    'max_tokens' => 2048,
                    'messages'   => [
                        [
                            'role'    => 'user',
                            'content' => [
                                [
                                    'type'   => 'image',
                                    'source' => [
                                        'type'       => 'base64',
                                        'media_type' => $mimeType,
                                        'data'       => $imageData,
                                    ],
                                ],
                                [
                                    'type' => 'text',
                                    'text' => $prompt,
                                ],
                            ],
                        ],
                    ],
                ],
            ]);

            $body = json_decode($response->getBody()->getContents(), true);
            $text = $body['content'][0]['text'] ?? '';

            // Extract JSON block dari response
            $jsonText = $text;
            if (preg_match('/\{[\s\S]*\}/m', $text, $matches)) {
                $jsonText = $matches[0];
            }

            $data = json_decode($jsonText, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                Log::warning('OcrService: JSON parse error - ' . $text);
                return $this->errorResult('Gagal mem-parse respons OCR. Silakan coba lagi.');
            }

            // Normalize header fields
            $data['tipe_transaksi']   = (string)($data['tipe_transaksi']   ?? '');
            $data['tanggal_nota']     = (string)($data['tanggal_nota']     ?? '');
            $data['no_nota']          = (string)($data['no_nota']          ?? '');
            $data['nama_konsumen']    = (string)($data['nama_konsumen']    ?? '');
            $data['no_ktp']           = (string)($data['no_ktp']           ?? '');
            $data['no_telp']          = (string)($data['no_telp']          ?? '');
            $data['sumber_dana']      = (string)($data['sumber_dana']      ?? '');
            $data['tujuan_transaksi'] = (string)($data['tujuan_transaksi'] ?? '');
            $data['keterangan']       = (string)($data['keterangan']       ?? '');

            // Normalize detail array
            if (!isset($data['detail']) || !is_array($data['detail'])) {
                $data['detail'] = [];
            }

            foreach ($data['detail'] as &$row) {
                $row['nomor']            = (int)   ($row['nomor']            ?? 0);
                $row['keterangan_valas'] = (string)($row['keterangan_valas'] ?? '');
                $row['nilai_valas']      = (float) ($row['nilai_valas']      ?? 0);
                $row['nilai_tukar']      = (float) ($row['nilai_tukar']      ?? 0);
                $row['total_nilai']      = (float) ($row['total_nilai']      ?? 0);
                $row['catatan_detail']   = (string)($row['catatan_detail']   ?? '');

                // Hitung ulang total jika 0
                if ($row['total_nilai'] == 0 && $row['nilai_valas'] > 0 && $row['nilai_tukar'] > 0) {
                    $row['total_nilai'] = $row['nilai_valas'] * $row['nilai_tukar'];
                }
            }

            return [
                'success' => true,
                'data'    => $data,
                'raw'     => $text,
                'message' => '',
            ];

        } catch (RequestException $e) {
            $msg = 'HTTP Error OCR: ' . $e->getMessage();
            Log::error('OcrService: ' . $msg);
            return $this->errorResult($msg);
        } catch (\Exception $e) {
            $msg = 'Error OCR: ' . $e->getMessage();
            Log::error('OcrService: ' . $msg);
            return $this->errorResult($msg);
        }
    }

    private function detectMimeType(string $path): string
    {
        $map = [
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png'  => 'image/png',
            'gif'  => 'image/gif',
            'webp' => 'image/webp',
        ];
        $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
        return $map[$ext] ?? 'image/jpeg';
    }

    private function errorResult(string $message): array
    {
        return [
            'success' => false,
            'message' => $message,
            'data'    => [
                'tipe_transaksi'   => '',
                'tanggal_nota'     => '',
                'no_nota'          => '',
                'nama_konsumen'    => '',
                'no_ktp'           => '',
                'no_telp'          => '',
                'sumber_dana'      => '',
                'tujuan_transaksi' => '',
                'keterangan'       => '',
                'detail'           => [],
            ],
            'raw'     => '',
        ];
    }
}
