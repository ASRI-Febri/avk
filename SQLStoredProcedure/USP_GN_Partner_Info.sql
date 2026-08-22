SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	20 Oktober 2016
-- Description	:	Get detail Business Partner
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add CreateByID, CreateByDate, CreateByName, ModifiedByID, ModifiedByDate, ModifiedByName Columns for LOG Tab
-- Mod			:	Samuel Febrianto, 22 Aug 2026
-- Mod Desc		:	Tambah IDX_M_IDType dan IDTypeName (alias jenis identitas).
-- =============================================

-- EXEC [USP_GN_Partner_Info] 1

IF OBJECT_ID('[dbo].[USP_GN_Partner_Info]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GN_Partner_Info]
GO

CREATE PROCEDURE [dbo].[USP_GN_Partner_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_Partner	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [IDX_M_Partner],[IDX_M_Parent],[Prefix],[PartnerID]
      ,[BarcodeMember]
      ,[PartnerName]
      ,[PartnerAlias]
      ,[Gender]
      ,[SingleIdentityNumber]
      ,[TaxIdentityNumber]
      ,[DateOfBirth]
      ,[PlaceOfBirth]
      ,MBP.[Email]
      ,[Phone1]
      ,[Phone2]
      ,[FaxNo]
      ,[MobilePhone]
      ,[Remarks]
      ,[IsSupplier]
      ,[IsCustomer]
      ,[IsCompany]
      ,[IsMember]
	  ,[IsDTTOT]
      ,[StartDate]
      ,[EndDate]
      ,[StartPeriod]
      ,[EndPeriod]
      ,[ARAccount]
      ,[APAccount]
      ,[ActiveStatus]
      ,[CreditLimit]
      ,[DiscountMember]
      ,[BankName]
      ,[BranchName]
      ,[BranchCode]
      ,[AccountNumber]
      ,[AccountName]
	  ,MBP.[IDX_M_IDType]
	  ,IDTypeName = RTRIM(ISNULL(IDT.Alias,''))
	  , 
	  ----------------------------------------------------
		MU.Name AS UserName,
		ARAccountDesc = AR.COAID + ' - ' + AR.COADesc,
		APAccountDesc = AP.COAID + ' - ' + AP.COADesc,
		-----------------------------------------------------
		MBP.UCreate AS CreateByID,
		MBP.DCreate AS CreateByDate,
		MU.Name AS CreateByName,
		------------------------------------------------------
		MBP.UModified AS ModifiedByID,
		MBP.DModified AS ModifiedByDate,
		MUM.Name AS ModifiedByName
	FROM GN_M_Partner MBP
	LEFT JOIN GL_M_COA AR ON MBP.ARAccount = AR.IDX_M_COA
	LEFT JOIN GL_M_COA AP ON MBP.APAccount = AP.IDX_M_COA
	LEFT JOIN SM_M_User MU ON MU.LoginID = MBP.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = MBP.UModified
	LEFT JOIN GN_M_IDType IDT ON IDT.IDX_M_IDType = MBP.IDX_M_IDType
	WHERE MBP.IDX_M_Partner = @IDX_M_Partner

END
GO
