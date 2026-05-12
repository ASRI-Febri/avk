SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Receiving Item Header by ID
-- =============================================

-- EXEC [USP_MC_SalesOrder_Info] 3

CREATE PROCEDURE [dbo].[USP_MC_SalesOrder_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesOrder	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- CHECK Receive AMOUNT & STATUS
	DECLARE @_ReceiveAmount 		DECIMAL(18,2)	
	DECLARE @_SalesAmount 			DECIMAL(18,2)
	DECLARE @_ReceiveStatus 		VARCHAR(1) = 'N' -- Not Paid
	DECLARE @_ReceiveStatusDesc 	VARCHAR(20) = 'Belum Dibayar'

	SELECT @_ReceiveAmount = SUM(FPD.ReceiveAmount)	
	FROM CM_T_FinancialReceiveHeader FPH
	LEFT JOIN CM_T_FinancialReceiveDetail FPD 
		ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	LEFT JOIN MC_T_SalesOrder MH ON MH.IDX_M_DocumentType = FPD.IDX_M_DocumentType
		AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
		AND RTRIM(MH.SONumber) = RTRIM(FPD.DocumentNo)
	LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
	WHERE FPH.RecordStatus = 'A' AND FPD.RecordStatus = 'A' AND FPH.ReceiveStatus = 'A'
		AND FPD.IDX_DocumentNo = @IDX_T_SalesOrder	

	SELECT @_SalesAmount = SUM(POD.BaseCurrencyAmount)
	FROM MC_T_SalesOrderDetail POD 
	WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

	IF @_ReceiveAmount >= @_SalesAmount
	BEGIN
		SET @_ReceiveStatus = 'P' -- Paid		
		SET @_ReceiveStatusDesc = 'Lunas'
	END 

	IF @_ReceiveAmount < @_SalesAmount AND @_ReceiveAmount > 0	
	BEGIN
		SET @_ReceiveStatus = 'N' -- Not Paid		
		SET @_ReceiveStatusDesc = 'Belum Lunas'
	END 

    -- ==================================================================================================
    -- OUTPUT DATA
	-- ==================================================================================================
	SELECT [IDX_T_SalesOrder],SO.[IDX_M_Partner],SO.IDX_M_Company, SO.IDX_M_Branch,
		SO.IDX_M_DocumentType,
		SONumber,[SODate],[SONotes],SO.ReferenceNo,SOStatus, 
		SO.SOApprovalDate, SO.SOApprovalNotes, 
		SO.FundSource, SO.TransactionPurpose,
		SO.[UCreate],SO.[DCreate],SO.[UModified],SO.[DModified],SO.[RecordStatus],
		MP.PartnerID, MP.PartnerName, MP.SingleIdentityNumber,
		C.CompanyID, C.CompanyName, C.LegalAddress, C.Province, C.City, C.District, C.Subdistrict,
		C.Phone, C.WhatsappNo,
		B.BranchID, B.BranchName,
		TotalSalesAmount = @_SalesAmount, TotalReceiveAmount = @_ReceiveAmount,
		ReceiveStatus = @_ReceiveStatus, ReceiveStatusDesc = @_ReceiveStatusDesc,
		StatusDesc = CASE SO.SOStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' 
			WHEN 'C' THEN 'Void' WHEN 'V' THEN 'Validate' END, 
		SO.UCreate, U.Name AS UCreateName
	FROM MC_T_SalesOrder SO
	LEFT JOIN GN_M_Company C ON C.IDX_M_Company = SO.IDX_M_Company
	LEFT JOIN GN_M_Branch B ON B.IDX_M_Branch = SO.IDX_M_Branch
	LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = SO.IDX_M_Partner
	LEFT JOIN SM_M_User U ON U.LoginID = SO.UCreate
	WHERE SO.IDX_T_SalesOrder = @IDX_T_SalesOrder

END


GO
