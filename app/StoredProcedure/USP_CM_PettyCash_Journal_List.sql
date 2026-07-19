USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Closing journal lines for a header. Called via exec_sp (@IDX_T_PettyCashHeader)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCash_Journal_List]
    @IDX_T_PettyCashHeader BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        JD.JournalSeqNo,
        RTRIM(ISNULL(COA.COAID, ''))   AS COAID,
        RTRIM(ISNULL(COA.COADesc, '')) AS COADesc,
        RTRIM(ISNULL(JD.RemarkDetail, '')) AS JournalDesc,
        ISNULL(JD.BDebetAmount, 0)     AS BDebetAmount,
        ISNULL(JD.BCreditAmount, 0)    AS BCreditAmount,
        RTRIM(ISNULL(JH.ReferenceNo, '')) AS ReferenceNo,
        CONVERT(VARCHAR(10), JH.JournalDate, 120) AS JournalDate,
        CASE JH.PostingStatus WHEN 'P' THEN 'Posted' WHEN 'U' THEN 'Unposted' ELSE 'Unknown' END AS PostingStatusDesc
    FROM GL_T_JournalHeader JH WITH(NOLOCK)
        INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
        LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON JD.IDX_M_COA = COA.IDX_M_COA
    WHERE JH.IDX_M_JournalType = 10
      AND JH.IDX_ReferenceNo = @IDX_T_PettyCashHeader
      AND JH.RecordStatus = 'A'
      AND JD.RecordStatus = 'A'
    ORDER BY JD.JournalSeqNo;
END
GO
