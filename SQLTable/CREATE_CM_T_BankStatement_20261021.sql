SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Rekening koran (bank statement) hasil upload PDF.
--				Header = satu file rekening koran (satu rekening, satu periode),
--				Detail = baris mutasinya. Setiap baris dapat dibuatkan jurnal
--				(IDX_T_JournalHeader); baris biaya admin (IsAdminFee) dapat
--				digabung menjadi satu jurnal penyesuaian.
--
--				Script boleh dijalankan berulang: setiap langkah diperiksa dulu.
-- =============================================

IF OBJECT_ID('dbo.CM_T_BankStatementHeader') IS NULL
BEGIN
	CREATE TABLE [dbo].[CM_T_BankStatementHeader](
		[IDX_T_BankStatementHeader]	[bigint] IDENTITY(1,1) NOT NULL,
		[IDX_M_Company]				[bigint] NOT NULL,
		[IDX_M_Branch]				[bigint] NOT NULL,
		[IDX_M_FinancialAccount]	[bigint] NOT NULL,
		[StatementNo]				[varchar](50) NOT NULL,
		[BankName]					[varchar](50) NULL,
		[AccountNo]					[varchar](50) NULL,
		[AccountName]				[varchar](100) NULL,
		[CurrencyID]				[varchar](3) NULL,
		[PeriodStart]				[date] NOT NULL,
		[PeriodEnd]					[date] NOT NULL,
		[OpeningBalance]			[decimal](22, 4) NOT NULL DEFAULT 0,
		[ClosingBalance]			[decimal](22, 4) NOT NULL DEFAULT 0,
		[TotalDebit]				[decimal](22, 4) NOT NULL DEFAULT 0,
		[TotalCredit]				[decimal](22, 4) NOT NULL DEFAULT 0,
		[FileName]					[varchar](255) NULL,
		[Notes]						[varchar](500) NULL,
		[UCreate]					[varchar](36) NULL,
		[DCreate]					[datetime] NULL,
		[UModified]					[varchar](36) NULL,
		[DModified]					[datetime] NULL,
		[RecordStatus]				[varchar](1) NULL,
	 CONSTRAINT [PK_CM_T_BankStatementHeader] PRIMARY KEY CLUSTERED ([IDX_T_BankStatementHeader] ASC)
	)
END
GO

IF OBJECT_ID('dbo.CM_T_BankStatementDetail') IS NULL
BEGIN
	CREATE TABLE [dbo].[CM_T_BankStatementDetail](
		[IDX_T_BankStatementDetail]	[bigint] IDENTITY(1,1) NOT NULL,
		[IDX_T_BankStatementHeader]	[bigint] NOT NULL,
		[SeqNo]						[int] NOT NULL,
		[PostingDate]				[datetime] NOT NULL,
		[Remark]					[varchar](1000) NULL,
		[ReferenceNo]				[varchar](100) NULL,
		[DebitAmount]				[decimal](22, 4) NOT NULL DEFAULT 0,
		[CreditAmount]				[decimal](22, 4) NOT NULL DEFAULT 0,
		[Balance]					[decimal](22, 4) NOT NULL DEFAULT 0,
		[IsAdminFee]				[bit] NOT NULL DEFAULT 0,
		[IDX_T_JournalHeader]		[bigint] NULL,
		[UCreate]					[varchar](36) NULL,
		[DCreate]					[datetime] NULL,
		[UModified]					[varchar](36) NULL,
		[DModified]					[datetime] NULL,
		[RecordStatus]				[varchar](1) NULL,
	 CONSTRAINT [PK_CM_T_BankStatementDetail] PRIMARY KEY CLUSTERED ([IDX_T_BankStatementDetail] ASC),
	 CONSTRAINT [FK_CM_T_BankStatementDetail_Header] FOREIGN KEY ([IDX_T_BankStatementHeader])
		REFERENCES [dbo].[CM_T_BankStatementHeader] ([IDX_T_BankStatementHeader])
	)

	CREATE INDEX [IX_CM_T_BankStatementDetail_Header]
		ON [dbo].[CM_T_BankStatementDetail] ([IDX_T_BankStatementHeader], [SeqNo])
END
GO
