USE [AVKDB]
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Schema additions required for GL journal posting (Option 2).
-- Header : IDX_M_FinancialAccount  -> the Petty Cash / Kas Kecil source account (CREDIT side)
-- Detail : IDX_M_COA               -> the expense (beban) account per line       (DEBIT side)
-- Safe to run multiple times.
-- =============================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.CM_T_PettyCashHeader') AND name = 'IDX_M_FinancialAccount')
BEGIN
    ALTER TABLE [dbo].[CM_T_PettyCashHeader] ADD [IDX_M_FinancialAccount] [bigint] NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.CM_T_PettyCashDetail') AND name = 'IDX_M_COA')
BEGIN
    ALTER TABLE [dbo].[CM_T_PettyCashDetail] ADD [IDX_M_COA] [bigint] NULL;
END
GO
