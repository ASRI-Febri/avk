SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Hak akses menu Rekening Koran (Finance), diberikan ke grup
--				ADMIN dan FINA.
--				  FM-BS-R : lihat daftar & detail rekening koran
--				  FM-BS-C : upload rekening koran
--				  FM-BS-J : buat jurnal dari rekening koran
--				  FM-BS-D : hapus rekening koran
--
--				Script boleh dijalankan berulang.
-- =============================================

DECLARE @Forms TABLE (FormID VARCHAR(50), FormName VARCHAR(100))
INSERT INTO @Forms VALUES
	('FM-BS-R', 'Rekening Koran Read'),
	('FM-BS-C', 'Upload Rekening Koran'),
	('FM-BS-J', 'Rekening Koran Create Journal'),
	('FM-BS-D', 'Rekening Koran Delete')

INSERT INTO SM_M_Form (IDX_M_Application, IDX_M_Module, FormID, FormName, FormURL, FormDescription,
					   IconClass1, IconClass2, IconClass3, ShowInSidebar, UCreate, DCreate, RecordStatus)
SELECT 1, 0, F.FormID, F.FormName, '-', F.FormName, '-', '-', '-', 'N', 'sa', GETDATE(), 'A'
FROM @Forms F
WHERE NOT EXISTS (SELECT 1 FROM SM_M_Form MF WHERE RTRIM(MF.FormID) = F.FormID)

INSERT INTO SM_M_GroupForm (IDX_M_Group, IDX_M_Form, UCreate, DCreate, RecordStatus)
SELECT G.IDX_M_Group, MF.IDX_M_Form, 'sa', GETDATE(), 'A'
FROM SM_M_Group G
	CROSS JOIN SM_M_Form MF
WHERE G.GroupID IN ('ADMIN', 'FINA')
	AND RTRIM(MF.FormID) IN (SELECT FormID FROM @Forms)
	AND NOT EXISTS (SELECT 1 FROM SM_M_GroupForm GF
					WHERE GF.IDX_M_Group = G.IDX_M_Group AND GF.IDX_M_Form = MF.IDX_M_Form)
GO
