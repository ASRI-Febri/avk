
/*	
	EXEC [dbo].[USP_CM_FakturNumer_List]
		 1
		,10
		,'RowNumber'
		,'asc'
		,'R'
		
		
	EXEC [dbo].[USP_CM_FakturNumer_List]
		1
		,10
		,'RowNumber'
		,'asc'
		,'C'
		
	
*/
CREATE PROCEDURE [dbo].[USP_CM_FakturNumber_List] 	
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1) --R = Record, C = Count	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlFrom2				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' FN.IDX_M_FakturNumber ' + @SortDir
		SET @_Sort2 = ' IDX_M_FakturNumber ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'Period'
	BEGIN
		SET @_Sort1 = ' FN.PeriodFaktur ' + @SortDir
		SET @_Sort2 = ' PeriodFaktur ' + @SortDir
	END		

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

	SET @SqlSelect = '	SELECT * FROM (
							SELECT 
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber, 
								FN.IDX_M_FakturNumber, 
								FN.PeriodFaktur,
								FN.StatusFaktur, 
								
								MIN(FNL.FakturNumber) As StartingNo,
								MAX(FNL.FakturNumber) As EndingNo
								' 					
	
	SET @SqlFrom = 'FROM CM_M_FakturNumber FN
					LEFT JOIN CM_M_FakturNumberLine FNL ON FN.IDX_M_FakturNumber = FNL.IDX_M_FakturNumber '

	SET @SqlFrom2 = 'FROM CM_M_FakturNumber FN WHERE FN.RecordStatus= ''A''
					 '

	SET @SqlWhere = 'WHERE FN.RecordStatus = ''A''  
					GROUP BY FN.IDX_M_FakturNumber, FN.PeriodFaktur, FN.StatusFaktur
					'

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	--SET @SqlOrder = ' ORDER BY ' + @_Sort2

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom2)		
	END

END
