SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Screening nama konsumen (GN_M_Partner) terhadap daftar DTTOT (GN_M_DTTOT).
--				Nama DTTOT dipecah per segmen "alias" lalu dicocokkan dengan nama konsumen:
--				  EXACT   = nama konsumen sama persis dengan salah satu nama/alias DTTOT
--				  PARTIAL = nama konsumen terkandung di nama/alias DTTOT atau sebaliknya
--				            (minimal 5 karakter untuk mengurangi false positive)
--				Kolom IsDTTOT menunjukkan flag saat ini pada data konsumen.
-- =============================================

-- EXEC USP_GN_DTTOT_Screening

CREATE PROCEDURE [dbo].[USP_GN_DTTOT_Screening]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ============================================================
	-- PECAH NAMA DTTOT MENJADI SEGMEN ALIAS
	-- (split manual dengan CHARINDEX agar tidak bergantung pada
	--  STRING_SPLIT / compatibility level database)
	-- ============================================================
	CREATE TABLE #Alias (
		IDX_M_DTTOT			BIGINT,
		FullName			VARCHAR(1000),
		DensusCode			VARCHAR(50),
		SuspectType			VARCHAR(50),
		AliasName			VARCHAR(1000)
	)

	DECLARE @IDX		BIGINT
	DECLARE @FullName	VARCHAR(1000)
	DECLARE @Code		VARCHAR(50)
	DECLARE @Type		VARCHAR(50)
	DECLARE @Work		VARCHAR(1100)
	DECLARE @Pos		INT
	DECLARE @Segment	VARCHAR(1000)

	DECLARE cur_dttot CURSOR LOCAL FAST_FORWARD FOR
		SELECT IDX_M_DTTOT, RTRIM(ISNULL(FullName,'')), RTRIM(ISNULL(DensusCode,'')), RTRIM(ISNULL(SuspectType,''))
		FROM GN_M_DTTOT
		WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A'

	OPEN cur_dttot
	FETCH NEXT FROM cur_dttot INTO @IDX, @FullName, @Code, @Type

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Work = UPPER(@FullName) + ' ALIAS '

		WHILE CHARINDEX(' ALIAS ', @Work) > 0
		BEGIN
			SET @Pos = CHARINDEX(' ALIAS ', @Work)
			SET @Segment = LTRIM(RTRIM(LEFT(@Work, @Pos - 1)))

			IF @Segment <> ''
				INSERT INTO #Alias VALUES (@IDX, @FullName, @Code, @Type, @Segment)

			SET @Work = SUBSTRING(@Work, @Pos + 7, LEN(@Work) + 7)
		END

		FETCH NEXT FROM cur_dttot INTO @IDX, @FullName, @Code, @Type
	END

	CLOSE cur_dttot
	DEALLOCATE cur_dttot

	-- ============================================================
	-- COCOKKAN DENGAN NAMA KONSUMEN
	-- ============================================================
	SELECT X.IDX_M_Partner, X.PartnerID, X.PartnerName, X.SingleIdentityNumber, X.IsDTTOT,
		X.IDX_M_DTTOT, X.DTTOTName, X.DensusCode, X.SuspectType, X.AliasName, X.MatchType
	FROM (
		SELECT
			P.IDX_M_Partner,
			RTRIM(ISNULL(P.PartnerID,''))				AS PartnerID,
			UPPER(RTRIM(ISNULL(P.PartnerName,'')))		AS PartnerName,
			RTRIM(ISNULL(P.SingleIdentityNumber,''))	AS SingleIdentityNumber,
			CASE WHEN RTRIM(ISNULL(P.IsDTTOT,'N')) = 'Y' THEN 'Y' ELSE 'N' END AS IsDTTOT,
			A.IDX_M_DTTOT,
			A.FullName									AS DTTOTName,
			A.DensusCode,
			A.SuspectType,
			A.AliasName,
			CASE WHEN UPPER(RTRIM(P.PartnerName)) = A.AliasName THEN 'EXACT' ELSE 'PARTIAL' END AS MatchType,
			ROW_NUMBER() OVER (
				PARTITION BY P.IDX_M_Partner, A.IDX_M_DTTOT
				ORDER BY CASE WHEN UPPER(RTRIM(P.PartnerName)) = A.AliasName THEN 0 ELSE 1 END
			) AS rn
		FROM GN_M_Partner P
		INNER JOIN #Alias A
			ON (
				UPPER(RTRIM(P.PartnerName)) = A.AliasName
				OR (LEN(RTRIM(ISNULL(P.PartnerName,''))) >= 5 AND A.AliasName LIKE '%' + UPPER(RTRIM(P.PartnerName)) + '%')
				OR (LEN(A.AliasName) >= 5 AND UPPER(RTRIM(ISNULL(P.PartnerName,''))) LIKE '%' + A.AliasName + '%')
			)
		WHERE RTRIM(ISNULL(P.RecordStatus,'')) = 'A'
	) X
	WHERE X.rn = 1
	ORDER BY CASE X.MatchType WHEN 'EXACT' THEN 0 ELSE 1 END, X.PartnerName, X.DensusCode
END
GO
