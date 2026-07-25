SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Daftar Terduga Teroris dan Organisasi Teroris (DTTOT).
--				Data diupload dari file Excel resmi (renewal periodik),
--				setiap upload mengganti seluruh isi tabel.
-- =============================================
CREATE TABLE [dbo].[GN_M_DTTOT](
	[IDX_M_DTTOT] [bigint] IDENTITY(1,1) NOT NULL,
	[FullName] [varchar](1000) NULL,
	[Description] [varchar](max) NULL,
	[SuspectType] [varchar](50) NULL,
	[DensusCode] [varchar](50) NULL,
	[PlaceOfBirth] [varchar](500) NULL,
	[DateOfBirth] [varchar](200) NULL,
	[Nationality] [varchar](500) NULL,
	[Address] [varchar](2000) NULL,
	[FileName] [varchar](256) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_GN_M_DTTOT] PRIMARY KEY CLUSTERED
(
	[IDX_M_DTTOT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GN_M_DTTOT] ADD  CONSTRAINT [DF_GN_M_DTTOT_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[GN_M_DTTOT] ADD  CONSTRAINT [DF_GN_M_DTTOT_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[GN_M_DTTOT] ADD  CONSTRAINT [DF_GN_M_DTTOT_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orang atau Korporasi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GN_M_DTTOT', @level2type=N'COLUMN',@level2name=N'SuspectType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tanggal lahir disimpan sebagai teks karena format sumber bervariasi (bisa lebih dari satu tanggal)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GN_M_DTTOT', @level2type=N'COLUMN',@level2name=N'DateOfBirth'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nama file Excel sumber upload terakhir' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GN_M_DTTOT', @level2type=N'COLUMN',@level2name=N'FileName'
GO
