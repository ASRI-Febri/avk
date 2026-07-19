USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Detail list for a header. Called via exec_sp (@IDX_T_PettyCashHeader)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashDetail_List]
    @IDX_T_PettyCashHeader BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        D.IDX_T_PettyCashDetail,
        D.IDX_T_PettyCashHeader,
        ISNULL(D.IDX_M_DocumentType, 0)       AS IDX_M_DocumentType,
        ISNULL(D.IDX_M_Partner, 0)            AS IDX_M_Partner,
        ISNULL(D.IDX_Reference, 0)            AS IDX_Reference,
        RTRIM(ISNULL(D.ReferenceNo, ''))      AS ReferenceNo,
        CONVERT(VARCHAR(10), D.TransactionDate, 120) AS TransactionDate,
        RTRIM(ISNULL(D.PartnerName, ''))      AS PartnerName,
        RTRIM(ISNULL(D.DetailDesc, ''))       AS DetailDesc,
        ISNULL(D.PettyCashAmount, 0)          AS PettyCashAmount,
        ISNULL(D.IDX_M_COA, 0)                AS IDX_M_COA,
        RTRIM(ISNULL(COA.COAID, ''))          AS COAID,
        RTRIM(ISNULL(COA.COADesc, ''))        AS COADesc,
        RTRIM(ISNULL(DT.DocumentTypeDesc, '')) AS DocumentTypeDesc,
        RTRIM(ISNULL(H.PettyCashStatus, 'O')) AS PettyCashStatus
    FROM CM_T_PettyCashDetail D WITH(NOLOCK)
        LEFT JOIN GN_M_DocumentType DT WITH(NOLOCK) ON D.IDX_M_DocumentType = DT.IDX_M_DocumentType
        LEFT JOIN CM_T_PettyCashHeader H WITH(NOLOCK) ON D.IDX_T_PettyCashHeader = H.IDX_T_PettyCashHeader
        LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON D.IDX_M_COA = COA.IDX_M_COA
    WHERE D.IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader
      AND D.RecordStatus = 'A'
    ORDER BY D.TransactionDate, D.IDX_T_PettyCashDetail;
END
GO
