-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 Oktober 2018
-- Description:	Inquiry Internal Transfer Detail by ID
-- =============================================

--EXEC USP_CM_InternalTransferDetail_List 7

CREATE PROCEDURE [dbo].[USP_CM_InternalTransferDetail_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_InternalTransferHeader		BIGINT = 0		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ITH.*, ITD.*, 
		MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		StatusDesc = CASE ITH.TransferStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, 
		COA.COAID, COA.COADesc, COA.COADesc2				
	FROM CM_T_InternalTransferDetail ITD	
		LEFT JOIN CM_T_InternalTransferHeader ITH ON ITD.IDX_T_InternalTransferHeader = ITH.IDX_T_InternalTransferHeader	
		LEFT JOIN GN_M_DocumentType MDT ON ITH.IDX_M_DocumentType = MDT.IDX_M_DocumentType	
		LEFT JOIN GL_M_COA COA ON ITD.COADetail = COA.IDX_M_COA		
	WHERE ITD.IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader 
	ORDER BY ITD.IDX_T_InternalTransferDetail DESC

END


