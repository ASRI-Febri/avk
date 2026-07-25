SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Simpan satu baris DTTOT dari hasil upload file Excel.
-- =============================================

-- EXEC USP_GN_DTTOT_Save 'NAMA alias ALIAS','deskripsi','Orang','ILQ-308','Uganda','09/03/1996','Uganda','Alamat','DTTOT 20260709.xlsx','admin'

CREATE PROCEDURE [dbo].[USP_GN_DTTOT_Save]
	@FullName			VARCHAR(1000),
	@Description		VARCHAR(MAX),
	@SuspectType		VARCHAR(50),
	@DensusCode			VARCHAR(50),
	@PlaceOfBirth		VARCHAR(500),
	@DateOfBirth		VARCHAR(200),
	@Nationality		VARCHAR(500),
	@Address			VARCHAR(2000),
	@FileName			VARCHAR(256),
	@UserID				VARCHAR(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO GN_M_DTTOT (
		FullName, [Description], SuspectType, DensusCode,
		PlaceOfBirth, DateOfBirth, Nationality, [Address],
		[FileName], UCreate, DCreate, RecordStatus
	)
	VALUES (
		@FullName, @Description, @SuspectType, @DensusCode,
		@PlaceOfBirth, @DateOfBirth, @Nationality, @Address,
		@FileName, @UserID, SYSDATETIME(), 'A'
	)

	SELECT 'success' AS Result
END
GO
