

/* =====================================================================================
   4. SP: USP_CM_InternalTransfer_Info   (single record by id; @IDX from get_detail_by_id)
   ===================================================================================== */
-- EXEC [dbo].[USP_CM_InternalTransfer_Info] 1
CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_Info]
    @IDX    BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IT.IDX_T_InternalTransferHeader,
        IT.IDX_M_Company, IT.IDX_M_Branch, IT.IDX_M_DocumentType,
        IT.IDX_M_FromFinancialAccount, IT.IDX_M_ToFinancialAccount,
        IT.FromCOA, IT.ToCOA,
        IT.TransferID, IT.VoucherNoManual,
        CONVERT(VARCHAR(10), IT.TransferDate, 120) AS TransferDate,
        ISNULL(IT.TransferAmount,0) AS TransferAmount,
        IT.RemarkHeader, IT.TransferStatus,
        CONVERT(VARCHAR(10), IT.ApprovalDate, 120) AS ApprovalDate,
        IT.ApprovalRemark, IT.ApprovalBy,
        CONVERT(VARCHAR(10), IT.VoidDate, 120) AS VoidDate,
        IT.VoidReason, IT.VoidBy,
        IT.UCreate, IT.DCreate, IT.UModified, IT.DModified, IT.RecordStatus,
        StatusDesc = CASE IT.TransferStatus
            WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved'
            WHEN 'V' THEN 'Void' ELSE 'Unknown' END,
        C.CompanyID, C.CompanyName, C.CompanyName AS CompanyDesc,
        ISNULL(C.Phone,'') AS CompanyPhone,
        B.BranchID, B.BranchName,
        FA.FinancialAccountID AS FromAccountID, FA.FinancialAccountDesc AS FromAccountDesc,
        TA.FinancialAccountID AS ToAccountID,   TA.FinancialAccountDesc AS ToAccountDesc
    FROM CM_T_InternalTransferHeader IT WITH(NOLOCK)
        LEFT JOIN GN_M_Company C WITH(NOLOCK) ON C.IDX_M_Company = IT.IDX_M_Company
        LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON B.IDX_M_Branch = IT.IDX_M_Branch
        LEFT JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON FA.IDX_M_FinancialAccount = IT.IDX_M_FromFinancialAccount
        LEFT JOIN CM_M_FinancialAccount TA WITH(NOLOCK) ON TA.IDX_M_FinancialAccount = IT.IDX_M_ToFinancialAccount
    WHERE IT.IDX_T_InternalTransferHeader = @IDX
END
