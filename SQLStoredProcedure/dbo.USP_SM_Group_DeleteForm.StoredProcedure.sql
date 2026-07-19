USE [AVKDB]
GO
/****** Object:  StoredProcedure [dbo].[USP_SM_Group_DeleteForm] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 13 Jun 2026
-- Description:	Delete (revoke) a single form access for a group on SM_M_GroupForm.
--              HARD DELETE is used on purpose: both USP_SM_GroupForm_List and
--              MyController::check_permission do NOT filter SM_M_GroupForm.RecordStatus,
--              so a soft delete would neither hide the row nor revoke the access.
--              Mirrors the add side in USP_SM_Group_AddForm.
-- =============================================
/*
	SELECT * FROM SM_M_GroupForm
	BEGIN TRAN
	EXEC [dbo].[USP_SM_Group_DeleteForm] 1,'1406069','A'
	ROLLBACK TRAN
*/

CREATE OR ALTER PROCEDURE [dbo].[USP_SM_Group_DeleteForm]
	@IDX_M_GroupForm		BIGINT,
	------------------------------------------------
	@UserID					VARCHAR(50),
	@RecordStatus			CHAR(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),
			ID			BIGINT,
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog		AS INT
		DECLARE @_IDX_M_Group	AS BIGINT
		/*****************************/

		-- Resolve parent group (returned as ID so the caller reloads the correct group table)
		SELECT @_IDX_M_Group = IDX_M_Group
		FROM SM_M_GroupForm
		WHERE IDX_M_GroupForm = @IDX_M_GroupForm

		IF @_IDX_M_Group IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Group access not found!')
		END

		/** If no error occured **/
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			DELETE FROM SM_M_GroupForm
			WHERE IDX_M_GroupForm = @IDX_M_GroupForm

			-- OUTPUT (ID = IDX_M_Group so the page reloads this group's access table)
			INSERT INTO @TableLog VALUES ('success', @_IDX_M_Group, 'Data Sudah Disimpan')
		END

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())

		SELECT * FROM @TableLog

		-- Test XACT_STATE for 1 or -1.
		-- XACT_STATE = 0 means there is no transaction and
		-- a commit or rollback operation would generate an error.

		-- Test whether the transaction is uncommittable.
		IF (XACT_STATE()) = -1
		BEGIN
			PRINT N'The transaction is in an uncommittable state. ' + 'Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		-- Test whether the transaction is active and valid.
		IF (XACT_STATE()) = 1
		BEGIN
			PRINT N'The transaction is committable. ' + 'Committing transaction.'
			COMMIT TRANSACTION;
		END;

	END CATCH;

END
GO
