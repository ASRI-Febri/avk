-- =============================================
-- Author		:	Ferry
-- Create date	:	09112015
-- Description	:	Query Untuk Closing
-- Mod			:	2024-01-04 by Anton --> Mod from SP CAR into Quality
-- =============================================

-- EXEC [dbo].[USP_CM_ClosingPeriod] '01','2024','1305276','Y'

CREATE PROCEDURE [dbo].[usp_CM_ClosingPeriod]
	-- Add the parameters for the stored procedure here
	@Bulan VARCHAR(2),
	@Tahun VARCHAR(4),
	@UCreate VARCHAR(7),
	@IgnoreUnpost VARCHAR(1) -- jika ignore transaksi unpost tulis Y, jika tidak (harus post) tulis N
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- INSERT statements for procedure here
	--- param --
	--DECLARE @Bulan VARCHAR(2) = '11'
	--DECLARE @Tahun VARCHAR(4) = '2015'
	--DECLARE @UCreate VARCHAR(7) = '1404047'
	------------

	BEGIN TRANSACTION TRANS_CM_ClosingPeriod

	--- param generator ---
	DECLARE @sdate DATETIME  = CONVERT(DATETIME,@tahun+@bulan+'01')
	DECLARE @edate DATETIME = DATEADD(s,-1,DATEADD(m,1,@sdate))
	DECLARE @speriode VARCHAR(6) = LEFT(CONVERT(VARCHAR,@sdate,112),6)
	DECLARE @BPeriode VARCHAR(6) = LEFT(CONVERT(VARCHAR,DATEADD(m,-1,@sdate),112),6)

	DECLARE @COA_LTB VARCHAR(20) = '302.02.000' --Laba Tahun Berjalan
	DECLARE @AccountType_LTB VARCHAR(2)
	DECLARE @IDX_COA_LTB BIGINT 

	SELECT @IDX_COA_LTB = IDX_M_COA, @AccountType_LTB = B.COATypeID
	FROM GL_M_COA A
		INNER JOIN GL_M_COAType B ON A.IDX_M_COAType = B.IDX_M_COAType
	WHERE A.COAID = @COA_LTB

	DECLARE @COA_LD				VARCHAR(20) = '302.00.000' --Laba Ditahan
	DECLARE @AccountType_LD		VARCHAR(2)
	DECLARE @IDX_COA_LD			BIGINT 

	SELECT @IDX_COA_LD = IDX_M_COA, @AccountType_LD = B.COATypeID 
	FROM GL_M_COA A
		INNER JOIN GL_M_COAType B ON A.IDX_M_COAType = B.IDX_M_COAType 
	WHERE A.COAID = @COA_LD

	--DECLARE @COA_DI				VARCHAR(20) = '304.01.01.004' --Dividen Interim
	--DECLARE @AccountType_DI		VARCHAR(2)
	--DECLARE @IDX_COA_DI			BIGINT 

	--SELECT @IDX_COA_DI = IDX_M_COA, @AccountType_DI = AccountType 
	--FROM M_COA 
	--WHERE COA = @COA_DI

	DECLARE @RateEOM DECIMAL(18,2) = (SELECT TOP 1 Rate FROM M_Rate WHERE TransactionDate < @edate ORDER BY TRANSACTIONDate DESC)
	------------------------

	----- Prerequisite ---
	--SELECT OT.Jenis, OT.Kode, OT.Tanggal, OT.NIK, MU.Name
	--INTO #tempOT
	--FROM (
	--	SELECT 'Entry Titipan' AS Jenis, BSCode AS Kode, JournalDateBS AS Tanggal, UCreate AS NIK FROM T_BankStatementHeader WHERE (JournalDateBS between @sdate AND @edate) AND ApprovalStatusBS = 'D' AND RecordStatus = 'A'
	--	UNION ALL
	--	SELECT 'Vendor Invoice' AS Jenis, VICode AS Kode, JournalDateVI AS Tanggal, UCreate AS NIK FROM T_VENDorInvoiceHeader WHERE (JournalDateVI between @sdate AND @edate) AND ApprovalStatusVI = 'D' AND RecordStatus = 'A'
	--	UNION ALL
	--	SELECT 'Vendor Payment' AS Jenis, VPCode AS Kode, JournalDateVP AS Tanggal, UCreate AS NIK FROM T_VENDorPaymentHeader WHERE (JournalDateVP between @sdate AND @edate) AND ApprovalStatusVP = 'D' AND RecordStatus = 'A'
	--	UNION ALL
	--	SELECT 'Financial Payment' AS Jenis, FTCode AS Kode, JournalDate AS Tanggal, UCreate AS NIK FROM T_FinancialTRANSACTIONHeader WHERE (TRANSACTIONDate between @sdate AND @edate) AND ApprovalStatus = 'D' AND RecordStatus = 'A'
	--	) OT
	--LEFT JOIN SecurityManagementDB.dbo.M_Users MU on OT.NIK = MU.NIK

	--- VALIDATION POSTING ---
	--IF EXISTS (SELECT '' FROM #tempOT)
	--BEGIN
	--	PRINT 'ada journal yang belum di approve pada periode closing, batalkan closing'

	--	SELECT * FROM #tempOT

	--	IF @IgnoreUnpost = 'N' -- jagaan buat ignore post
	--	BEGIN
	--		GOTO Errorsp
	--	END
	--	ELSE
	--	BEGIN
	--		PRINT 'Ignore Post, Yeahhh'
	--	END
	--END

	--PRINT 'Posting Check, Done'

	--- VALIDATION RATE ---
	--IF EXISTS (SELECT ''
	--			FROM (SELECT Currency, @sdate as datemin
	--					FROM MasterGlobalDB.dbo.M_GroupsCompany
	--					WHERE Currency <> 'IDR'
	--					GROUP BY Currency) BCR 
	--			LEFT JOIN M_Rate TR on TR.CurrencyID = BCR.Currency AND TR.TransactionDate < BCR.datemin
	--			WHERE TR.TransactionDate IS NULL)
	--BEGIN
	---- ada kurs yang belum ada rate nya, EJECT SP
	--	PRINT 'Kurs Belum Terisi'
	--	GOTO Errorsp
	--END
	--PRINT 'Rate Ready'

	--- VALIDATION CLOSING ---
	IF EXISTS(SELECT '' FROM GL_T_AccountBalance WHERE JournalPeriod = @speriode)
	BEGIN
		PRINT 'Closing Periode ' + @speriode + ' Found'
		PRINT 'Delete Closing Periode ' + @speriode
		DELETE GL_T_AccountBalance WHERE JournalPeriod = @speriode
	END
	ELSE
	BEGIN
		PRINT 'Closing Periode ' + @speriode + ' Not Found'
	END
	PRINT 'Validation Closing, Done'
	----------------------------------------------------------------

	--- Source ---
	SELECT JH.IDX_M_Company, JH.IDX_M_Branch, CONVERT(DATE,JH.JournalDate) AS JournalDate, COA.TranslationRate, MC.CurrencyID AS BaseCur, JD.IDX_M_COA, COATYPE.COATypeID, 
			--JD.BDebetAmount, 
			CONVERT(DECIMAL(20,4),JD.BDebetAmount) BDebetAmount, 
			CONVERT(DECIMAL(20,4),JD.BCreditAmount) BCreditAmount
	INTO #SourceJournal
	FROM GL_T_JournalDetail JD
		LEFT JOIN GL_T_JournalHeader JH ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_COAType COATYPE ON COA.IDX_M_COAType = COATYPE.IDX_M_COAType
		LEFT JOIN GN_M_Company MGC ON JH.IDX_M_Company = MGC.IDX_M_Company
		INNER JOIN GN_M_Currency MC ON MGC.IDX_M_Currency = MC.IDX_M_Currency
	--WHERE JD.RecordStatus = 'A' AND JH.RecordStatus = 'A' AND JH.IsPosted = 'P' AND JH.PostingDate between @sdate AND @Edate
	WHERE JD.RecordStatus = 'A' AND JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' AND JH.JournalPeriod = @speriode --JH.JournalDate between @sdate AND @Edate -- ganti jadi periode
		AND RTRIM(COA.COAID) <> '302.02.000'	

	PRINT 'Source populate (Creating #SourceJournal), Done'

	-- UPDATE JournalDate WHERE TranslationRate E(END of month rate) to ENDOf Month date 
	UPDATE #SourceJournal
	SET JournalDate = CONVERT(DATE,@edate)
	WHERE TranslationRate = 'E'

	PRINT 'UPDATE Date on #SourceJournal WHERE TranslationRate E(END of month rate) to ENDOf Month date, Done'

	-- UPDATE JournalDate to specific date based on Rate
	WHILE EXISTS (SELECT ''
					FROM (SELECT JournalDate, BaseCur
							FROM #SourceJournal
							GROUP BY JournalDate, BaseCur) SJ
					LEFT JOIN M_Rate TR on SJ.JournalDate = TR.TransactionDate AND SJ.BaseCur = TR.CurrencyID
					WHERE TR.TransactionDate IS NULL AND SJ.BaseCur <> 'IDR')
	BEGIN
		PRINT 'UPDATE temp moving date (d-1)'

		UPDATE #SourceJournal
		SET JournalDate = DATEADD(d,-1,JournalDate)
		WHERE JournalDate in (SELECT SJ.JournalDate
								FROM (SELECT JournalDate, BaseCur
										FROM #SourceJournal
										GROUP BY JournalDate, BaseCur) SJ
								LEFT JOIN M_Rate TR on SJ.JournalDate = TR.TransactionDate AND SJ.BaseCur = TR.CurrencyID
								WHERE TR.TransactionDate IS NULL AND SJ.BaseCur <> 'IDR')
	END

	PRINT 'UPDATE Date on #SourceJournal, Done Rate ALL Match'

	--- Create BakedSource (Count Transalation)
	SELECT @Tahun + @Bulan as JournalPeriod,
			SJ.IDX_M_Company, SJ.IDX_M_Branch,
			SJ.IDX_M_COA, 
			SJ.COATypeID,
			SUM(CONVERT(DECIMAL(20,4),SJ.BDebetAmount)) AS BDebetAmount, 
			SUM(CONVERT(DECIMAL(20,4),SJ.BCreditAmount)) AS BCreditAmount, 
			SUM(CONVERT(DECIMAL(20,4),SJ.bdebetamount) * CONVERT(DECIMAL(20,4),ISNULL(tr.Rate,1))) AS TDebetAmount, 
			SUM(CONVERT(DECIMAL(20,4),SJ.bcreditamount) * CONVERT(DECIMAL(20,4),ISNULL(tr.Rate,1))) AS TCreditAmount
	INTO #BakedSource
	FROM #SourceJournal SJ
		LEFT JOIN M_Rate TR on SJ.JournalDate = TR.TRANSACTIONDate AND SJ.BaseCur = TR.CurrencyID
	GROUP BY SJ.IDX_M_Company, SJ.IDX_M_Branch, SJ.IDX_M_COA, SJ.COATypeID

	PRINT 'Creating #BakedSource (Count Transalation), Done'

	-- clear up memory
	TRUNCATE TABLE #SourceJournal

	PRINT 'Truncate #SourceJournal (Clean Memory), Done'

	-- Calculate + Insert Laba tahun berjalan to BakedSource
	-- Cek jika ada transaksi journal yang menggunakan account Laba Tahun Berjalan

	--IF EXISTS(SELECT JournalPeriod FROM #BakedSource WHERE IDX_M_COA = @IDX_COA_LTB)
	--BEGIN
	--	PRINT 'Exists data Laba Tahun Berjalan'

	--	UPDATE #BakedSource SET BDebetAmount = #BakedSource.BDebetAmount + Temp.BDebetAmount, 
	--		BCreditAmount = #BakedSource.BCreditAmount + Temp.BCreditAmount,
	--		TDebetAmount = #BakedSource.TDebetAmount + Temp.TDebetAmount, 
	--		TCreditAmount = #BakedSource.TCreditAmount + Temp.TCreditAmount
	--	FROM (	SELECT @tahun + @bulan as JournalPeriod, 
	--					IDX_M_Organization, 
	--					IDX_M_Branch, 
	--					@IDX_COA_LTB as IDX_M_COA, 
	--					@AccountType_LTB as AccountType, 
	--					SUM(CONVERT(DECIMAL(20,4),BDebetAmount)) as BDebetAmount, 
	--					SUM(CONVERT(DECIMAL(20,4),BCreditAmount)) as BCreditAmount,
	--					SUM(CONVERT(DECIMAL(20,4),TDebetAmount)) as TDebetAmount, 
	--					SUM(CONVERT(DECIMAL(20,4),TCreditAmount)) as TCreditAmount
	--			FROM #BakedSource
	--			WHERE RTRIM(AccountType) IN ('EX','IC')
	--			GROUP BY IDX_M_Organization, IDX_M_Branch) Temp		
	--	INNER JOIN #BakedSource ON #BakedSource.IDX_M_Organization = Temp.IDX_M_Organization AND #BakedSource.IDX_M_Branch = Temp.IDX_M_Branch
	--	WHERE #BakedSource.IDX_M_COA = @IDX_COA_LTB
	--END
	--ELSE
	--BEGIN
	--PRINT 'Not Exists data Laba Tahun Berjalan'

	-- Insert Laba Tahun Berjalan
	INSERT INTO #BakedSource (JournalPeriod, IDX_M_Company, IDX_M_Branch, IDX_M_COA, COATypeID, BDebetAmount, BCreditAmount, TDebetAmount, TCreditAmount)
	SELECT @tahun + @bulan as JournalPeriod, 
			IDX_M_Company, 
			IDX_M_Branch, 
			@IDX_COA_LTB as IDX_M_COA, 
			@AccountType_LTB as AccountType, 
			SUM(CONVERT(DECIMAL(20,4),BDebetAmount)) as BDebetAmount, 
			SUM(CONVERT(DECIMAL(20,4),BCreditAmount)) as BCreditAmount,
			SUM(CONVERT(DECIMAL(20,4),TDebetAmount)) as TDebetAmount, 
			SUM(CONVERT(DECIMAL(20,4),TCreditAmount)) as TCreditAmount
	FROM #BakedSource
	WHERE RTRIM(COATypeID) IN ('EX','IC')
	GROUP BY IDX_M_Company, IDX_M_Branch

	-- Update Laba Tahun Berjalan, jika ada transaksi journal memorial 
	-- yang menggunakan account tersebut
	UPDATE #BakedSource SET BDebetAmount = #BakedSource.BDebetAmount + Temp.BDebetAmount, 
		BCreditAmount = #BakedSource.BCreditAmount + Temp.BCreditAmount
	FROM (	SELECT IDX_M_Company, IDX_M_Branch, IDX_M_COA, BDebetAmount = SUM(BDebetAmount), BCreditAmount = SUM(BCreditAmount) 
			FROM GL_T_JournalHeader JH
				LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
			WHERE JH.JournalPeriod = @speriode AND JD.IDX_M_COA = @IDX_COA_LTB
			GROUP BY IDX_M_Company, IDX_M_Branch, IDX_M_COA) Temp
	INNER JOIN #BakedSource ON #BakedSource.IDX_M_Company = Temp.IDX_M_Company AND #BakedSource.IDX_M_Branch = Temp.IDX_M_Branch
	WHERE #BakedSource.IDX_M_COA = @IDX_COA_LTB

	--END	

	PRINT 'Calculate + INSERT LTB to #BakedSource, Done'

	-- ========================================================
	-- Get last periode Account Balance (LPAB)
	-- Jika periode adalah bulan Januari atau bulan pertama tahun fiskal,
	-- maka saldo awal dari Account Laba Tahun Berjalan harus di set = 0
	-- ========================================================
	SELECT AB.IDX_M_Company,  
			AB.IDX_M_Branch, 
			AB.IDX_M_COA,
			CASE WHEN @Bulan = '01' AND AB.IDX_M_COA = @IDX_COA_LTB THEN 0 ELSE CONVERT(DECIMAL(20,4),AB.BEndingBalance) END AS BEndingBalance,
			CASE WHEN @Bulan = '01' AND AB.IDX_M_COA = @IDX_COA_LTB THEN 0 ELSE CONVERT(DECIMAL(20,4),AB.TEndingBalance) END AS TEndingBalance
	INTO #LPAB
	FROM GL_T_AccountBalance AB WHERE AB.JournalPeriod = @BPeriode -- @BPeriod = Periode Sebelumnya

	--IF @speriode = '202007'
	--BEGIN
	--	DECLARE @EndingForLTB DECIMAL(20,4)

	--	SELECT @EndingForLTB = SUM(AB.BEndingBalance) 
	--	FROM GL_T_AccountBalance AB WITH(NOLOCK)
	--		INNER JOIN GL_M_COA COA WITH(NOLOCK) ON AB.IDX_M_COA = COA.IDX_M_COA
	--		INNER JOIN GL_M_COAType COAType WITH(NOLOCK) ON COA.IDX_M_COAType = COAType.IDX_M_COAType
	--	WHERE AB.JournalPeriod ='202006' AND COAType.COATypeID IN ('IC','EX')

	--	UPDATE #LPAB SET BEndingBalance = @EndingForLTB, TEndingBalance = @EndingForLTB WHERE IDX_M_COA = @IDX_COA_LTB
	--END

	PRINT 'INSERT Last Periode AcountBalance to #LPAB, Done '

	IF @Bulan = '01'
	BEGIN

		DELETE #LPAB
		WHERE IDX_M_COA = @IDX_COA_LD

		INSERT INTO #LPAB (IDX_M_Company, IDX_M_Branch, IDX_M_COA, BENDingBalance, TENDingBalance)
		SELECT IDX_M_Company AS IDX_M_Organization, IDX_M_Branch AS IDX_M_Branch, @IDX_COA_LD AS IDX_M_COA, 
				sum(CONVERT(DECIMAL(20,4),BEndingBalance)) AS BEndingBalance, 
				sum(CONVERT(DECIMAL(20,4),TEndingBalance)) AS TEndingBalance
		--FROM T_AccountBalance AB WHERE AB.JournalPeriod = @BPeriode AND IDX_M_COA in (@IDX_COA_LTB, @IDX_COA_LD)
		--FROM T_AccountBalance AB WHERE AB.JournalPeriod = @BPeriode AND IDX_M_COA in (@IDX_COA_LTB, @IDX_COA_LD, @IDX_COA_DI) --mod Anton 22 Mei 2017 --> dividen interim
		FROM GL_T_AccountBalance AB WHERE AB.JournalPeriod = @BPeriode AND IDX_M_COA in (@IDX_COA_LTB, @IDX_COA_LD) --mod Anton 22 Mei 2017 --> dividen interim
			GROUP BY IDX_M_Company, IDX_M_Branch

	END

	--- Construct Base Final Query Account Balance (#FinAB)
	SELECT 	ISNULL(LPAB.IDX_M_Company, BS.IDX_M_Company) AS IDX_M_Organization,
			ISNULL(LPAB.IDX_M_Branch, BS.IDX_M_Branch) AS IDX_M_Branch,
			ISNULL(LPAB.IDX_M_COA, BS.IDX_M_COA) AS IDX_M_COA,
			CONVERT(DECIMAL(20,4),ISNULL(LPAB.BENDingBalance,0)) AS BBBalance,
			CONVERT(DECIMAL(20,4),ISNULL(BS.BDebetAmount, 0)) AS BDebetAmount,
			CONVERT(DECIMAL(20,4),ISNULL(BS.BCreditAmount, 0)) AS BCreditAmount,
			CONVERT(DECIMAL(20,4),ISNULL(LPAB.BEndingBalance,0) + ISNULL(BS.BDebetAmount,0) - ISNULL(BS.BCreditAmount,0)) AS BEndingBalance,
			CONVERT(DECIMAL(20,4),ISNULL(LPAB.TEndingBalance,0)) AS TBBalance,
			CONVERT(DECIMAL(20,4),ISNULL(BS.TDebetAmount, 0)) AS TDebetAmount,
			CONVERT(DECIMAL(20,4),ISNULL(BS.TCreditAmount, 0)) AS TCreditAmount,
			CONVERT(DECIMAL(20,4),ISNULL(LPAB.TEndingBalance,0) + ISNULL(BS.TDebetAmount,0) - ISNULL(BS.TCreditAmount,0)) AS TEndingBalance
			INTO #FinAB
	FROM #LPAB LPAB
	FULL OUTER JOIN  #BakedSource BS ON LPAB.IDX_M_Company = BS.IDX_M_Company AND 
										LPAB.IDX_M_Branch = BS.IDX_M_Branch AND 
										LPAB.IDX_M_COA = BS.IDX_M_COA 

	-- replace Begining Translation for foreign company --
	UPDATE #FinAB
	SET TBBalance = BBBalance * @RateEOM, TEndingBalance = (BBBalance * @RateEOM) + TDebetAmount - TCreditAmount
	FROM #FinAB FAB
		LEFT JOIN GL_M_COA MC on FAB.IDX_M_COA = MC.IDX_M_COA 
		LEFT JOIN MasterGlobalDB.dbo.M_GroupsCompany MGC on MGC.IDX_M_GroupsCompany = FAB.IDX_M_Organization
	WHERE MGC.Currency = 'USD' AND MC.TranslationRate = 'E'
	-------------------------------------------------------

	PRINT 'Construct Base Final Query Account Balance (#FinAB), Done'

	--- Exception for January
	--IF @Bulan = '01'
	--BEGIN
	--	PRINT 'Hit on January!'

	--	--- DELETE LD INSERT LD
	--	DELETE #FinAB
	--	WHERE IDX_M_COA = @IDX_COA_LD
	--	PRINT 'DELETE LD on #FinAB, Done'

	--	--- Calculate + INSERT LD on #FinAB
	--	INSERT INTO #FinAB (IDX_M_Organization, IDX_M_Branch, IDX_M_COA, BBBalance, BDebetAmount, BCreditAmount, BENDingBalance,
	--																	TBBalance, TDebetAmount, TCreditAmount, TENDingBalance)
	--	SELECT IDX_M_Organization, 
	--			IDX_M_Branch, 
	--			@IDX_COA_LD as IDX_M_COA, 
	--			sum(BENDingBalance) as BBBalance, 
	--			0 as BDebetAmount, 
	--			0 as BCreditAmount,
	--			sum(BENDingBalance) as BENDingBalance,
	--			sum(TENDingBalance) as TBBalance, 
	--			0 as TDebetAmount, 
	--			0 as TCreditAmount,
	--			sum(TENDingBalance) as TENDingBalance
	--	FROM #LPAB
	--	WHERE IDX_M_COA = @IDX_COA_LD or IDX_M_COA = @IDX_COA_LTB
	--	GROUP BY IDX_M_Organization, IDX_M_Branch
	--	PRINT 'Calculate + INSERT LD on #FinAB, Done'

	--	PRINT 'Exception For January, Done'
	--END
	--------------------------------------------------------------------------

	-- ==================================================
	-- Add by Febry, March 31, 2017
	-- If periode = 01 atau bulan pertama dari tahun fiskal
	-- maka saldo awal dari account pendapatan dan biaya (Semua COA yang termasuk dalam profit and loss
	-- harus di set = 0
	-- ==================================================
	IF @Bulan = '01'
	BEGIN
		PRINT 'Select COA in profit and loss'

		SELECT * FROM #FinAB
			INNER JOIN GL_M_COA COA ON #FinAB.IDX_M_COA = COA.IDX_M_COA
			INNER JOIN GL_M_COAType COATYPE ON COA.IDX_M_COAType = COATYPE.IDX_M_COAType
		--WHERE COATYPE.COATypeID IN ('IC','EX') or COA.IDX_M_COA = @IDX_COA_DI --mod Anton 22 Mei 2017 --> dividen interim
		WHERE COATYPE.COATypeID IN ('IC','EX')

		UPDATE #FinAB SET BBBalance = 0, TBBalance = 0
		FROM #FinAB  
			INNER JOIN GL_M_COA COA ON #FinAB.IDX_M_COA = COA.IDX_M_COA
			INNER JOIN GL_M_COAType COATYPE ON COA.IDX_M_COAType = COATYPE.IDX_M_COAType
		--WHERE COA.AccountType IN ('IC','EX') or COA.IDX_M_COA = @IDX_COA_DI --mod Anton 22 Mei 2017 --> dividen interim
		WHERE COATYPE.COATypeID IN ('IC','EX')

		UPDATE #FinAB SET BEndingBalance = BBBalance + (BDebetAmount - BCreditAmount), 
			TEndingBalance = TBBalance + (TDebetAmount - TCreditAmount)
		FROM #FinAB  
			INNER JOIN GL_M_COA COA ON #FinAB.IDX_M_COA = COA.IDX_M_COA
			INNER JOIN GL_M_COAType COATYPE ON COA.IDX_M_COAType = COATYPE.IDX_M_COAType
		--WHERE COA.AccountType IN ('IC','EX') or COA.IDX_M_COA = @IDX_COA_DI --mod Anton 22 Mei 2017 --> dividen interim
		WHERE COATYPE.COATypeID IN ('IC','EX')
	END
	-- ==================================================

	--- INSERT #FinAB to T_AccountBalance
	INSERT INTO GL_T_AccountBalance
								(JournalPeriod,
								IDX_M_Company,
								IDX_M_Department,
								IDX_M_Project,
								IDX_M_Branch,
								IDX_M_COA, 
								COADESCription,
								CurrencyID,
								BBBalance,
								BDebetAmount,
								BCreditAmount,
								BENDingBalance,
								TBBalance,
								TDebetAmount,
								TCreditAmount,
								TENDingBalance,
								Notes,
								UCreate,
								DCreate,
								RecordStatus)
	SELECT @speriode as JournalPeriod,
			FAB.IDX_M_Organization,
			0,
			0,
			FAB.IDX_M_Branch,
			FAB.IDX_M_COA,
			COA.COADesc,
			MGC.Currency as BaseCur,
			FAB.BBBalance,
			FAB.BDebetAmount,
			FAB.BCreditAmount,
			FAB.BENDingBalance,
			FAB.TBBalance,
			FAB.TDebetAmount,
			FAB.TCreditAmount,
			FAB.TENDingBalance,
			'Closing ' + @speriode as Notes,
			@UCreate as UCreate,
			getdate() as DCreate,
			'A' as RecordStatus
	FROM #FinAB FAB
		LEFT JOIN GL_M_COA COA on FAB.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN MasterGlobalDB.dbo.M_GroupsCompany MGC on MGC.IDX_M_GroupsCompany = FAB.IDX_M_Organization

	PRINT 'INSERT #FinAB to T_AccountBalance, Done'
	---------------------------------------

	



	COMMIT TRANSACTION TRANS_CM_ClosingPeriod

	GOTO exitsp
	
	Errorsp: ROLLBACK TRANSACTION TRANS_CM_ClosingPeriod

	exitsp: 

END



