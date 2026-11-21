
/*	

	EXEC [dbo].[USP_CM_FakturNumber_Info]
		 1

*/
CREATE PROCEDURE [dbo].[USP_CM_FakturNumber_Info] 	
	-- Add the parameters for the stored procedure here
	@IDX_M_FakturNumber	BIGINT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	MFN.*, 
			SIH.InvoiceNo As TransactionNo

	FROM CM_M_FakturNumberLine MFN WITH (NOLOCK)
	LEFT JOIN CM_T_SalesInvoiceHeader SIH WITH (NOLOCK) ON MFN.IDX_T_Transaction=SIH.IDX_T_SalesInvoiceHeader

	WHERE MFN.IDX_M_FakturNumber = @IDX_M_FakturNumber
END
