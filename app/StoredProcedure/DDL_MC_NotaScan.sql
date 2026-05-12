-- =============================================
-- Author     : Samuel Febrianto
-- Create date: 17 Apr 2026
-- Description: DDL untuk fitur Scan Nota OCR
--              Jalankan script ini terlebih dahulu
--              sebelum membuat stored procedures
-- =============================================

-- ============================================================
-- TABLE HEADER
-- ============================================================
CREATE TABLE [dbo].[MC_T_NotaScan] (
    [IDX_T_MC_NotaScan]     BIGINT          NOT NULL IDENTITY(1,1),
    [TipeTransaksi]         CHAR(1)         NOT NULL,   -- J = Jual (SO), B = Beli (PO)
    [TanggalNota]           DATE            NULL,
    [NoNota]                VARCHAR(100)    NULL,       -- No. Kwitansi dari nota
    [NamaKonsumen]          VARCHAR(200)    NULL,       -- Nama pembeli/penjual
    [NoKTP]                 VARCHAR(50)     NULL,       -- No identitas konsumen
    [NoTelp]                VARCHAR(50)     NULL,       -- No telepon konsumen
    [SumberDana]            VARCHAR(200)    NULL,       -- Sumber dana (sesuai regulasi BI)
    [TujuanTransaksi]       VARCHAR(200)    NULL,       -- Tujuan transaksi (sesuai regulasi BI)
    [Keterangan]            VARCHAR(500)    NULL,       -- Catatan umum tambahan
    [FileName]              VARCHAR(255)    NULL,
    [FilePath]              VARCHAR(1000)   NULL,
    [OCRRawText]            NVARCHAR(MAX)   NULL,
    [Status]                CHAR(1)         NOT NULL DEFAULT 'D',  -- D = Draft
    [RecordStatus]          CHAR(1)         NOT NULL DEFAULT 'A',
    [UCreate]               VARCHAR(50)     NULL,
    [DCreate]               DATETIME        NULL,
    [UModified]             VARCHAR(50)     NULL,
    [DModified]             DATETIME        NULL,
    CONSTRAINT [PK_MC_T_NotaScan] PRIMARY KEY CLUSTERED ([IDX_T_MC_NotaScan] ASC)
)
GO

-- ============================================================
-- TABLE DETAIL
-- ============================================================
CREATE TABLE [dbo].[MC_T_NotaScanDetail] (
    [IDX_T_MC_NotaScanDetail]   BIGINT          NOT NULL IDENTITY(1,1),
    [IDX_T_MC_NotaScan]         BIGINT          NOT NULL,
    [Nomor]                     INT             NULL,
    [KeteranganValas]           VARCHAR(200)    NULL,   -- Diperlebar: e.g. "PHP 100x3+50x1+20x2"
    [NilaiValas]                DECIMAL(18,2)   NULL DEFAULT 0,  -- Total lembar valas (e.g. 390 PHP)
    [NilaiTukar]                DECIMAL(18,4)   NULL DEFAULT 0,  -- Rate / kurs
    [TotalNilai]                DECIMAL(18,2)   NULL DEFAULT 0,  -- Nilai IDR = NilaiValas * NilaiTukar
    [CatatanDetail]             VARCHAR(500)    NULL,   -- Catatan per baris (e.g. "Order PHP")
    [RecordStatus]              CHAR(1)         NOT NULL DEFAULT 'A',
    [UCreate]                   VARCHAR(50)     NULL,
    [DCreate]                   DATETIME        NULL,
    CONSTRAINT [PK_MC_T_NotaScanDetail] PRIMARY KEY CLUSTERED ([IDX_T_MC_NotaScanDetail] ASC),
    CONSTRAINT [FK_MC_T_NotaScanDetail_Header]
        FOREIGN KEY ([IDX_T_MC_NotaScan])
        REFERENCES [dbo].[MC_T_NotaScan] ([IDX_T_MC_NotaScan])
)
GO
