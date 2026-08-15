USE [AVKDB]
GO
/****** Object:  StoredProcedure [dbo].[USP_MC_PurchaseOrder_Info]    Script Date: 6/13/2026 2:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Receiving Item Header by ID
-- =============================================

-- EXEC [USP_MC_PurchaseOrder_Info] 4

IF OBJECT_ID('[dbo].[USP_MC_PurchaseOrder_Info]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_PurchaseOrder_Info]
GO

CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrder_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseOrder	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- CHECK PAYMENT AMOUNT & STATUS
	DECLARE @_PaymentAmount 		DECIMAL(18,2)	
	DECLARE @_PurchaseAmount 		DECIMAL(18,2)
	DECLARE @_PaymentStatus 		VARCHAR(1) = 'N' -- Not Paid
	DECLARE @_PaymentStatusDesc 	VARCHAR(20) = 'Belum Dibayar'

	SELECT @_PaymentAmount = SUM(FPD.PaymentAmount)	
	FROM CM_T_FinancialPaymentHeader FPH
	LEFT JOIN CM_T_FinancialPaymentDetail FPD 
		ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	LEFT JOIN MC_T_PurchaseOrder MH ON MH.IDX_M_DocumentType = FPD.IDX_M_DocumentType
		AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
		AND RTRIM(MH.PONumber) = RTRIM(FPD.DocumentNo)
	LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
	WHERE FPH.RecordStatus = 'A' AND FPD.RecordStatus = 'A' AND FPH.PaymentStatus = 'A'
		AND FPD.IDX_DocumentNo = @IDX_T_PurchaseOrder	

	SELECT @_PurchaseAmount = SUM(POD.BaseCurrencyAmount)
	FROM MC_T_PurchaseOrderDetail POD 
	WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

	IF @_PaymentAmount >= @_PurchaseAmount
	BEGIN
		SET @_PaymentStatus = 'P' -- Paid		
		SET @_PaymentStatusDesc = 'Lunas'
	END 

	IF @_PaymentAmount < @_PurchaseAmount AND @_PaymentAmount > 0	
	BEGIN
		SET @_PaymentStatus = 'N' -- Not Paid		
		SET @_PaymentStatusDesc = 'Belum Lunas'
	END 

	-- ==================================================================================================
    -- OUTPUT DATA
	-- ==================================================================================================
	SELECT [IDX_T_PurchaseOrder],PO.[IDX_M_Partner],PO.IDX_M_Company, PO.IDX_M_Branch,
		PONumber,[PODate],[PONotes],PO.ReferenceNo,POStatus, 
		PO.POApprovalDate, PO.POApprovalNotes, 
		PO.[UCreate],PO.[DCreate],PO.[UModified],PO.[DModified],PO.[RecordStatus],
		PO.FundSource, PO.TransactionPurpose,
		MP.PartnerID, MP.PartnerName, MP.SingleIdentityNumber,
		ISNULL(PA.Street,'') AS PartnerAddress,
        PA.IsDefault, 
		C.CompanyID, C.CompanyName, C.LegalAddress, C.Province, C.City, C.District, C.Subdistrict,
		C.Phone, C.WhatsappNo, B.BranchID, B.BranchName,
		TotalPurchaseAmount = @_PurchaseAmount, TotalPaymentAmount = @_PaymentAmount,
		PaymentStatus = @_PaymentStatus, PaymentStatusDesc = @_PaymentStatusDesc,
		StatusDesc = CASE PO.POStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' 
            WHEN 'C' THEN 'Void' WHEN 'V' THEN 'Validate' END
	FROM MC_T_PurchaseOrder PO
	LEFT JOIN GN_M_Company C ON C.IDX_M_Company = PO.IDX_M_Company
	LEFT JOIN GN_M_Branch B ON B.IDX_M_Branch = PO.IDX_M_Branch
	LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
    LEFT JOIN (SELECT IDX_M_PartnerAddress, IDX_M_Partner, Street, IsDefault 
                FROM GN_M_PartnerAddress 
                WHERE IsDefault = 'Y') PA ON PA.IDX_M_Partner = PO.IDX_M_Partner
	WHERE PO.IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

END



GO
