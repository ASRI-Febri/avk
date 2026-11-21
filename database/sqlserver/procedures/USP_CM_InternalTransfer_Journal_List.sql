CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_Journal_List]
    @IDX_T_InternalTransferHeader   BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @_IDX_M_JournalType INT = 9   -- VERIFY (samakan dengan Approve)

    SELECT
        ISNULL(JH.ReferenceNo,'') AS VoucherNo,
        CONVERT(VARCHAR(10), JH.JournalDate, 120) AS JournalDate,
        'Internal Transfer' AS JournalType,
        COA.COAID, COA.COADesc,
        '' AS ProjectID,
        ISNULL(JD.RemarkDetail,'') AS JournalDesc,
        ISNULL(JD.RemarkDetail,'') AS RemarkDetail,
        ISNULL(JD.BDebetAmount,0) AS BDebetAmount,
        ISNULL(JD.BCreditAmount,0) AS BCreditAmount
    FROM GL_T_JournalHeader JH WITH(NOLOCK)
        INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
        INNER JOIN GL_M_COA COA WITH(NOLOCK) ON JD.IDX_M_COA = COA.IDX_M_COA
    WHERE JH.IDX_ReferenceNo = @IDX_T_InternalTransferHeader
        AND JH.IDX_M_JournalType = @_IDX_M_JournalType
        AND ISNULL(JH.RecordStatus,'A') = 'A'
        AND ISNULL(JD.RecordStatus,'A') = 'A'
    ORDER BY JD.BDebetAmount DESC, JD.IDX_T_JournalDetail
END
