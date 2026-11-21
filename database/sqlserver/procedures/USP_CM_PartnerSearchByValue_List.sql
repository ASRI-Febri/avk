-- =============================================
-- Author:		Jonathan
-- Create date: 2023-05-17
-- Description:	Search Partner by value (for ajax searching)
-- =============================================

-- [USP_CM_PartnerSearchByValue_List] ''

CREATE PROCEDURE [dbo].[USP_CM_PartnerSearchByValue_List] 
	@SearchValue		VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SqlSelect			VARCHAR(1000)
	DECLARE @_SqlFrom			VARCHAR(1000)
	DECLARE @_SqlWhere			VARCHAR(1000)

	SET @SearchValue = '%' + RTRIM(@SearchValue) + '%'

    SET @_SqlSelect = '	SELECT BP.IDX_M_Partner, CONCAT(BP.PartnerID, '' - '', BP.PartnerName) AS PartnerName  ' 							
	
	SET @_SqlFrom = 'FROM GN_M_Partner BP '

	SET @_SqlWhere = 'WHERE BP.RecordStatus = ''A'' AND (
						RTRIM(ISNULL(BP.PartnerID,''''))  LIKE ''' + @SearchValue + ''' 
						OR RTRIM(ISNULL(BP.PartnerName,'''')) LIKE ''' + @SearchValue + ''')' 

	PRINT(@_SqlSelect + @_SqlFrom + @_SqlWhere)
	EXEC(@_SqlSelect + @_SqlFrom + @_SqlWhere)
END
