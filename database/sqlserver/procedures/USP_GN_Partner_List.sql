/* =============================================
Author			: Samuel Febrianto
Create date		: 17 Mei 2018
Description		: Business Partner List for Financial Application

/*	
	EXEC [dbo].[USP_GN_Partner_List] 1,10,'IDX_M_Partner','asc','R','','angkasa','','','S',''
	EXEC [dbo].[USP_GN_Partner_List] 1,10,'RowNumber','asc','C','','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GN_Partner_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	 
	------------------------------------------------------------------------------
	@PartnerID				VARCHAR(50),
	@PartnerName			VARCHAR(50),	
	@BarcodeMember			VARCHAR(50),
	@SingleIdentityNumber	VARCHAR(50),
	@PartnerType			CHAR(1) = '', -- A = All, C = Customer, S = Supplier	
	@Street					VARCHAR(5000)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow					AS INT
	DECLARE @ToRow						AS INT
	DECLARE @_Sort1						AS VARCHAR(100)
	DECLARE @_Sort2						AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect					AS VARCHAR(5000)
	DECLARE @SqlFrom					AS VARCHAR(5000)
	DECLARE @SqlWhere					AS VARCHAR(5000)
	DECLARE @SqlLimit					AS VARCHAR(5000)
	DECLARE @SqlOrder					AS VARCHAR(5000)
	DECLARE @SqlAdditionalSearch		AS VARCHAR(5000)
	--------------------------------------------------------------
	DECLARE @_PartnerID					AS VARCHAR(50)
	DECLARE @_PartnerName				AS VARCHAR(50)
	DECLARE @_BarcodeMember				AS VARCHAR(50)
	DECLARE @_SingleIdentityNumber		AS VARCHAR(50)
	DECLARE @_Street					AS VARCHAR(5000)
	DECLARE @_PartnerTypeDesc			AS VARCHAR(50)	

	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir
	
	-- SET Paging and Row Number
	IF @Page = 1
	BEGIN
		SET @FromRow = 1
		SET @ToRow = @Row
	END

	IF @Page > 1
	BEGIN
		SET @FromRow = ((@Page * @Row) - @Row) + 1
		SET @ToRow = @FromRow + @Row - 1		
	END

	-- =================================================================================
	-- SET INPUT PARAMETER INTO SEARCH PARAMETER
	-- =================================================================================
	SET @_PartnerID = '%' + RTRIM(@PartnerID) + '%'
	SET @_PartnerName = '%' + RTRIM(@PartnerName) + '%'
	SET @_BarcodeMember = '%' + RTRIM(@BarcodeMember) + '%'
	SET @_SingleIdentityNumber = '%' + RTRIM(@SingleIdentityNumber) + '%'
	SET @_Street = '%' + RTRIM(@Street) + '%'
	
	IF RTRIM(@PartnerType) = 'A' OR RTRIM(@PartnerType) = '' -- ALL CUSTOMER & SUPPLIER
	BEGIN		
		SET @SqlAdditionalSearch = ''
	END

	IF RTRIM(@PartnerType) = 'C' -- CUSTOMER
	BEGIN		
		SET @SqlAdditionalSearch = ' AND ((RTRIM(ISNULL(BP.IsCustomer,'''')) = ''Y'' OR RTRIM(ISNULL(BP.IsMember,'''')) = ''Y'')) '
	END

	IF RTRIM(@PartnerType) = 'S' -- CUSTOMER
	BEGIN		
		SET @SqlAdditionalSearch = ' AND (RTRIM(ISNULL(BP.IsSupplier,''''))) = ''Y'''
	END

	-- =================================================================================
	-- CUSTOM SORT
	-- =================================================================================
	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'IDX_M_Partner'
	BEGIN
		SET @_Sort1 = ' BP.IDX_M_Partner ' + @SortDir
		SET @_Sort2 = ' BP.IDX_M_Partner ' + @SortDir
	END	

	-- =================================================================================
	-- SET SQL QUERY
	-- =================================================================================
	SET @SqlSelect = '	SELECT * FROM (
							SELECT 
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber, 
								BP.IDX_M_Partner, BP.BarcodeMember, BP.PartnerID, BP.PartnerName, ISNULL(BP.IsCustomer,'''') AS IsCustomer, 
								ISNULL(BP.IsMember,'''') AS IsMember, ISNULL(BP.IsSupplier,'''') AS IsSupplier, BP.SingleIdentityNumber,
								BP.TaxIdentityNumber, BP.MobilePhone, BP.Remarks, ISNULL(BPA.Street,'''') AS Street,
								ActiveDesc = CASE BP.ActiveStatus WHEN ''A'' THEN ''Active'' WHEN ''I'' THEN ''Inactive'' ELSE ''Inactive'' END,	
								StatusDesc = CASE BP.RecordStatus WHEN ''A'' THEN ''Active'' WHEN ''I'' THEN ''Inactive'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = '
					FROM GN_M_Partner BP
						LEFT JOIN (	SELECT IDX_M_PartnerAddress, IDX_M_Partner, Street 
									FROM GN_M_PartnerAddress
									WHERE ISNULL(IsDefault,'''') = ''Y'') BPA ON BP.IDX_M_Partner = BPA.IDX_M_Partner '

	SET @SqlWhere = 'WHERE ISNULL(PartnerName,'''')  LIKE ''' + @_PartnerName + 
						''' AND RTRIM(ISNULL(PartnerID,'''')) LIKE ''' + @_PartnerID + 
						''' AND RTRIM(ISNULL(BarcodeMember,'''')) LIKE ''' + @_BarcodeMember + 
						''' AND RTRIM(ISNULL(BPA.Street,'''')) LIKE ''' + @_Street + 
						''' AND RTRIM(ISNULL(SingleIdentityNumber,'''')) LIKE ''' + @_SingleIdentityNumber + '''' + @SqlAdditionalSearch

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	SET @SqlOrder = ''

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)		
	END


	--SELECT BP.IDX_GN_M_Partner, BP.BarcodeMember, BP.PartnerID, BP.PartnerName, BP.IsCustomer, BP.IsSupplier, BP.SingleIdentityNumber,
	--	BP.TaxIdentityNumber, BP.MobilePhone, BP.Remarks,  
	--	ActiveDesc = CASE BP.ActiveStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END,	
	--	StatusDesc = CASE BP.RecordStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END
	--FROM GN_M_Partner BP



    
	--IF @PartnerType = 'A'
	--BEGIN
	--	SELECT TOP 100 MBP.*,	
	--		ActiveDesc = CASE MBP.ActiveStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END,	
	--		StatusDesc = CASE MBP.RecordStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END
	--	FROM GN_M_Partner MBP 			
	--		--LEFT JOIN SM_M_User MU ON MBP.UCreate = MU.UserID
	--	WHERE RTRIM(MBP.PartnerID) LIKE RTRIM(@_PartnerID) AND RTRIM(MBP.PartnerName) LIKE RTRIM(@_PartnerName)
	--		AND RTRIM(ISNULL(MBP.BarcodeMember,'')) LIKE RTRIM(@_BarcodeMember)
	--		AND RTRIM(ISNULL(MBP.SingleIdentityNumber,'')) LIKE RTRIM(@_SingleIdentityNumber)					
	--	ORDER BY IDX_GN_M_Partner ASC
	--END

	--IF @PartnerType = 'C'
	--BEGIN
	--	SELECT TOP 100 MBP.*,	
	--		ActiveDesc = CASE MBP.ActiveStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END,	
	--		StatusDesc = CASE MBP.RecordStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END
	--	FROM GN_M_Partner MBP 			
	--		--LEFT JOIN SM_M_User MU ON MBP.UCreate = MU.UserID
	--	WHERE RTRIM(MBP.PartnerID) LIKE RTRIM(@_PartnerID) AND RTRIM(MBP.PartnerName) LIKE RTRIM(@_PartnerName)
	--		AND RTRIM(ISNULL(MBP.BarcodeMember,'')) LIKE RTRIM(@_BarcodeMember)
	--		AND RTRIM(ISNULL(MBP.SingleIdentityNumber,'')) LIKE RTRIM(@_SingleIdentityNumber)
	--		AND (RTRIM(ISNULL(MBP.IsCustomer,'')) = 'Y' OR RTRIM(ISNULL(MBP.IsMember,'')) = 'Y')
	--	ORDER BY IDX_GN_M_Partner ASC
	--END

	--IF @PartnerType = 'S'
	--BEGIN
	--	SELECT TOP 100 MBP.*,	
	--		ActiveDesc = CASE MBP.ActiveStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END,	
	--		StatusDesc = CASE MBP.RecordStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END
	--	FROM GN_M_Partner MBP 			
	--		--LEFT JOIN SM_M_User MU ON MBP.UCreate = MU.UserID
	--	WHERE RTRIM(MBP.PartnerID) LIKE RTRIM(@_PartnerID) AND RTRIM(MBP.PartnerName) LIKE RTRIM(@_PartnerName)
	--		AND RTRIM(ISNULL(MBP.BarcodeMember,'')) LIKE RTRIM(@_BarcodeMember)
	--		AND RTRIM(ISNULL(MBP.SingleIdentityNumber,'')) LIKE RTRIM(@_SingleIdentityNumber)
	--		AND RTRIM(ISNULL(MBP.IsSupplier,'')) = 'Y' 		
	--	ORDER BY IDX_GN_M_Partner ASC
	--END

END









