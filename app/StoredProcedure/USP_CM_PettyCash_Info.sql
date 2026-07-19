USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Header Info (single record). Called via MyController::get_detail_by_id (@IDX)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCash_Info]
    @IDX BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        H.IDX_T_PettyCashHeader,
        ISNULL(H.IDX_M_Company, '')             AS IDX_M_Company,
        H.IDX_M_Branch,
        ISNULL(H.IDX_M_FinancialAccount, '')    AS IDX_M_FinancialAccount,
        CONVERT(VARCHAR(10), H.OpeningDate, 120) AS OpeningDate,
        RTRIM(ISNULL(H.TransactionType, ''))    AS TransactionType,
        RTRIM(ISNULL(H.TransactionID, ''))      AS TransactionID,
        RTRIM(ISNULL(H.TransactionDesc, ''))    AS TransactionDesc,
        ISNULL(H.CashierID, 0)                  AS CashierID,
        RTRIM(ISNULL(H.PettyCashStatus, 'O'))   AS PettyCashStatus,
        CONVERT(VARCHAR(10), H.ClosingDate, 120) AS ClosingDate,
        RTRIM(ISNULL(H.ClosingBy, ''))          AS ClosingBy,
        RTRIM(ISNULL(H.ClosingNotes, ''))       AS ClosingNotes,
        RTRIM(ISNULL(H.UCreate, ''))            AS UCreate,
        RTRIM(ISNULL(H.RecordStatus, 'A'))      AS RecordStatus,
        RTRIM(ISNULL(C.CompanyName, ''))        AS CompanyDesc,
        RTRIM(ISNULL(B.BranchName, ''))         AS BranchName,
        RTRIM(ISNULL(U.UserName, ''))           AS CashierName,
        LTRIM(RTRIM(ISNULL(FA.FinancialAccountID, '') + ' - ' + ISNULL(FA.FinancialAccountDesc, ''))) AS FinancialAccountInfo,
        ISNULL(D.TotalAmount, 0)                AS TotalAmount,
        CASE H.PettyCashStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' ELSE 'Unknown' END AS StatusDesc
    FROM CM_T_PettyCashHeader H WITH(NOLOCK)
        LEFT JOIN GN_M_Company C WITH(NOLOCK) ON H.IDX_M_Company = C.IDX_M_Company
        LEFT JOIN GN_M_Branch  B WITH(NOLOCK) ON H.IDX_M_Branch  = B.IDX_M_Branch
        LEFT JOIN SM_M_User    U WITH(NOLOCK) ON H.CashierID     = U.IDX_M_User
        LEFT JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
        LEFT JOIN (
            SELECT IDX_T_PettyCashHeader, SUM(PettyCashAmount) AS TotalAmount
            FROM CM_T_PettyCashDetail WITH(NOLOCK)
            WHERE RecordStatus = 'A'
            GROUP BY IDX_T_PettyCashHeader
        ) D ON H.IDX_T_PettyCashHeader = D.IDX_T_PettyCashHeader
    WHERE H.IDX_T_PettyCashHeader = @IDX;
END
GO
