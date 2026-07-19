USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Detail Info (single record). Called via get_detail_by_id (@IDX)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashDetail_Info]
    @IDX BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        D.IDX_T_PettyCashDetail,
        D.IDX_T_PettyCashHeader,
        ISNULL(D.IDX_M_DocumentType, '')      AS IDX_M_DocumentType,
        ISNULL(D.IDX_M_COA, 0)                AS IDX_M_COA,
        ISNULL(D.IDX_M_Partner, 0)            AS IDX_M_Partner,
        ISNULL(D.IDX_Reference, 0)            AS IDX_Reference,
        RTRIM(ISNULL(D.ReferenceNo, ''))      AS ReferenceNo,
        CONVERT(VARCHAR(10), D.TransactionDate, 120) AS TransactionDate,
        RTRIM(ISNULL(D.PartnerName, ''))      AS PartnerName,
        RTRIM(ISNULL(D.DetailDesc, ''))       AS DetailDesc,
        ISNULL(D.PettyCashAmount, 0)          AS PettyCashAmount,
        RTRIM(ISNULL(COA.COAID, ''))          AS COAID,
        RTRIM(ISNULL(COA.COADesc, ''))        AS COADesc,
        LTRIM(RTRIM(ISNULL(COA.COAID, '') + ' - ' + ISNULL(COA.COADesc, ''))) AS COADesc1,
        RTRIM(ISNULL(D.RecordStatus, 'A'))    AS RecordStatus
    FROM CM_T_PettyCashDetail D WITH(NOLOCK)
        LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON D.IDX_M_COA = COA.IDX_M_COA
    WHERE D.IDX_T_PettyCashDetail = @IDX;
END
GO
