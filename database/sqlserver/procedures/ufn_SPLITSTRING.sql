



/* =============================================
Author			: Arnold Gunawan
Create date		: 19 May 2016
Description		: ufn for Split String with specific delimiter with CLR Method
					Based on http://sqlperformance.com/2012/07/t-sql-queries/split-strings
							 https://www.mssqltips.com/sqlservertip/1665/sql-server-clr-and-sql-split-functions-to-parse-a-delimited-string/
Samples			: 
	SELECT * FROM ufn_SPLITSTRING('1,5',',')
History			: 
1. 19 May 2016 - Arnold Gunawan - Initial Coding
-- ============================================= */
CREATE FUNCTION [dbo].[ufn_SPLITSTRING]
(	
	@List		VARCHAR(MAX),
	@Delimiter	VARCHAR(255)
)
RETURNS @ParsedString TABLE (Item VARCHAR(8000))
AS
BEGIN
	DECLARE		@Position INT
	SET		@Position = 1
	SET		@List = @List + @Delimiter
	WHILE	CHARINDEX(@Delimiter,@List,@position) <> 0
		BEGIN
			INSERT INTO @parsedString
			SELECT	SUBSTRING(@List, @position, CHARINDEX(@Delimiter,@List,@position) - @position)
			SET		@position = CHARINDEX(@Delimiter,@List,@position) + 1
		END
	RETURN
END






