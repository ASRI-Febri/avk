USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Header List for DataTables (server-side)
-- Positional parameters built by MyController::get_datatables + PettyCashController::inquiry_data
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCash_List]
    @Page           INT,
    @Row            INT,
    @SortBy         VARCHAR(50),
    @SortDir        VARCHAR(5),
    @ReturnType     CHAR(1),          -- 'R' = return records, 'C' = return count
    @IDX_M_Company  VARCHAR(50)  = '',
    @IDX_M_Branch   VARCHAR(50)  = '',
    @CompanyName    VARCHAR(250) = '',
    @TransactionID  VARCHAR(50)  = '',
    @TransactionDesc VARCHAR(450) = '',
    @OpeningDate    VARCHAR(50)  = '',
    @UserID         VARCHAR(50)  = ''
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH PettyCash AS
    (
        SELECT
            H.IDX_T_PettyCashHeader,
            H.IDX_M_Company,
            H.IDX_M_Branch,
            RTRIM(C.CompanyName)            AS CompanyName,
            RTRIM(H.TransactionID)          AS TransactionID,
            CONVERT(VARCHAR(10), H.OpeningDate, 120) AS OpeningDate,
            RTRIM(H.TransactionDesc)        AS TransactionDesc,
            RTRIM(ISNULL(U.UserName, ''))   AS CashierName,
            ISNULL(D.TotalAmount, 0)        AS TotalAmount,
            CASE H.PettyCashStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' ELSE 'Unknown' END AS StatusDesc
        FROM CM_T_PettyCashHeader H WITH(NOLOCK)
            LEFT JOIN GN_M_Company C  WITH(NOLOCK) ON H.IDX_M_Company = C.IDX_M_Company
            LEFT JOIN GN_M_Branch  B  WITH(NOLOCK) ON H.IDX_M_Branch  = B.IDX_M_Branch
            LEFT JOIN SM_M_User    U  WITH(NOLOCK) ON H.CashierID     = U.IDX_M_User
            LEFT JOIN (
                SELECT IDX_T_PettyCashHeader, SUM(PettyCashAmount) AS TotalAmount
                FROM CM_T_PettyCashDetail WITH(NOLOCK)
                WHERE RecordStatus = 'A'
                GROUP BY IDX_T_PettyCashHeader
            ) D ON H.IDX_T_PettyCashHeader = D.IDX_T_PettyCashHeader
        WHERE H.RecordStatus = 'A'
            AND (@IDX_M_Company  = '' OR H.IDX_M_Company = @IDX_M_Company)
            AND (@IDX_M_Branch   = '' OR H.IDX_M_Branch  = @IDX_M_Branch)
            AND (@CompanyName    = '' OR C.CompanyName    LIKE '%' + @CompanyName + '%')
            AND (@TransactionID  = '' OR H.TransactionID  LIKE '%' + @TransactionID + '%')
            AND (@TransactionDesc = '' OR H.TransactionDesc LIKE '%' + @TransactionDesc + '%')
            AND (@OpeningDate    = '' OR CONVERT(VARCHAR(10), H.OpeningDate, 120) LIKE '%' + @OpeningDate + '%')
            AND H.IDX_M_Branch IN (
                SELECT UB.IDX_M_Branch
                FROM SM_M_UserBranch UB WITH(NOLOCK)
                    INNER JOIN SM_M_User SU WITH(NOLOCK) ON UB.IDX_M_User = SU.IDX_M_User
                WHERE SU.LoginID = @UserID AND UB.RecordStatus = 'A'
            )
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY
            CASE WHEN @SortDir = 'asc'  AND @SortBy = 'TransactionID' THEN TransactionID END ASC,
            CASE WHEN @SortDir = 'desc' AND @SortBy = 'TransactionID' THEN TransactionID END DESC,
            IDX_T_PettyCashHeader DESC) AS RowNumber,
        *
    INTO #Result
    FROM PettyCash;

    IF @ReturnType = 'C'
    BEGIN
        SELECT COUNT(*) AS TotalRows FROM #Result;
        RETURN;
    END

    SELECT *
    FROM #Result
    WHERE RowNumber BETWEEN ((@Page - 1) * @Row) + 1 AND (@Page * @Row)
    ORDER BY RowNumber;
END
GO
