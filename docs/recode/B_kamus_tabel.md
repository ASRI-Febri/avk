# Lampiran B — Kamus Tabel

> Dihasilkan otomatis dari `sys.tables`/`sys.columns` database lokal `AVKDB` pada 2026-11-21. Jumlah baris = snapshot DB lokal (bukan produksi).
>
> Hanya ada 6 foreign key fisik: `GN_M_Partner.IDX_M_IDType` → `GN_M_IDType.IDX_M_IDType`, `CM_T_BankStatementDetail.IDX_T_BankStatementHeader` → `CM_T_BankStatementHeader.IDX_T_BankStatementHeader`, `CM_T_BankStatementAdjustment.IDX_T_BankStatementHeader` → `CM_T_BankStatementHeader.IDX_T_BankStatementHeader`, `CM_T_BankStatementMatch.IDX_T_BankStatementHeader` → `CM_T_BankStatementHeader.IDX_T_BankStatementHeader`, `MC_T_NotaScanDetail.IDX_T_MC_NotaScan` → `MC_T_NotaScan.IDX_T_MC_NotaScan`, `CM_T_BankStatementMatchDetail.IDX_T_BankStatementMatch` → `CM_T_BankStatementMatch.IDX_T_BankStatementMatch`. Semua relasi lain **implisit** (dijaga oleh SP).

| Tabel | Baris | PK | Dipakai oleh N SP |
|---|---:|---|---:|
| [`CM_M_CashflowID`](#cm_m_cashflowid) | 0 | IDX_M_CashflowID | 7 |
| [`CM_M_FakturNumber`](#cm_m_fakturnumber) | 0 | IDX_M_FakturNumber | 4 |
| [`CM_M_FakturNumberLine`](#cm_m_fakturnumberline) | 0 | — | 3 |
| [`CM_M_FinancialAccount`](#cm_m_financialaccount) | 5 | IDX_M_FinancialAccount | 45 |
| [`CM_T_BankStatementAdjustment`](#cm_t_bankstatementadjustment) | 42 | IDX_T_BankStatementAdjustment | 3 |
| [`CM_T_BankStatementDetail`](#cm_t_bankstatementdetail) | 1024 | IDX_T_BankStatementDetail | 13 |
| [`CM_T_BankStatementHeader`](#cm_t_bankstatementheader) | 3 | IDX_T_BankStatementHeader | 13 |
| [`CM_T_BankStatementMatch`](#cm_t_bankstatementmatch) | 9 | IDX_T_BankStatementMatch | 4 |
| [`CM_T_BankStatementMatchDetail`](#cm_t_bankstatementmatchdetail) | 27 | IDX_T_BankStatementMatchDetail | 3 |
| [`CM_T_FakturPajak`](#cm_t_fakturpajak) | 0 | — | 0 |
| [`CM_T_FinancialPaymentDetail`](#cm_t_financialpaymentdetail) | 2466 | IDX_T_FinancialPaymentDetail | 45 |
| [`CM_T_FinancialPaymentHeader`](#cm_t_financialpaymentheader) | 2466 | IDX_T_FinancialPaymentHeader | 47 |
| [`CM_T_FinancialPaymentLog`](#cm_t_financialpaymentlog) | 206 | IDX_T_FinancialPaymentLog | 4 |
| [`CM_T_FinancialReceiveDetail`](#cm_t_financialreceivedetail) | 1972 | IDX_T_FinancialReceiveDetail | 43 |
| [`CM_T_FinancialReceiveHeader`](#cm_t_financialreceiveheader) | 1972 | IDX_T_FinancialReceiveHeader | 41 |
| [`CM_T_FinancialReceiveLog`](#cm_t_financialreceivelog) | 1 | IDX_T_FinancialReceiveLog | 1 |
| [`CM_T_InternalTransferDetail`](#cm_t_internaltransferdetail) | 0 | IDX_T_InternalTransferDetail | 7 |
| [`CM_T_InternalTransferHeader`](#cm_t_internaltransferheader) | 46 | IDX_T_InternalTransferHeader | 11 |
| [`CM_T_InternalTransferLog`](#cm_t_internaltransferlog) | 52 | IDX_T_InternalTransferLog | 5 |
| [`CM_T_PaymentAllocation`](#cm_t_paymentallocation) | 0 | IDX_T_PaymentAllocation | 29 |
| [`CM_T_PettyCashDetail`](#cm_t_pettycashdetail) | 4 | IDX_T_PettyCashDetail | 8 |
| [`CM_T_PettyCashHeader`](#cm_t_pettycashheader) | 1 | IDX_T_PettyCashHeader | 10 |
| [`CM_T_PurchaseInvoiceDetail`](#cm_t_purchaseinvoicedetail) | 0 | IDX_T_PurchaseInvoiceDetail | 27 |
| [`CM_T_PurchaseInvoiceHeader`](#cm_t_purchaseinvoiceheader) | 0 | IDX_T_PurchaseInvoiceHeader | 31 |
| [`CM_T_PurchaseInvoiceTax`](#cm_t_purchaseinvoicetax) | 0 | IDX_T_PurchaseInvoiceTax | 16 |
| [`CM_T_PurchaseRefundDetail`](#cm_t_purchaserefunddetail) | 0 | IDX_T_PurchaseRefundDetail | 3 |
| [`CM_T_PurchaseRefundHeader`](#cm_t_purchaserefundheader) | 0 | IDX_T_PurchaseRefundHeader | 5 |
| [`CM_T_PurchaseRefundTax`](#cm_t_purchaserefundtax) | 0 | IDX_T_PurchaseRefundTax | 3 |
| [`CM_T_ReceiveAllocation`](#cm_t_receiveallocation) | 0 | IDX_T_ReceiveAllocation | 28 |
| [`CM_T_SalesInvoiceDetail`](#cm_t_salesinvoicedetail) | 0 | IDX_T_SalesInvoiceDetail | 24 |
| [`CM_T_SalesInvoiceHeader`](#cm_t_salesinvoiceheader) | 0 | IDX_T_SalesInvoiceHeader | 28 |
| [`CM_T_SalesInvoiceTax`](#cm_t_salesinvoicetax) | 0 | IDX_T_SalesInvoiceTax | 15 |
| [`CM_T_SalesRefundDetail`](#cm_t_salesrefunddetail) | 0 | IDX_T_SalesRefundDetail | 7 |
| [`CM_T_SalesRefundHeader`](#cm_t_salesrefundheader) | 0 | IDX_T_SalesRefundHeader | 10 |
| [`CM_T_SalesRefundTax`](#cm_t_salesrefundtax) | 0 | IDX_T_SalesRefundTax | 4 |
| [`CM_T_TaxInvoiceDetail`](#cm_t_taxinvoicedetail) | 0 | IDX_T_TaxInvoiceDetail | 0 |
| [`CM_T_TaxInvoiceHeader`](#cm_t_taxinvoiceheader) | 0 | IDX_T_TaxInvoiceHeader | 0 |
| [`FA_M_Asset`](#fa_m_asset) | 0 | IDX_M_Asset | 13 |
| [`FA_M_AssetCategory`](#fa_m_assetcategory) | 2 | IDX_M_AssetCategory | 10 |
| [`FA_T_Depreciation`](#fa_t_depreciation) | 0 | IDX_T_Depreciation | 11 |
| [`FA_T_DepreciationDetail`](#fa_t_depreciationdetail) | 0 | IDX_T_DepreciationDetail | 11 |
| [`GL_M_COA`](#gl_m_coa) | 159 | IDX_M_COA | 97 |
| [`GL_M_COACategory`](#gl_m_coacategory) | 9 | IDX_M_COACategory | 1 |
| [`GL_M_COAGroup1`](#gl_m_coagroup1) | 36 | IDX_M_COAGroup1 | 7 |
| [`GL_M_COAGroup2`](#gl_m_coagroup2) | 0 | IDX_M_COAGroup2 | 4 |
| [`GL_M_COAGroup3`](#gl_m_coagroup3) | 0 | IDX_M_COAGroup3 | 3 |
| [`GL_M_COAType`](#gl_m_coatype) | 5 | IDX_M_COAType | 6 |
| [`GL_M_FiscalPeriod`](#gl_m_fiscalperiod) | 0 | IDX_M_FiscalPeriod | 20 |
| [`GL_M_JournalType`](#gl_m_journaltype) | 11 | IDX_M_JournalType | 24 |
| [`GL_M_RecurringJournal`](#gl_m_recurringjournal) | 1 | IDX_M_RecurringJournal | 4 |
| [`GL_M_Tax`](#gl_m_tax) | 0 | IDX_M_Tax | 22 |
| [`GL_T_AccountBalance`](#gl_t_accountbalance) | 0 | IDX_GL_T_AccountBalance | 5 |
| [`GL_T_JournalCashflow`](#gl_t_journalcashflow) | 0 | IDX_T_JournalCashflow | 0 |
| [`GL_T_JournalDetail`](#gl_t_journaldetail) | 32093 | IDX_T_JournalDetail | 75 |
| [`GL_T_JournalHeader`](#gl_t_journalheader) | 10438 | IDX_T_JournalHeader | 91 |
| [`GL_T_JournalHeaderLog`](#gl_t_journalheaderlog) | 224 | IDX_T_JournalHeaderLog | 8 |
| [`GL_T_ReconcileDetail`](#gl_t_reconciledetail) | 0 | IDX_GL_T_ReconcileDetail | 0 |
| [`GL_T_ReconcileHeader`](#gl_t_reconcileheader) | 0 | IDX_GL_T_ReconcileHeader | 0 |
| [`GL_T_RecurringJournalLog`](#gl_t_recurringjournallog) | 4 | IDX_T_RecurringJournalLog | 2 |
| [`GN_M_AddressType`](#gn_m_addresstype) | 3 | IDX_M_AddressType | 3 |
| [`GN_M_Bank`](#gn_m_bank) | 2 | IDX_M_Bank | 5 |
| [`GN_M_BankCardPattern`](#gn_m_bankcardpattern) | 0 | IDX_M_CardPattern | 1 |
| [`GN_M_BankCardType`](#gn_m_bankcardtype) | 0 | IDX_M_CardType | 1 |
| [`GN_M_BankMerchant`](#gn_m_bankmerchant) | 0 | IDX_M_BankMerchant | 0 |
| [`GN_M_Branch`](#gn_m_branch) | 2 | IDX_M_Branch | 76 |
| [`GN_M_BusinessType`](#gn_m_businesstype) | 0 | IDX_M_BusinessType | 0 |
| [`GN_M_Company`](#gn_m_company) | 1 | IDX_M_Company | 36 |
| [`GN_M_Country`](#gn_m_country) | 26 | IDX_M_Country | 4 |
| [`GN_M_Currency`](#gn_m_currency) | 19 | IDX_M_Currency | 20 |
| [`GN_M_CurrencyRate`](#gn_m_currencyrate) | 0 | IDX_M_CurrencyRate | 0 |
| [`GN_M_Department`](#gn_m_department) | 4 | IDX_M_Department | 4 |
| [`GN_M_DocumentType`](#gn_m_documenttype) | 13 | IDX_M_DocumentType | 31 |
| [`GN_M_DTTOT`](#gn_m_dttot) | 531 | IDX_M_DTTOT | 3 |
| [`GN_M_Gender`](#gn_m_gender) | 2 | IDX_M_Gender | 0 |
| [`GN_M_Global`](#gn_m_global) | 0 | IDX_M_Global | 0 |
| [`GN_M_IDType`](#gn_m_idtype) | 5 | IDX_M_IDType | 2 |
| [`GN_M_Membership`](#gn_m_membership) | 0 | IDX_M_Membership | 0 |
| [`GN_M_MemberType`](#gn_m_membertype) | 0 | IDX_M_MemberType | 0 |
| [`GN_M_Menu`](#gn_m_menu) | 0 | IDX_M_Menu | 0 |
| [`GN_M_Partner`](#gn_m_partner) | 2609 | IDX_M_Partner | 67 |
| [`GN_M_Partner_MergeBackup_20260815`](#gn_m_partner_mergebackup_20260815) | 4 | — | 0 |
| [`GN_M_PartnerAccountHistory`](#gn_m_partneraccounthistory) | 0 | IDX_M_PartnerAccountHistory | 0 |
| [`GN_M_PartnerAddress`](#gn_m_partneraddress) | 2275 | IDX_M_PartnerAddress | 16 |
| [`GN_M_PartnerAddress_MergeBackup_20260815`](#gn_m_partneraddress_mergebackup_20260815) | 4 | — | 0 |
| [`GN_M_PartnerBank`](#gn_m_partnerbank) | 7 | IDX_M_PartnerBank | 4 |
| [`GN_M_PartnerContact`](#gn_m_partnercontact) | 0 | IDX_M_PartnerContact | 0 |
| [`GN_M_PartnerImage`](#gn_m_partnerimage) | 0 | IDX_M_PartnerImage | 0 |
| [`GN_M_PartnerTitle`](#gn_m_partnertitle) | 0 | IDX_M_PartnerTitle | 0 |
| [`GN_M_PartnerType`](#gn_m_partnertype) | 0 | IDX_M_PartnerType | 0 |
| [`GN_M_PaymentTerms`](#gn_m_paymentterms) | 0 | IDX_M_PaymentTerms | 0 |
| [`GN_M_PaymentType`](#gn_m_paymenttype) | 0 | IDX_M_PaymentType | 2 |
| [`GN_M_PostalCode`](#gn_m_postalcode) | 82712 | IDX_M_PostalCode | 7 |
| [`GN_M_Project`](#gn_m_project) | 1 | IDX_M_Project | 28 |
| [`GN_M_PurchaseType`](#gn_m_purchasetype) | 0 | IDX_M_PurchaseType | 0 |
| [`GN_M_Religion`](#gn_m_religion) | 0 | IDX_M_Religion | 0 |
| [`GN_M_SalesPerson`](#gn_m_salesperson) | 0 | IDX_M_SalesPerson | 3 |
| [`GN_M_SalesTeam`](#gn_m_salesteam) | 0 | IDX_M_SalesTeam | 0 |
| [`GN_M_ShippingTerms`](#gn_m_shippingterms) | 0 | IDX_M_ShippingTerms | 0 |
| [`GN_M_TransactionType`](#gn_m_transactiontype) | 0 | IDX_M_TransactionType | 0 |
| [`GN_M_Voucher`](#gn_m_voucher) | 0 | IDX_M_Voucher | 0 |
| [`GN_M_VoucherLine`](#gn_m_voucherline) | 0 | IDX_M_VoucherLine | 0 |
| [`GN_T_Attachment`](#gn_t_attachment) | 0 | IDX_T_Attachment | 4 |
| [`MC_M_Currency`](#mc_m_currency) | 26 | IDX_M_Currency | 39 |
| [`MC_M_TransactionType`](#mc_m_transactiontype) | 5 | IDX_M_TransactionType | 9 |
| [`MC_M_Valas`](#mc_m_valas) | 143 | IDX_M_Valas | 38 |
| [`MC_M_ValasChange`](#mc_m_valaschange) | 19 | IDX_M_ValasChange | 30 |
| [`MC_T_BIMiddleRate`](#mc_t_bimiddlerate) | 182 | IDX_T_BIMiddleRate | 4 |
| [`MC_T_BIMonthly`](#mc_t_bimonthly) | 154 | IDX_T_BIMonthly | 4 |
| [`MC_T_COGSCalculation`](#mc_t_cogscalculation) | 16 | IDX_T_COGSCalculation | 3 |
| [`MC_T_COGSValasCalculation`](#mc_t_cogsvalascalculation) | 995 | IDX_T_COGSValasCalculation | 9 |
| [`MC_T_CurrencyRateHistory`](#mc_t_currencyratehistory) | 0 | IDX_T_CurrencyRateHistory | 2 |
| [`MC_T_InventoryCalculation`](#mc_t_inventorycalculation) | 321 | IDX_T_InventoryCalculation | 2 |
| [`MC_T_KursBI`](#mc_t_kursbi) | 0 | IDX_T_KursBI | 2 |
| [`MC_T_LTKM`](#mc_t_ltkm) | 0 | IDX_T_LTKM | 4 |
| [`MC_T_LTKT`](#mc_t_ltkt) | 0 | IDX_T_LTKT | 3 |
| [`MC_T_NotaScan`](#mc_t_notascan) | 0 | IDX_T_MC_NotaScan | 4 |
| [`MC_T_NotaScanDetail`](#mc_t_notascandetail) | 0 | IDX_T_MC_NotaScanDetail | 4 |
| [`MC_T_OpenCloseDaily`](#mc_t_openclosedaily) | 1 | IDX_T_OpenCloseDaily | 7 |
| [`MC_T_OpenCloseDailyDetail`](#mc_t_openclosedailydetail) | 130 | IDX_T_OpenCloseDailyDetail | 7 |
| [`MC_T_POSValas`](#mc_t_posvalas) | 0 | IDX_T_POSValas | 0 |
| [`MC_T_POSValasDetail`](#mc_t_posvalasdetail) | 0 | IDX_T_POSValasDetail | 0 |
| [`MC_T_PurchaseOrder`](#mc_t_purchaseorder) | 2349 | IDX_T_PurchaseOrder | 33 |
| [`MC_T_PurchaseOrderDetail`](#mc_t_purchaseorderdetail) | 4739 | IDX_T_PurchaseOrderDetail | 23 |
| [`MC_T_PurchaseOrderTax`](#mc_t_purchaseordertax) | 0 | IDX_T_PurchaseOrderTax | 0 |
| [`MC_T_PurchaseOrderUpload`](#mc_t_purchaseorderupload) | 4527 | IDX_T_PurchaseOrderUpload | 2 |
| [`MC_T_SalesOrder`](#mc_t_salesorder) | 1855 | IDX_T_SalesOrder | 40 |
| [`MC_T_SalesOrderDetail`](#mc_t_salesorderdetail) | 4215 | IDX_T_SalesOrderDetail | 28 |
| [`MC_T_SalesOrderUpload`](#mc_t_salesorderupload) | 4448 | IDX_T_SalesOrderUpload | 2 |
| [`MC_T_StockCardValas`](#mc_t_stockcardvalas) | 8944 | IDX_T_StockCardValas | 11 |
| [`PR_T_PurchaseOrderTax`](#pr_t_purchaseordertax) | 0 | IDX_T_PurchaseOrderTax | 0 |
| [`SM_M_Application`](#sm_m_application) | 2 | IDX_M_Application | 4 |
| [`SM_M_Form`](#sm_m_form) | 141 | IDX_M_Form | 12 |
| [`SM_M_Group`](#sm_m_group) | 6 | IDX_M_Group | 10 |
| [`SM_M_GroupForm`](#sm_m_groupform) | 235 | IDX_M_GroupForm | 8 |
| [`SM_M_Module`](#sm_m_module) | 1 | IDX_M_Module | 1 |
| [`SM_M_Position`](#sm_m_position) | 0 | IDX_M_Position | 0 |
| [`SM_M_RoleAction`](#sm_m_roleaction) | 0 | — | 0 |
| [`SM_M_RolePosition`](#sm_m_roleposition) | 0 | IDX_M_RolePosition | 0 |
| [`SM_M_User`](#sm_m_user) | 17 | IDX_M_User | 41 |
| [`SM_M_UserBranch`](#sm_m_userbranch) | 19 | IDX_M_UserBranch | 5 |
| [`SM_M_UserCompany`](#sm_m_usercompany) | 0 | IDX_M_UserCompany | 0 |
| [`SM_M_UserDepartment`](#sm_m_userdepartment) | 0 | IDX_M_UserDepartment | 1 |
| [`SM_M_UserGroup`](#sm_m_usergroup) | 19 | IDX_M_UserGroup | 5 |
| [`SM_M_UserProject`](#sm_m_userproject) | 0 | IDX_M_UserProject | 3 |
| [`SM_T_CustomerResetPassword`](#sm_t_customerresetpassword) | 0 | IDX_T_CustomerResetPassword | 3 |
| [`SM_T_RolePosition`](#sm_t_roleposition) | 0 | IDX_T_RolePosition | 0 |
| [`SM_T_Session`](#sm_t_session) | 0 | SessionID | 0 |
| [`SM_T_SessionHistory`](#sm_t_sessionhistory) | 0 | IDX_T_SessionHistory | 0 |
| [`X_PostalCode`](#x_postalcode) | 65535 | — | 0 |
| [`X_PostalCodeAll`](#x_postalcodeall) | 17177 | — | 0 |

### CM_M_CashflowID

Baris: 0 · PK: IDX_M_CashflowID

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_CashflowID` | bigint | N | IDENTITY |
| 2 | `IDX_ParentCashflowID` | bigint | N |  |
| 3 | `CategoryType` | char(1) | N |  |
| 4 | `CashflowID` | varchar(10) | N |  |
| 5 | `CashflowDesc` | varchar(200) | Y |  |
| 6 | `InFlag` | bit | Y |  |
| 7 | `OutFlag` | bit | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UCreate` | varchar(50) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `UModified` | varchar(50) | Y |  |
| 12 | `RecordStatus` | char(1) | Y |  |

Dipakai oleh: `USP_CM_CashflowID_Create`, `USP_CM_CashflowID_Info`, `USP_CM_CashflowID_Update`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_R_Cashflow`, `USP_GL_COA_Info`

### CM_M_FakturNumber

Baris: 0 · PK: IDX_M_FakturNumber

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_FakturNumber` | bigint | N | IDENTITY |
| 2 | `PeriodFaktur` | varchar(6) | N |  |
| 3 | `StatusFaktur` | varchar(8) | N |  |
| 4 | `DCreate` | datetime | Y |  |
| 5 | `UCreate` | varchar(50) | Y |  |
| 6 | `DModified` | datetime | Y |  |
| 7 | `UModified` | varchar(50) | Y |  |
| 8 | `RecordStatus` | varchar(50) | Y |  |

Dipakai oleh: `USP_CM_FakturNumber_ClosePeriod`, `USP_CM_FakturNumber_Create`, `USP_CM_FakturNumber_Info2`, `USP_CM_FakturNumber_OpenPeriod`

### CM_M_FakturNumberLine

Baris: 0 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_FakturNumberLine` | bigint | N | IDENTITY |
| 2 | `IDX_M_FakturNumber` | bigint | N |  |
| 3 | `FakturNumber` | varchar(32) | N |  |
| 4 | `isUsed` | bit | Y |  |
| 5 | `IDX_T_Transaction` | bigint | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(50) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(50) | Y |  |
| 10 | `RecordStatus` | varchar(50) | Y |  |

Dipakai oleh: `USP_CM_FakturNumber_Info`, `USP_CM_FakturNumber_Line_Create`, `USP_CM_SalesInvoice_Approve`

### CM_M_FinancialAccount

Baris: 5 · PK: IDX_M_FinancialAccount

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_FinancialAccount` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | Y |  |
| 4 | `IDX_M_Bank` | bigint | Y |  |
| 5 | `IDX_M_Currency` | int | Y |  |
| 6 | `IDX_M_COA` | bigint | Y |  |
| 7 | `FinancialAccountID` | varchar(50) | Y |  |
| 8 | `FinancialAccountDesc` | varchar(50) | Y |  |
| 9 | `FinancialAccountType` | char(1) | Y |  |
| 10 | `AccountName` | varchar(50) | Y |  |
| 11 | `AccountNo` | varchar(50) | Y |  |
| 12 | `isUsedByPOS` | bit | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_CreateAdminFeeJournal`, `USP_CM_BankStatement_CreateJournal`, `USP_CM_BankStatement_CreateMergedJournal`, `USP_CM_BankStatement_CreateMonthEndJournal`, `USP_CM_BankStatement_Info`, `USP_CM_BankStatement_LedgerBalance`, `USP_CM_BankStatement_LedgerLines`, `USP_CM_BankStatement_List`, `USP_CM_BankStatement_Match_Save`, `USP_CM_BankStatement_Save`, `USP_CM_FinancialAccount_Create`, `USP_CM_FinancialAccount_Info`, `USP_CM_FinancialAccount_Update`, `USP_CM_FinancialPaymentHeader_Create`, `USP_CM_FinancialPaymentHeader_Update`, `USP_CM_FinancialPayment_Approve`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Info`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialReceiveHeader_Create`, `USP_CM_FinancialReceiveHeader_Update`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Info`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_InternalTransfer_Info`, `USP_CM_InternalTransfer_Validate`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Info`, `USP_CM_R_BankTransfer_Period`, `USP_CM_R_Cashflow`, `USP_CM_R_CashflowBank`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_FinancialReceive_Period`, `USP_CM_SalesInvoice_Payment`, `USP_MC_PurchaseOrderPayment_List`, `USP_MC_PurchaseOrder_Info`, `USP_MC_R_AP`, `USP_MC_R_AR`, `USP_MC_SalesOrderPayment_List`, `USP_MC_SalesOrder_Info`

### CM_T_BankStatementAdjustment

Baris: 42 · PK: IDX_T_BankStatementAdjustment

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BankStatementAdjustment` | bigint | N | IDENTITY |
| 2 | `IDX_T_BankStatementHeader` | bigint | N |  |
| 3 | `IDX_T_JournalHeader` | bigint | N |  |
| 4 | `SourceType` | char(1) | N |  |
| 5 | `SourceID` | bigint | N |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_AdjustmentLinks`, `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_Match_Save`

### CM_T_BankStatementDetail

Baris: 1024 · PK: IDX_T_BankStatementDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BankStatementDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_BankStatementHeader` | bigint | N |  |
| 3 | `SeqNo` | int | N |  |
| 4 | `PostingDate` | datetime | N |  |
| 5 | `Remark` | varchar(1000) | Y |  |
| 6 | `ReferenceNo` | varchar(100) | Y |  |
| 7 | `DebitAmount` | decimal(22,4) | N |  |
| 8 | `CreditAmount` | decimal(22,4) | N |  |
| 9 | `Balance` | decimal(22,4) | N |  |
| 10 | `IsAdminFee` | bit | N |  |
| 11 | `IDX_T_JournalHeader` | bigint | Y |  |
| 12 | `UCreate` | varchar(36) | Y |  |
| 13 | `DCreate` | datetime | Y |  |
| 14 | `UModified` | varchar(36) | Y |  |
| 15 | `DModified` | datetime | Y |  |
| 16 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatementDetail_List`, `USP_CM_BankStatementDetail_SetAdminFee`, `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_CreateAdminFeeJournal`, `USP_CM_BankStatement_CreateJournal`, `USP_CM_BankStatement_CreateMergedJournal`, `USP_CM_BankStatement_CreateMonthEndJournal`, `USP_CM_BankStatement_Delete`, `USP_CM_BankStatement_Info`, `USP_CM_BankStatement_List`, `USP_CM_BankStatement_Match_Save`, `USP_CM_BankStatement_MonthEndRows`, `USP_CM_BankStatement_Save`

### CM_T_BankStatementHeader

Baris: 3 · PK: IDX_T_BankStatementHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BankStatementHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_FinancialAccount` | bigint | N |  |
| 5 | `StatementNo` | varchar(50) | N |  |
| 6 | `BankName` | varchar(50) | Y |  |
| 7 | `AccountNo` | varchar(50) | Y |  |
| 8 | `AccountName` | varchar(100) | Y |  |
| 9 | `CurrencyID` | varchar(3) | Y |  |
| 10 | `PeriodStart` | date | N |  |
| 11 | `PeriodEnd` | date | N |  |
| 12 | `OpeningBalance` | decimal(22,4) | N |  |
| 13 | `ClosingBalance` | decimal(22,4) | N |  |
| 14 | `TotalDebit` | decimal(22,4) | N |  |
| 15 | `TotalCredit` | decimal(22,4) | N |  |
| 16 | `FileName` | varchar(255) | Y |  |
| 17 | `Notes` | varchar(500) | Y |  |
| 18 | `UCreate` | varchar(36) | Y |  |
| 19 | `DCreate` | datetime | Y |  |
| 20 | `UModified` | varchar(36) | Y |  |
| 21 | `DModified` | datetime | Y |  |
| 22 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_CreateAdminFeeJournal`, `USP_CM_BankStatement_CreateJournal`, `USP_CM_BankStatement_CreateMergedJournal`, `USP_CM_BankStatement_CreateMonthEndJournal`, `USP_CM_BankStatement_Delete`, `USP_CM_BankStatement_Info`, `USP_CM_BankStatement_InsertJournal`, `USP_CM_BankStatement_LedgerBalance`, `USP_CM_BankStatement_LedgerLines`, `USP_CM_BankStatement_List`, `USP_CM_BankStatement_Match_Save`, `USP_CM_BankStatement_Save`

### CM_T_BankStatementMatch

Baris: 9 · PK: IDX_T_BankStatementMatch

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BankStatementMatch` | bigint | N | IDENTITY |
| 2 | `IDX_T_BankStatementHeader` | bigint | N |  |
| 3 | `UCreate` | varchar(36) | Y |  |
| 4 | `DCreate` | datetime | Y |  |
| 5 | `UModified` | varchar(36) | Y |  |
| 6 | `DModified` | datetime | Y |  |
| 7 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_MatchLinks`, `USP_CM_BankStatement_Match_Delete`, `USP_CM_BankStatement_Match_Save`

### CM_T_BankStatementMatchDetail

Baris: 27 · PK: IDX_T_BankStatementMatchDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BankStatementMatchDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_BankStatementMatch` | bigint | N |  |
| 3 | `SourceType` | char(1) | N |  |
| 4 | `SourceID` | bigint | N |  |

Dipakai oleh: `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_MatchLinks`, `USP_CM_BankStatement_Match_Save`

### CM_T_FakturPajak

Baris: 0 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_Faktur` | bigint | N | IDENTITY |
| 2 | `IDX_T_Transaction` | bigint | Y |  |
| 3 | `TransactionType` | varchar(50) | Y |  |
| 4 | `KodeTransaksi` | varchar(50) | Y |  |
| 5 | `FakturPengganti` | int | Y |  |
| 6 | `NomorFaktur` | varchar(50) | Y |  |
| 7 | `TanggalFaktur` | date | Y |  |
| 8 | `MasaPajak` | varchar(50) | Y |  |
| 9 | `TahunPajak` | varchar(50) | Y |  |
| 10 | `StatusPajak` | varchar(50) | Y |  |
| 11 | `DCreate` | datetime | Y |  |
| 12 | `UCreate` | varchar(50) | Y |  |
| 13 | `RecordStatus` | varchar(50) | Y |  |

### CM_T_FinancialPaymentDetail

Baris: 2466 · PK: IDX_T_FinancialPaymentDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_FinancialPaymentDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_FinancialPaymentHeader` | bigint | N |  |
| 3 | `IDX_T_DepositReceive` | bigint | Y |  |
| 4 | `IDX_M_Branch` | bigint | Y |  |
| 5 | `IDX_M_Project` | bigint | Y |  |
| 6 | `IDX_M_Department` | bigint | Y |  |
| 7 | `IDX_M_DocumentType` | bigint | Y |  |
| 8 | `IDX_DocumentNo` | bigint | Y |  |
| 9 | `DocumentNo` | varchar(50) | Y |  |
| 10 | `COADetail` | bigint | Y |  |
| 11 | `PaymentAmount` | decimal(22,2) | Y |  |
| 12 | `RemarkDetail` | varchar(500) | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Create`, `USP_CM_FinancialPaymentDetail_Delete`, `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_LinkDocument`, `USP_CM_FinancialPaymentDetail_List`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPaymentHeader_Update`, `USP_CM_FinancialPayment_Approve`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialPayment_Duplicate`, `USP_CM_FinancialPayment_GetAllocation_List`, `USP_CM_FinancialPayment_Handover`, `USP_CM_FinancialPayment_Journal_List`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Create`, `USP_CM_PaymentAllocation_CreateMultiple`, `USP_CM_PaymentAllocation_Delete`, `USP_CM_PaymentAllocation_Info`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PaymentAllocation_List`, `USP_CM_PaymentAllocation_Update`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_PurchaseInvoice_Payment_List`, `USP_CM_R_CashflowBank`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`, `USP_CM_SalesRefund_Journal_List`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrderPayment_List`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_Payment`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_R_AP`

### CM_T_FinancialPaymentHeader

Baris: 2466 · PK: IDX_T_FinancialPaymentHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_FinancialPaymentHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_FinancialAccount` | bigint | N |  |
| 5 | `IDX_M_DocumentType` | bigint | N |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `IDX_M_Currency` | int | Y |  |
| 8 | `IDX_M_PaymentType` | bigint | N |  |
| 9 | `COAHeader` | bigint | Y |  |
| 10 | `PaymentID` | varchar(50) | Y |  |
| 11 | `PaymentDate` | datetime | Y |  |
| 12 | `RemarkHeader` | varchar(500) | Y |  |
| 13 | `PaymentStatus` | char(1) | Y |  |
| 14 | `PaymentAmount` | decimal(22,2) | Y |  |
| 15 | `DestinationAccountName` | varchar(100) | Y |  |
| 16 | `DestinationBank` | varchar(100) | Y |  |
| 17 | `DestinationAccountNo` | varchar(50) | Y |  |
| 18 | `ApprovedBy` | varchar(20) | Y |  |
| 19 | `ApprovalDate` | datetime | Y |  |
| 20 | `ApprovalRemark` | varchar(8000) | Y |  |
| 21 | `ValidateBy` | varchar(20) | Y |  |
| 22 | `ValidationDate` | datetime | Y |  |
| 23 | `ValidationRemark` | varchar(8000) | Y |  |
| 24 | `VoidBy` | varchar(20) | Y |  |
| 25 | `VoidDate` | datetime | Y |  |
| 26 | `VoidReason` | varchar(8000) | Y |  |
| 27 | `VoucherNoManual` | varchar(50) | Y |  |
| 28 | `PDCNo` | varchar(50) | Y |  |
| 29 | `HandoverBy` | varchar(50) | Y |  |
| 30 | `HandoverTo` | varchar(50) | Y |  |
| 31 | `HandoverDate` | datetime | Y |  |
| 32 | `HandoverNotes` | varchar(250) | Y |  |
| 33 | `UCreate` | varchar(36) | Y |  |
| 34 | `DCreate` | datetime | Y |  |
| 35 | `UModified` | varchar(36) | Y |  |
| 36 | `DModified` | datetime | Y |  |
| 37 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Create`, `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_List`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPaymentHeader_Create`, `USP_CM_FinancialPaymentHeader_Update`, `USP_CM_FinancialPayment_Approve`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialPayment_Duplicate`, `USP_CM_FinancialPayment_GetAllocation_List`, `USP_CM_FinancialPayment_Handover`, `USP_CM_FinancialPayment_Info`, `USP_CM_FinancialPayment_Journal_List`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_FinancialReceive_Approve`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Create`, `USP_CM_PaymentAllocation_CreateMultiple`, `USP_CM_PaymentAllocation_Info`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PaymentAllocation_List`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_PurchaseInvoice_Payment_List`, `USP_CM_R_BankTransfer_Period`, `USP_CM_R_CashflowBank`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`, `USP_CM_SalesRefund_Journal_List`, `USP_GN_Attachment_Save`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrderPayment_List`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_Payment`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_R_AP`

### CM_T_FinancialPaymentLog

Baris: 206 · PK: IDX_T_FinancialPaymentLog

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_FinancialPaymentLog` | bigint | N | IDENTITY |
| 2 | `IDX_T_FinancialPaymentHeader` | bigint | N |  |
| 3 | `LogType` | varchar(50) | Y |  |
| 4 | `LogDate` | datetime | Y |  |
| 5 | `LogRemark` | varchar(500) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_Approve`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_Validate`

### CM_T_FinancialReceiveDetail

Baris: 1972 · PK: IDX_T_FinancialReceiveDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_FinancialReceiveDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_FinancialReceiveHeader` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | Y |  |
| 4 | `IDX_M_Project` | bigint | Y |  |
| 5 | `IDX_M_Department` | bigint | Y |  |
| 6 | `IDX_M_DocumentType` | varchar(50) | Y |  |
| 7 | `IDX_DocumentNo` | bigint | Y |  |
| 8 | `DocumentNo` | varchar(50) | Y |  |
| 9 | `COADetail` | bigint | Y |  |
| 10 | `ReceiveAmount` | decimal(22,2) | Y |  |
| 11 | `RemarkDetail` | varchar(250) | Y |  |
| 12 | `UCreate` | varchar(36) | Y |  |
| 13 | `DCreate` | datetime | Y |  |
| 14 | `UModified` | varchar(36) | Y |  |
| 15 | `DModified` | datetime | Y |  |
| 16 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialReceiveDetail_Create`, `USP_CM_FinancialReceiveDetail_Delete`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_FinancialReceiveDetail_LinkDocument`, `USP_CM_FinancialReceiveDetail_List`, `USP_CM_FinancialReceiveDetail_Update`, `USP_CM_FinancialReceiveHeader_Update`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Delete`, `USP_CM_FinancialReceive_Duplicate`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_FinancialReceive_Void`, `USP_CM_R_FinancialReceive_Period`, `USP_CM_R_SalesInvoice_Item_Backup`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Create`, `USP_CM_ReceiveAllocation_Delete`, `USP_CM_ReceiveAllocation_Info`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_ReceiveAllocation_List`, `USP_CM_ReceiveAllocation_Update`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesInvoice_OS_List`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesInvoice_Payment_List`, `USP_MC_LTKM_Preview`, `USP_MC_LTKM_Save`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`, `USP_MC_R_AR`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderPayment_List`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_Payment`

### CM_T_FinancialReceiveHeader

Baris: 1972 · PK: IDX_T_FinancialReceiveHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_FinancialReceiveHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_FinancialAccount` | bigint | N |  |
| 5 | `IDX_M_DocumentType` | bigint | N |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `IDX_M_Currency` | int | Y |  |
| 8 | `IDX_M_PaymentType` | bigint | N |  |
| 9 | `COAHeader` | bigint | Y |  |
| 10 | `ReceiveID` | varchar(50) | Y |  |
| 11 | `ReceiveDate` | datetime | Y |  |
| 12 | `RemarkHeader` | varchar(8000) | Y |  |
| 13 | `ReceiveStatus` | char(1) | Y |  |
| 14 | `TenderedAmount` | decimal(18,2) | Y |  |
| 15 | `ReceiveAmount` | decimal(22,2) | Y |  |
| 16 | `ApprovedBy` | varchar(20) | Y |  |
| 17 | `ApprovalDate` | datetime | Y |  |
| 18 | `ApprovalRemark` | varchar(8000) | Y |  |
| 19 | `ValidateBy` | varchar(32) | Y |  |
| 20 | `ValidationDate` | datetime | Y |  |
| 21 | `VoidBy` | varchar(20) | Y |  |
| 22 | `VoidDate` | datetime | Y |  |
| 23 | `VoidReason` | varchar(8000) | Y |  |
| 24 | `CardNumber` | varchar(50) | Y |  |
| 25 | `CardHolderName` | varchar(50) | Y |  |
| 26 | `VoucherNoManual` | varchar(50) | Y |  |
| 27 | `PDCNo` | varchar(50) | Y |  |
| 28 | `UCreate` | varchar(36) | Y |  |
| 29 | `DCreate` | datetime | Y |  |
| 30 | `UModified` | varchar(36) | Y |  |
| 31 | `DModified` | datetime | Y |  |
| 32 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialReceiveDetail_Create`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_FinancialReceiveDetail_List`, `USP_CM_FinancialReceiveDetail_Update`, `USP_CM_FinancialReceiveHeader_Create`, `USP_CM_FinancialReceiveHeader_Update`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Delete`, `USP_CM_FinancialReceive_Duplicate`, `USP_CM_FinancialReceive_Info`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_FinancialReceive_Void`, `USP_CM_R_BankTransfer_Period`, `USP_CM_R_FinancialReceive_Period`, `USP_CM_R_SalesInvoice_Item_Backup`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Info`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_ReceiveAllocation_List`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesInvoice_OS_List`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesInvoice_Payment_List`, `USP_MC_LTKM_Preview`, `USP_MC_LTKM_Save`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`, `USP_MC_R_AR`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderPayment_List`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_Payment`

### CM_T_FinancialReceiveLog

Baris: 1 · PK: IDX_T_FinancialReceiveLog

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_FinancialReceiveLog` | bigint | N | IDENTITY |
| 2 | `IDX_T_FinancialReceiveHeader` | bigint | N |  |
| 3 | `LogType` | varchar(50) | Y |  |
| 4 | `LogDate` | datetime | Y |  |
| 5 | `LogRemark` | varchar(500) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialReceive_Delete`

### CM_T_InternalTransferDetail

Baris: 0 · PK: IDX_T_InternalTransferDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_InternalTransferDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_InternalTransferHeader` | bigint | N |  |
| 3 | `COADetail` | bigint | Y |  |
| 4 | `TransferAmount` | decimal(22,2) | Y |  |
| 5 | `RemarkDetail` | varchar(500) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_InternalTransferDetail_Create`, `USP_CM_InternalTransferDetail_Delete`, `USP_CM_InternalTransferDetail_Info`, `USP_CM_InternalTransferDetail_List`, `USP_CM_InternalTransferDetail_Update`, `USP_CM_InternalTransfer_Delete`, `USP_CM_InternalTransfer_Validate`

### CM_T_InternalTransferHeader

Baris: 46 · PK: IDX_T_InternalTransferHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_InternalTransferHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Branch` | int | Y |  |
| 4 | `IDX_M_DocumentType` | int | Y |  |
| 5 | `IDX_M_FromFinancialAccount` | bigint | Y |  |
| 6 | `IDX_M_ToFinancialAccount` | bigint | Y |  |
| 7 | `FromCOA` | bigint | Y |  |
| 8 | `ToCOA` | bigint | Y |  |
| 9 | `TransferID` | varchar(50) | Y |  |
| 10 | `VoucherNoManual` | varchar(50) | Y |  |
| 11 | `TransferDate` | date | Y |  |
| 12 | `TransferAmount` | decimal(22,2) | Y |  |
| 13 | `RemarkHeader` | varchar(500) | Y |  |
| 14 | `TransferStatus` | char(1) | Y |  |
| 15 | `ApprovalDate` | date | Y |  |
| 16 | `ApprovalRemark` | varchar(500) | Y |  |
| 17 | `ApprovalBy` | varchar(50) | Y |  |
| 18 | `VoidDate` | date | Y |  |
| 19 | `VoidReason` | varchar(500) | Y |  |
| 20 | `VoidBy` | varchar(50) | Y |  |
| 21 | `UCreate` | varchar(50) | Y |  |
| 22 | `DCreate` | datetime | Y |  |
| 23 | `UModified` | varchar(50) | Y |  |
| 24 | `DModified` | datetime | Y |  |
| 25 | `RecordStatus` | char(1) | Y |  |

Dipakai oleh: `USP_CM_InternalTransferDetail_Info`, `USP_CM_InternalTransferDetail_List`, `USP_CM_InternalTransferHeader_Create`, `USP_CM_InternalTransferHeader_Update`, `USP_CM_InternalTransfer_Approve`, `USP_CM_InternalTransfer_Delete`, `USP_CM_InternalTransfer_Info`, `USP_CM_InternalTransfer_ReverseApproval`, `USP_CM_InternalTransfer_ReverseValidate`, `USP_CM_InternalTransfer_Validate`, `USP_CM_InternalTransfer_Void`

### CM_T_InternalTransferLog

Baris: 52 · PK: IDX_T_InternalTransferLog

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_InternalTransferLog` | bigint | N | IDENTITY |
| 2 | `IDX_T_InternalTransferHeader` | bigint | Y |  |
| 3 | `LogType` | varchar(20) | Y |  |
| 4 | `LogDate` | datetime | Y |  |
| 5 | `LogRemark` | varchar(500) | Y |  |
| 6 | `UCreate` | varchar(50) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `RecordStatus` | char(1) | Y |  |

Dipakai oleh: `USP_CM_InternalTransfer_Approve`, `USP_CM_InternalTransfer_Delete`, `USP_CM_InternalTransfer_ReverseApproval`, `USP_CM_InternalTransfer_ReverseValidate`, `USP_CM_InternalTransfer_Void`

### CM_T_PaymentAllocation

Baris: 0 · PK: IDX_T_PaymentAllocation

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PaymentAllocation` | bigint | N | IDENTITY |
| 2 | `IDX_T_FinancialPaymentDetail` | bigint | N |  |
| 3 | `IDX_M_Partner` | bigint | Y |  |
| 4 | `IDX_M_DocumentType` | int | Y |  |
| 5 | `IDX_DocumentNo` | bigint | Y |  |
| 6 | `AllocationID` | varchar(50) | Y |  |
| 7 | `COAAllocation` | bigint | Y |  |
| 8 | `DocumentNo` | varchar(50) | Y |  |
| 9 | `AllocationDate` | datetime | Y |  |
| 10 | `AllocationAmount` | decimal(22,2) | Y |  |
| 11 | `RemarkAllocation` | varchar(500) | Y |  |
| 12 | `AllocationStatus` | char(1) | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Delete`, `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_List`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPayment_Approve`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialPayment_Handover`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Create`, `USP_CM_PaymentAllocation_CreateMultiple`, `USP_CM_PaymentAllocation_Delete`, `USP_CM_PaymentAllocation_Info`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PaymentAllocation_List`, `USP_CM_PaymentAllocation_Update`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_PurchaseInvoice_Payment_List`, `USP_CM_PurchaseInvoice_ReverseValidate`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`

### CM_T_PettyCashDetail

Baris: 4 · PK: IDX_T_PettyCashDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PettyCashDetail` | bigint | N |  |
| 2 | `IDX_T_PettyCashHeader` | bigint | N |  |
| 3 | `IDX_M_DocumentType` | int | Y |  |
| 4 | `IDX_M_Partner` | int | Y |  |
| 5 | `IDX_Reference` | bigint | Y |  |
| 6 | `ReferenceNo` | varchar(50) | Y |  |
| 7 | `TransactionDate` | date | Y |  |
| 8 | `PartnerName` | varchar(250) | Y |  |
| 9 | `DetailDesc` | varchar(50) | Y |  |
| 10 | `PettyCashAmount` | decimal(20,2) | Y |  |
| 11 | `UCreate` | varchar(10) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(10) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |
| 16 | `IDX_M_COA` | bigint | Y |  |

Dipakai oleh: `USP_CM_PettyCashDetail_Create`, `USP_CM_PettyCashDetail_Delete`, `USP_CM_PettyCashDetail_Info`, `USP_CM_PettyCashDetail_List`, `USP_CM_PettyCashDetail_Update`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Info`, `USP_CM_PettyCash_List`

### CM_T_PettyCashHeader

Baris: 1 · PK: IDX_T_PettyCashHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PettyCashHeader` | bigint | N |  |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `OpeningDate` | datetime | Y |  |
| 5 | `TransactionType` | char(3) | Y |  |
| 6 | `TransactionID` | varchar(50) | Y |  |
| 7 | `TransactionDesc` | varchar(450) | Y |  |
| 8 | `CashierID` | int | Y |  |
| 9 | `PettyCashStatus` | char(1) | Y |  |
| 10 | `ClosingDate` | datetime | Y |  |
| 11 | `ClosingBy` | varchar(50) | Y |  |
| 12 | `ClosingNotes` | varchar(500) | Y |  |
| 13 | `UCreate` | varchar(10) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(10) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |
| 18 | `IDX_M_FinancialAccount` | bigint | Y |  |

Dipakai oleh: `USP_CM_PettyCashDetail_Create`, `USP_CM_PettyCashDetail_Delete`, `USP_CM_PettyCashDetail_List`, `USP_CM_PettyCashDetail_Update`, `USP_CM_PettyCashHeader_Create`, `USP_CM_PettyCashHeader_Update`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Info`, `USP_CM_PettyCash_List`, `USP_CM_PettyCash_Reopen`

### CM_T_PurchaseInvoiceDetail

Baris: 0 · PK: IDX_T_PurchaseInvoiceDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseInvoiceDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseInvoiceHeader` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | Y |  |
| 4 | `IDX_M_Project` | bigint | Y |  |
| 5 | `IDX_M_Department` | bigint | Y |  |
| 6 | `IDX_M_Item` | bigint | Y |  |
| 7 | `IDX_M_UoM` | bigint | Y |  |
| 8 | `IDX_M_COA` | bigint | Y |  |
| 9 | `IDX_M_Tax` | int | Y |  |
| 10 | `IncludeTax` | bit | Y |  |
| 11 | `ItemDesc` | varchar(256) | Y |  |
| 12 | `Quantity` | decimal(18,2) | Y |  |
| 13 | `UnitPrice` | decimal(18,2) | Y |  |
| 14 | `UntaxedAmount` | decimal(20,2) | Y |  |
| 15 | `DiscountAmount` | decimal(20,2) | Y |  |
| 16 | `TaxAmount` | decimal(20,3) | Y |  |
| 17 | `RemarkDetail` | varchar(500) | Y |  |
| 18 | `IDX_Prev_T_PurchaseInvoiceDetail` | bigint | Y |  |
| 19 | `UCreate` | varchar(36) | Y |  |
| 20 | `DCreate` | datetime | Y |  |
| 21 | `UModified` | varchar(36) | Y |  |
| 22 | `DModified` | datetime | Y |  |
| 23 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Create`, `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPayment_GetAllocation_List`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_PaymentAllocation_Create`, `USP_CM_PaymentAllocation_CreateMultiple`, `USP_CM_PurchaseInvoiceDetail_Create`, `USP_CM_PurchaseInvoiceDetail_Delete`, `USP_CM_PurchaseInvoiceDetail_Info`, `USP_CM_PurchaseInvoiceDetail_List`, `USP_CM_PurchaseInvoiceDetail_Update`, `USP_CM_PurchaseInvoiceHeader_Update`, `USP_CM_PurchaseInvoiceTax_Create`, `USP_CM_PurchaseInvoiceTax_Info`, `USP_CM_PurchaseInvoiceTax_List`, `USP_CM_PurchaseInvoiceTax_Update`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Duplicate`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`

### CM_T_PurchaseInvoiceHeader

Baris: 0 · PK: IDX_T_PurchaseInvoiceHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseInvoiceHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_Currency` | int | Y |  |
| 5 | `IDX_M_LocationInventory` | bigint | N |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `IDX_M_DocumentType` | bigint | N |  |
| 8 | `IDX_ReferenceNo` | bigint | Y |  |
| 9 | `ReferenceNo` | varchar(50) | Y |  |
| 10 | `InvoiceNo` | varchar(50) | Y |  |
| 11 | `InvoiceDate` | datetime | Y |  |
| 12 | `InvoiceDueDate` | datetime | Y |  |
| 13 | `InvoicePeriod` | int | Y |  |
| 14 | `SupplierDeliveryNo` | varchar(500) | Y |  |
| 15 | `RemarkHeader` | varchar(8000) | Y |  |
| 16 | `InvoiceStatus` | char(1) | Y |  |
| 17 | `ApprovedDate` | datetime | Y |  |
| 18 | `ApproveBy` | varchar(36) | Y |  |
| 19 | `ApproveRemark` | varchar(8000) | Y |  |
| 20 | `VoidDate` | datetime | Y |  |
| 21 | `VoidBy` | varchar(36) | Y |  |
| 22 | `VoidReason` | varchar(8000) | Y |  |
| 23 | `IsCreateJournal` | char(1) | Y |  |
| 24 | `COAHeader` | bigint | Y |  |
| 25 | `VendorInvoiceNo` | varchar(500) | Y |  |
| 26 | `FakturPajak` | varchar(500) | Y |  |
| 27 | `IsTaxChecked` | char(1) | Y |  |
| 28 | `TotalPurchaseAmount` | decimal(18,2) | Y |  |
| 29 | `TotalDiscountAmount` | decimal(18,2) | Y |  |
| 30 | `TotalUntaxedAmount` | decimal(18,2) | Y |  |
| 31 | `TotalTaxedAmount` | decimal(18,2) | Y |  |
| 32 | `UCreate` | varchar(36) | Y |  |
| 33 | `DCreate` | datetime | Y |  |
| 34 | `UModified` | varchar(36) | Y |  |
| 35 | `DModified` | datetime | Y |  |
| 36 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Create`, `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPayment_GetAllocation_List`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_PaymentAllocation_Create`, `USP_CM_PaymentAllocation_CreateMultiple`, `USP_CM_PaymentAllocation_Update`, `USP_CM_PurchaseInvoiceDetail_Create`, `USP_CM_PurchaseInvoiceDetail_Delete`, `USP_CM_PurchaseInvoiceDetail_Info`, `USP_CM_PurchaseInvoiceDetail_List`, `USP_CM_PurchaseInvoiceDetail_Update`, `USP_CM_PurchaseInvoiceHeader_Create`, `USP_CM_PurchaseInvoiceHeader_Update`, `USP_CM_PurchaseInvoiceTax_Info`, `USP_CM_PurchaseInvoiceTax_List`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Duplicate`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_Journal_Inquiry`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_PurchaseInvoice_Payment_List`, `USP_CM_PurchaseInvoice_ReverseValidate`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`

### CM_T_PurchaseInvoiceTax

Baris: 0 · PK: IDX_T_PurchaseInvoiceTax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseInvoiceTax` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseInvoiceHeader` | bigint | N |  |
| 3 | `IDX_T_PurchaseInvoiceDetail` | bigint | Y |  |
| 4 | `IDX_M_Tax` | bigint | Y |  |
| 5 | `TaxID` | varchar(50) | Y |  |
| 6 | `TaxDesc` | varchar(50) | Y |  |
| 7 | `TaxRate` | decimal(5,2) | Y |  |
| 8 | `TaxAmount` | decimal(20,3) | Y |  |
| 9 | `TaxCOA` | bigint | Y |  |
| 10 | `AllowEdit` | char(1) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_GetAllocation_List`, `USP_CM_PurchaseInvoiceDetail_Create`, `USP_CM_PurchaseInvoiceDetail_Delete`, `USP_CM_PurchaseInvoiceDetail_Update`, `USP_CM_PurchaseInvoiceTax_Create`, `USP_CM_PurchaseInvoiceTax_Delete`, `USP_CM_PurchaseInvoiceTax_Info`, `USP_CM_PurchaseInvoiceTax_List`, `USP_CM_PurchaseInvoiceTax_Update`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Duplicate`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`

### CM_T_PurchaseRefundDetail

Baris: 0 · PK: IDX_T_PurchaseRefundDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseRefundDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseRefundHeader` | bigint | N |  |
| 3 | `IDX_M_Item` | bigint | Y |  |
| 4 | `IDX_M_UoM` | bigint | Y |  |
| 5 | `IDX_M_COA` | bigint | Y |  |
| 6 | `IDX_M_Tax` | int | Y |  |
| 7 | `IncludeTax` | bit | Y |  |
| 8 | `ItemDesc` | varchar(256) | Y |  |
| 9 | `Quantity` | decimal(18,2) | Y |  |
| 10 | `UnitPrice` | decimal(18,2) | Y |  |
| 11 | `UntaxedAmount` | decimal(20,2) | Y |  |
| 12 | `DiscountAmount` | decimal(20,2) | Y |  |
| 13 | `TaxAmount` | decimal(20,2) | Y |  |
| 14 | `RemarkDetail` | varchar(500) | Y |  |
| 15 | `UCreate` | varchar(36) | Y |  |
| 16 | `DCreate` | datetime | Y |  |
| 17 | `UModified` | varchar(36) | Y |  |
| 18 | `DModified` | datetime | Y |  |
| 19 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PurchaseRefundTax_Info`, `USP_CM_PurchaseRefundTax_List`, `USP_CM_PurchaseRefund_Approve`

### CM_T_PurchaseRefundHeader

Baris: 0 · PK: IDX_T_PurchaseRefundHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseRefundHeader` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseInvoiceHeader` | bigint | N |  |
| 3 | `IDX_M_Company` | bigint | Y |  |
| 4 | `IDX_M_Branch` | bigint | N |  |
| 5 | `IDX_M_Currency` | int | Y |  |
| 6 | `IDX_M_LocationInventory` | bigint | N |  |
| 7 | `IDX_M_Partner` | bigint | Y |  |
| 8 | `IDX_M_DocumentType` | bigint | N |  |
| 9 | `IDX_ReferenceNo` | bigint | Y |  |
| 10 | `ReferenceNo` | varchar(50) | Y |  |
| 11 | `InvoiceNo` | varchar(50) | Y |  |
| 12 | `InvoiceDate` | datetime | Y |  |
| 13 | `InvoiceDueDate` | datetime | Y |  |
| 14 | `SupplierDeliveryNo` | varchar(50) | Y |  |
| 15 | `RemarkHeader` | varchar(8000) | Y |  |
| 16 | `InvoiceStatus` | char(1) | Y |  |
| 17 | `ApprovedDate` | datetime | Y |  |
| 18 | `ApproveBy` | varchar(36) | Y |  |
| 19 | `ApproveRemark` | varchar(8000) | Y |  |
| 20 | `VoidDate` | datetime | Y |  |
| 21 | `VoidBy` | varchar(36) | Y |  |
| 22 | `VoidReason` | varchar(8000) | Y |  |
| 23 | `IsCreateJournal` | char(1) | Y |  |
| 24 | `COAHeader` | bigint | Y |  |
| 25 | `VendorInvoiceNo` | varchar(50) | Y |  |
| 26 | `FakturPajak` | varchar(50) | Y |  |
| 27 | `UCreate` | varchar(36) | Y |  |
| 28 | `DCreate` | datetime | Y |  |
| 29 | `UModified` | varchar(36) | Y |  |
| 30 | `DModified` | datetime | Y |  |
| 31 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PurchaseRefundHeader_Create`, `USP_CM_PurchaseRefundHeader_Update`, `USP_CM_PurchaseRefundTax_Info`, `USP_CM_PurchaseRefundTax_List`, `USP_CM_PurchaseRefund_Approve`

### CM_T_PurchaseRefundTax

Baris: 0 · PK: IDX_T_PurchaseRefundTax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseRefundTax` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseRefundHeader` | bigint | N |  |
| 3 | `IDX_T_PurchaseRefundDetail` | bigint | Y |  |
| 4 | `IDX_M_Tax` | bigint | Y |  |
| 5 | `TaxID` | varchar(50) | Y |  |
| 6 | `TaxDesc` | varchar(50) | Y |  |
| 7 | `TaxRate` | decimal(5,2) | Y |  |
| 8 | `TaxAmount` | decimal(20,2) | Y |  |
| 9 | `TaxCOA` | bigint | Y |  |
| 10 | `AllowEdit` | char(1) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PurchaseRefundTax_Info`, `USP_CM_PurchaseRefundTax_List`, `USP_CM_PurchaseRefund_Approve`

### CM_T_ReceiveAllocation

Baris: 0 · PK: IDX_T_ReceiveAllocation

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_ReceiveAllocation` | bigint | N | IDENTITY |
| 2 | `IDX_T_FinancialReceiveDetail` | bigint | N |  |
| 3 | `IDX_M_Partner` | bigint | Y |  |
| 4 | `IDX_M_DocumentType` | int | Y |  |
| 5 | `IDX_DocumentNo` | bigint | Y |  |
| 6 | `AllocationID` | varchar(50) | Y |  |
| 7 | `COAAllocation` | bigint | Y |  |
| 8 | `DocumentNo` | varchar(50) | Y |  |
| 9 | `AllocationDate` | datetime | Y |  |
| 10 | `AllocationAmount` | decimal(22,2) | Y |  |
| 11 | `RemarkAllocation` | varchar(250) | Y |  |
| 12 | `AllocationStatus` | char(1) | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialReceiveDetail_Delete`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_FinancialReceiveDetail_List`, `USP_CM_FinancialReceiveDetail_Update`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_Delete`, `USP_CM_FinancialReceive_GetAllocation_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_FinancialReceive_Void`, `USP_CM_R_SalesInvoice_Item_Backup`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Create`, `USP_CM_ReceiveAllocation_Delete`, `USP_CM_ReceiveAllocation_Info`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_ReceiveAllocation_List`, `USP_CM_ReceiveAllocation_Update`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesInvoice_Payment_List`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesInvoice_Void`

### CM_T_SalesInvoiceDetail

Baris: 0 · PK: IDX_T_SalesInvoiceDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesInvoiceDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesInvoiceHeader` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | Y |  |
| 4 | `IDX_M_Project` | bigint | Y |  |
| 5 | `IDX_M_Department` | bigint | Y |  |
| 6 | `IDX_M_Item` | bigint | Y |  |
| 7 | `IDX_M_UoM` | bigint | Y |  |
| 8 | `IDX_M_COA` | bigint | Y |  |
| 9 | `IDX_M_Tax` | int | Y |  |
| 10 | `IncludeTax` | bit | Y |  |
| 11 | `ItemDesc` | varchar(512) | Y |  |
| 12 | `Quantity` | decimal(18,2) | Y |  |
| 13 | `UnitPrice` | decimal(18,3) | Y |  |
| 14 | `UntaxedAmount` | decimal(20,3) | Y |  |
| 15 | `DiscountAmount` | decimal(20,3) | Y |  |
| 16 | `TaxAmount` | decimal(20,3) | Y |  |
| 17 | `RemarkDetail` | varchar(8000) | Y |  |
| 18 | `IDX_Prev_T_SalesInvoiceDetail` | bigint | Y |  |
| 19 | `UCreate` | varchar(36) | Y |  |
| 20 | `DCreate` | datetime | Y |  |
| 21 | `UModified` | varchar(36) | Y |  |
| 22 | `DModified` | datetime | Y |  |
| 23 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialReceive_GetAllocation_List`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_ReceiveAllocation_Create`, `USP_CM_SalesInvoiceDetail_Create`, `USP_CM_SalesInvoiceDetail_Delete`, `USP_CM_SalesInvoiceDetail_Info`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceDetail_Update`, `USP_CM_SalesInvoiceHeader_Create`, `USP_CM_SalesInvoiceHeader_Update`, `USP_CM_SalesInvoiceTax_Create`, `USP_CM_SalesInvoiceTax_Info`, `USP_CM_SalesInvoiceTax_List`, `USP_CM_SalesInvoiceTax_Update`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Duplicate`, `USP_CM_SalesInvoice_FakturHeader_Export`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_OS_List`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefundHeader_Create`

### CM_T_SalesInvoiceHeader

Baris: 0 · PK: IDX_T_SalesInvoiceHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesInvoiceHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_Currency` | int | Y |  |
| 5 | `IDX_M_LocationInventory` | bigint | N |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `IDX_M_DocumentType` | bigint | N |  |
| 8 | `IDX_ReferenceNo` | bigint | Y |  |
| 9 | `IDX_M_SalesPerson` | bigint | Y |  |
| 10 | `ReferenceNo` | varchar(100) | Y |  |
| 11 | `TaxInvoiceNo` | varchar(64) | Y |  |
| 12 | `ERPNo` | varchar(64) | Y |  |
| 13 | `InvoiceNo` | varchar(32) | Y |  |
| 14 | `InvoiceDate` | datetime | Y |  |
| 15 | `InvoiceDueDate` | datetime | Y |  |
| 16 | `InvoicePeriod` | int | Y |  |
| 17 | `DeliveryNo` | varchar(32) | Y |  |
| 18 | `RemarkHeader` | varchar(1024) | Y |  |
| 19 | `AuditNotes` | varchar(1024) | Y |  |
| 20 | `InvoiceStatus` | char(1) | Y |  |
| 21 | `ApprovedDate` | datetime | Y |  |
| 22 | `ApproveBy` | varchar(36) | Y |  |
| 23 | `ApproveRemark` | varchar(8000) | Y |  |
| 24 | `VoidDate` | datetime | Y |  |
| 25 | `VoidBy` | varchar(36) | Y |  |
| 26 | `VoidReason` | varchar(8000) | Y |  |
| 27 | `IsProforma` | char(1) | Y |  |
| 28 | `IsCreateJournal` | char(1) | Y |  |
| 29 | `COAHeader` | bigint | Y |  |
| 30 | `AccrueType` | char(4) | Y |  |
| 31 | `StampDuty` | decimal(18,0) | Y |  |
| 32 | `TotalSalesAmount` | decimal(18,2) | Y |  |
| 33 | `TotalDiscountAmount` | decimal(18,2) | Y |  |
| 34 | `TotalUntaxedAmount` | decimal(18,2) | Y |  |
| 35 | `TotalTaxedAmount` | decimal(18,2) | Y |  |
| 36 | `UCreate` | varchar(36) | Y |  |
| 37 | `DCreate` | datetime | Y |  |
| 38 | `UModified` | varchar(36) | Y |  |
| 39 | `DModified` | datetime | Y |  |
| 40 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FakturNumber_Info`, `USP_CM_FinancialReceive_GetAllocation_List`, `USP_CM_R_SalesInvoice_Item_Backup`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_ReceiveAllocation_Create`, `USP_CM_ReceiveAllocation_Update`, `USP_CM_SalesInvoiceDetail_Create`, `USP_CM_SalesInvoiceDetail_Delete`, `USP_CM_SalesInvoiceDetail_Info`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceDetail_Update`, `USP_CM_SalesInvoiceHeader_Create`, `USP_CM_SalesInvoiceHeader_Update`, `USP_CM_SalesInvoiceTax_Info`, `USP_CM_SalesInvoiceTax_List`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Duplicate`, `USP_CM_SalesInvoice_FakturHeader_Export`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesInvoice_OS_List`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesInvoice_Payment_List`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesInvoice_UpdateAuditNotes`, `USP_CM_SalesInvoice_Void`

### CM_T_SalesInvoiceTax

Baris: 0 · PK: IDX_T_SalesInvoiceTax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesInvoiceTax` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesInvoiceHeader` | bigint | N |  |
| 3 | `IDX_T_SalesInvoiceDetail` | bigint | Y |  |
| 4 | `IDX_M_Tax` | bigint | Y |  |
| 5 | `TaxID` | varchar(50) | Y |  |
| 6 | `TaxDesc` | varchar(50) | Y |  |
| 7 | `TaxRate` | decimal(5,2) | Y |  |
| 8 | `TaxAmount` | decimal(20,3) | Y |  |
| 9 | `TaxCOA` | bigint | Y |  |
| 10 | `AllowEdit` | char(1) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialReceive_GetAllocation_List`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_SalesInvoiceDetail_Create`, `USP_CM_SalesInvoiceDetail_Delete`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceDetail_Update`, `USP_CM_SalesInvoiceTax_Create`, `USP_CM_SalesInvoiceTax_Delete`, `USP_CM_SalesInvoiceTax_Info`, `USP_CM_SalesInvoiceTax_List`, `USP_CM_SalesInvoiceTax_Update`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Duplicate`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesRefundHeader_Create`

### CM_T_SalesRefundDetail

Baris: 0 · PK: IDX_T_SalesRefundDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesRefundDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesInvoiceDetail` | bigint | Y |  |
| 3 | `IDX_T_SalesRefundHeader` | bigint | N |  |
| 4 | `IDX_M_Item` | bigint | Y |  |
| 5 | `IDX_M_UoM` | bigint | Y |  |
| 6 | `IDX_M_COA` | bigint | Y |  |
| 7 | `IncludeTax` | bit | Y |  |
| 8 | `ItemDesc` | varchar(512) | Y |  |
| 9 | `Quantity` | decimal(18,2) | Y |  |
| 10 | `UnitPrice` | decimal(18,3) | Y |  |
| 11 | `UntaxedAmount` | decimal(20,3) | Y |  |
| 12 | `DiscountAmount` | decimal(20,3) | Y |  |
| 13 | `RefundQuantity` | decimal(18,2) | Y |  |
| 14 | `RefundPrice` | decimal(18,3) | Y |  |
| 15 | `RefundDesc` | varchar(8000) | Y |  |
| 16 | `IDX_M_Tax` | int | Y |  |
| 17 | `TaxAmount` | decimal(20,3) | Y |  |
| 18 | `TaxRefundAmount` | decimal(20,3) | Y |  |
| 19 | `RemarkDetail` | varchar(8000) | Y |  |
| 20 | `UCreate` | varchar(36) | Y |  |
| 21 | `DCreate` | datetime | Y |  |
| 22 | `UModified` | varchar(36) | Y |  |
| 23 | `DModified` | datetime | Y |  |
| 24 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_SalesRefundHeader_Create`, `USP_CM_SalesRefundTax_Info`, `USP_CM_SalesRefundTax_List`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Void`

### CM_T_SalesRefundHeader

Baris: 0 · PK: IDX_T_SalesRefundHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesRefundHeader` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesInvoiceHeader` | bigint | N |  |
| 3 | `IDX_M_Company` | bigint | Y |  |
| 4 | `IDX_M_Branch` | bigint | N |  |
| 5 | `IDX_M_Currency` | int | Y |  |
| 6 | `IDX_M_LocationInventory` | bigint | N |  |
| 7 | `IDX_M_Partner` | bigint | Y |  |
| 8 | `IDX_M_DocumentType` | bigint | N |  |
| 9 | `IDX_M_SalesPerson` | bigint | Y |  |
| 10 | `InvoiceReferenceNo` | varchar(32) | Y |  |
| 11 | `TaxInvoiceNo` | varchar(32) | Y |  |
| 12 | `RefundNo` | varchar(32) | Y |  |
| 13 | `RefundDate` | datetime | Y |  |
| 14 | `RefundDueDate` | datetime | Y |  |
| 15 | `ReferenceNo` | varchar(32) | Y |  |
| 16 | `DeliveryNo` | varchar(32) | Y |  |
| 17 | `RemarkHeader` | varchar(8000) | Y |  |
| 18 | `RefundStatus` | char(1) | Y |  |
| 19 | `ApprovedDate` | datetime | Y |  |
| 20 | `ApproveBy` | varchar(36) | Y |  |
| 21 | `ApproveRemark` | varchar(8000) | Y |  |
| 22 | `VoidDate` | datetime | Y |  |
| 23 | `VoidBy` | varchar(36) | Y |  |
| 24 | `VoidReason` | varchar(8000) | Y |  |
| 25 | `IsProforma` | char(1) | Y |  |
| 26 | `IsCreateJournal` | char(1) | Y |  |
| 27 | `COAHeader` | bigint | Y |  |
| 28 | `AccrueType` | char(4) | Y |  |
| 29 | `UCreate` | varchar(36) | Y |  |
| 30 | `DCreate` | datetime | Y |  |
| 31 | `UModified` | varchar(36) | Y |  |
| 32 | `DModified` | datetime | Y |  |
| 33 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesRefundHeader_Create`, `USP_CM_SalesRefundHeader_Update`, `USP_CM_SalesRefundTax_Info`, `USP_CM_SalesRefundTax_List`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Journal_List`, `USP_CM_SalesRefund_Void`

### CM_T_SalesRefundTax

Baris: 0 · PK: IDX_T_SalesRefundTax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesRefundTax` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesRefundHeader` | bigint | N |  |
| 3 | `IDX_T_SalesRefundDetail` | bigint | Y |  |
| 4 | `IDX_M_Tax` | bigint | Y |  |
| 5 | `TaxID` | varchar(50) | Y |  |
| 6 | `TaxDesc` | varchar(50) | Y |  |
| 7 | `TaxRate` | decimal(5,2) | Y |  |
| 8 | `TaxAmount` | decimal(20,2) | Y |  |
| 9 | `TaxRefundAmount` | decimal(20,2) | Y |  |
| 10 | `TaxCOA` | bigint | Y |  |
| 11 | `AllowEdit` | char(1) | Y |  |
| 12 | `UCreate` | varchar(36) | Y |  |
| 13 | `DCreate` | datetime | Y |  |
| 14 | `UModified` | varchar(36) | Y |  |
| 15 | `DModified` | datetime | Y |  |
| 16 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_SalesRefundHeader_Create`, `USP_CM_SalesRefundTax_Info`, `USP_CM_SalesRefundTax_List`, `USP_CM_SalesRefund_Approve`

### CM_T_TaxInvoiceDetail

Baris: 0 · PK: IDX_T_TaxInvoiceDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_TaxInvoiceDetail` | bigint | N |  |
| 2 | `IDX_T_TaxInvoiceHeader` | bigint | N |  |
| 3 | `TaxSeqNo` | int | Y |  |
| 4 | `DetailDesc` | varchar(8000) | Y |  |
| 5 | `Valas` | decimal(22,2) | Y |  |
| 6 | `Rupiah` | decimal(22,2) | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `RecordStatus` | varchar(1) | Y |  |

### CM_T_TaxInvoiceHeader

Baris: 0 · PK: IDX_T_TaxInvoiceHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_TaxInvoiceHeader` | bigint | N |  |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_BusinessPartner` | bigint | Y |  |
| 5 | `IDX_M_Currency` | int | Y |  |
| 6 | `IDX_M_ApplicationID` | bigint | Y |  |
| 7 | `ReferenceTable` | varchar(50) | Y |  |
| 8 | `IDX_DocumentNo` | bigint | Y |  |
| 9 | `TaxInvoiceType` | varchar(50) | Y |  |
| 10 | `TaxInvoiceCategory` | varchar(50) | Y |  |
| 11 | `TaxInvoiceModel` | varchar(50) | Y |  |
| 12 | `TaxInvoiceNo` | varchar(50) | Y |  |
| 13 | `TaxInvoiceDate` | datetime | Y |  |
| 14 | `TaxInvoicePeriod` | varchar(6) | Y |  |
| 15 | `PartnerNPWP` | varchar(50) | Y |  |
| 16 | `PartnerInvoiceNo` | varchar(50) | Y |  |
| 17 | `TransactionType` | varchar(50) | Y |  |
| 18 | `TransactionCode` | varchar(50) | Y |  |
| 19 | `DokumenTransaksi` | varchar(50) | Y |  |
| 20 | `ReferenceNo` | varchar(50) | Y |  |
| 21 | `PPNBM` | decimal(22,2) | Y |  |
| 22 | `PPNBMOriginal` | decimal(22,2) | Y |  |
| 23 | `RemarkHeader` | varchar(500) | Y |  |
| 24 | `UCreate` | varchar(36) | Y |  |
| 25 | `DCreate` | datetime | Y |  |
| 26 | `UModified` | varchar(36) | Y |  |
| 27 | `DModified` | datetime | Y |  |
| 28 | `RecordStatus` | varchar(1) | Y |  |

### FA_M_Asset

Baris: 0 · PK: IDX_M_Asset

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Asset` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Branch` | int | Y |  |
| 4 | `IDX_M_Department` | int | Y |  |
| 5 | `IDX_M_AssetCategory` | int | Y |  |
| 6 | `AssetCode` | varchar(50) | Y |  |
| 7 | `AssetName` | varchar(200) | Y |  |
| 8 | `AssetDesc` | varchar(5000) | Y |  |
| 9 | `AcquisitionDate` | date | Y |  |
| 10 | `UsageStartDate` | date | Y |  |
| 11 | `AcquisitionCost` | decimal(18,2) | Y |  |
| 12 | `ResidualValue` | decimal(18,2) | Y |  |
| 13 | `UsefulLifeMonth` | int | Y |  |
| 14 | `DeprMethod` | char(2) | Y |  |
| 15 | `FiscalGroup` | char(2) | Y |  |
| 16 | `FiscalDeprMethod` | char(2) | Y |  |
| 17 | `IDX_T_PurchaseInvoice` | bigint | Y |  |
| 18 | `ReferenceNo` | varchar(50) | Y |  |
| 19 | `AssetStatus` | char(1) | Y |  |
| 20 | `DisposalDate` | date | Y |  |
| 21 | `OpeningAccumDepr` | decimal(18,2) | Y |  |
| 22 | `UCreate` | varchar(36) | Y |  |
| 23 | `DCreate` | datetime | Y |  |
| 24 | `UModified` | varchar(36) | Y |  |
| 25 | `DModified` | datetime | Y |  |
| 26 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_FA_AssetDisposal_Save`, `USP_FA_AssetMutation_Save`, `USP_FA_Asset_Create`, `USP_FA_Asset_GenerateCode`, `USP_FA_Asset_Info`, `USP_FA_Asset_Update`, `USP_FA_Depreciation_Calculate`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_AssetCard`, `USP_FA_R_AssetList`, `USP_FA_R_DepreciationSchedule`, `USP_FA_R_FiscalDepreciation`, `USP_FA_R_Reconciliation`

### FA_M_AssetCategory

Baris: 2 · PK: IDX_M_AssetCategory

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_AssetCategory` | int | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `CategoryCode` | varchar(20) | Y |  |
| 4 | `CategoryName` | varchar(100) | Y |  |
| 5 | `IDX_M_COA_Asset` | bigint | Y |  |
| 6 | `IDX_M_COA_AccumDepr` | bigint | Y |  |
| 7 | `IDX_M_COA_DeprExpense` | bigint | Y |  |
| 8 | `IDX_M_COA_GainDisposal` | bigint | Y |  |
| 9 | `IDX_M_COA_LossDisposal` | bigint | Y |  |
| 10 | `DefaultUsefulLifeMonth` | int | Y |  |
| 11 | `DefaultDeprMethod` | char(2) | Y |  |
| 12 | `FiscalGroup` | char(2) | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_FA_AssetCategory_Create`, `USP_FA_AssetCategory_Info`, `USP_FA_AssetCategory_Update`, `USP_FA_AssetDisposal_Save`, `USP_FA_Asset_Info`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_AssetList`, `USP_FA_R_DepreciationSchedule`, `USP_FA_R_FiscalDepreciation`, `USP_FA_R_Reconciliation`

### FA_T_Depreciation

Baris: 0 · PK: IDX_T_Depreciation

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_Depreciation` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `DeprPeriod` | varchar(6) | Y |  |
| 4 | `IDX_T_JournalHeader` | bigint | Y |  |
| 5 | `DeprStatus` | char(1) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_FA_AssetDisposal_Save`, `USP_FA_Asset_Info`, `USP_FA_Asset_Update`, `USP_FA_Depreciation_Calculate`, `USP_FA_Depreciation_Cancel`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_AssetCard`, `USP_FA_R_AssetList`, `USP_FA_R_DepreciationSchedule`, `USP_FA_R_FiscalDepreciation`, `USP_FA_R_Reconciliation`

### FA_T_DepreciationDetail

Baris: 0 · PK: IDX_T_DepreciationDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_DepreciationDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_Depreciation` | bigint | Y |  |
| 3 | `IDX_M_Asset` | bigint | Y |  |
| 4 | `DeprAmount` | decimal(18,2) | Y |  |
| 5 | `FiscalDeprAmount` | decimal(18,2) | Y |  |
| 6 | `AccumDeprAfter` | decimal(18,2) | Y |  |
| 7 | `BookValueAfter` | decimal(18,2) | Y |  |
| 8 | `UCreate` | varchar(36) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UModified` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_FA_AssetDisposal_Save`, `USP_FA_Asset_Info`, `USP_FA_Asset_Update`, `USP_FA_Depreciation_Calculate`, `USP_FA_Depreciation_Cancel`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_AssetCard`, `USP_FA_R_AssetList`, `USP_FA_R_DepreciationSchedule`, `USP_FA_R_FiscalDepreciation`, `USP_FA_R_Reconciliation`

### GL_M_COA

Baris: 159 · PK: IDX_M_COA

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_COA` | bigint | N | IDENTITY |
| 2 | `IDX_M_COACategory` | bigint | Y |  |
| 3 | `IDX_M_COAType` | bigint | Y |  |
| 4 | `IDX_M_CashflowIn` | bigint | Y |  |
| 5 | `IDX_M_CashflowOut` | bigint | Y |  |
| 6 | `COAFlag` | char(1) | Y |  |
| 7 | `COAID` | varchar(32) | Y |  |
| 8 | `COADesc` | varchar(512) | Y |  |
| 9 | `COADesc2` | varchar(512) | Y |  |
| 10 | `ParentID` | bigint | Y |  |
| 11 | `DefaultBalance` | char(1) | Y |  |
| 12 | `AllowJournalEntry` | char(1) | Y |  |
| 13 | `IsReconcile` | char(1) | Y |  |
| 14 | `COAStatus` | char(1) | Y |  |
| 15 | `COAGroup1` | varchar(50) | Y |  |
| 16 | `COAGroup2` | varchar(50) | Y |  |
| 17 | `COAGroup3` | varchar(50) | Y |  |
| 18 | `TranslationRate` | varchar(1) | Y |  |
| 19 | `UCreate` | varchar(36) | Y |  |
| 20 | `DCreate` | datetime | Y |  |
| 21 | `UModified` | varchar(36) | Y |  |
| 22 | `DModified` | datetime | Y |  |
| 23 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_CreateAdminFeeJournal`, `USP_CM_BankStatement_CreateJournal`, `USP_CM_BankStatement_CreateMergedJournal`, `USP_CM_BankStatement_CreateMonthEndJournal`, `USP_CM_BankStatement_Info`, `USP_CM_BankStatement_InsertJournal`, `USP_CM_FinancialAccount_Info`, `USP_CM_FinancialPaymentDetail_Create`, `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_List`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Journal_List`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_FinancialReceiveDetail_List`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_InternalTransferDetail_Create`, `USP_CM_InternalTransferDetail_Info`, `USP_CM_InternalTransferDetail_List`, `USP_CM_InternalTransferDetail_Update`, `USP_CM_InternalTransfer_Approve`, `USP_CM_InternalTransfer_Journal_List`, `USP_CM_InternalTransfer_Validate`, `USP_CM_Partner_Info`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Info`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PaymentAllocation_List`, `USP_CM_PettyCashDetail_Info`, `USP_CM_PettyCashDetail_List`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Journal_List`, `USP_CM_PurchaseInvoiceDetail_Info`, `USP_CM_PurchaseInvoiceDetail_List`, `USP_CM_PurchaseInvoiceTax_Info`, `USP_CM_PurchaseInvoiceTax_List`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_Journal_Inquiry`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_PurchaseRefundTax_Info`, `USP_CM_PurchaseRefundTax_List`, `USP_CM_PurchaseRefund_Approve`, `USP_CM_R_Cashflow`, `USP_CM_R_CashflowBank`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Info`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_ReceiveAllocation_List`, `USP_CM_SalesInvoiceDetail_Info`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceTax_Info`, `USP_CM_SalesInvoiceTax_List`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesRefundTax_Info`, `USP_CM_SalesRefundTax_List`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Journal_List`, `USP_FA_AssetDisposal_Save`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_Reconciliation`, `USP_GL_COASearch_List`, `USP_GL_COA_Create`, `USP_GL_COA_Duplicate`, `USP_GL_COA_Info`, `USP_GL_COA_Update`, `USP_GL_JournalDetail_Create`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List`, `USP_GL_JournalDetail_Update`, `USP_GL_R_BalanceSheet`, `USP_GL_R_BalanceSheet_V2`, `USP_GL_R_CashflowStatement`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GL_R_TrialBalance`, `USP_GL_RecurringJournal_Generate`, `USP_GN_Branch_Info`, `USP_GN_DocumentType_Info`, `USP_GN_Partner_Info`, `USP_MC_A_Cash_Trend`, `USP_MC_A_Liquidity_Summary`, `USP_MC_A_Profitability_Trend`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasJournal_Create`, `USP_MC_Currency_Info`, `USP_MC_SalesOrderJournal_List`, `usp_CM_ClosingPeriod`

### GL_M_COACategory

Baris: 9 · PK: IDX_M_COACategory

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_COACategory` | bigint | N | IDENTITY |
| 2 | `IDX_M_COAType` | bigint | Y |  |
| 3 | `COACategoryID` | varchar(32) | Y |  |
| 4 | `COACategoryDesc` | varchar(256) | Y |  |
| 5 | `COACategoryDesc2` | varchar(512) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_COA_Info`

### GL_M_COAGroup1

Baris: 36 · PK: IDX_M_COAGroup1

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_COAGroup1` | int | N | IDENTITY |
| 2 | `IDX_M_COAType` | int | Y |  |
| 3 | `HeaderSort` | smallint | Y |  |
| 4 | `HeaderName1` | varchar(50) | Y |  |
| 5 | `HeaderName2` | varchar(50) | Y |  |
| 6 | `COAGroup1ID` | varchar(50) | Y |  |
| 7 | `COAGroup1Name1` | varchar(150) | Y |  |
| 8 | `COAGroup1Name2` | varchar(150) | Y |  |
| 9 | `UCreate` | varchar(36) | Y |  |
| 10 | `DCreate` | datetime | Y |  |
| 11 | `UModified` | varchar(36) | Y |  |
| 12 | `DModified` | datetime | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_COAGroup1_Create`, `USP_GL_COAGroup1_Info`, `USP_GL_COAGroup1_Update`, `USP_GL_COAGroup2_Info`, `USP_GL_R_BalanceSheet`, `USP_GL_R_BalanceSheet_V2`, `USP_GL_R_ProfitLoss`

### GL_M_COAGroup2

Baris: 0 · PK: IDX_M_COAGroup2

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_COAGroup2` | int | N | IDENTITY |
| 2 | `IDX_M_COAGroup1` | int | N |  |
| 3 | `COAGroup2ID` | varchar(50) | Y |  |
| 4 | `COAGroup2Name1` | varchar(150) | Y |  |
| 5 | `COAGroup2Name2` | varchar(150) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_COAGroup2_Create`, `USP_GL_COAGroup2_Info`, `USP_GL_COAGroup2_Update`, `USP_GL_COAGroup3_Info`

### GL_M_COAGroup3

Baris: 0 · PK: IDX_M_COAGroup3

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_COAGroup3` | int | N | IDENTITY |
| 2 | `IDX_M_COAGroup2` | int | N |  |
| 3 | `COAGroup3ID` | varchar(50) | Y |  |
| 4 | `COAGroup3Name1` | varchar(150) | Y |  |
| 5 | `COAGroup3Name2` | varchar(150) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_COAGroup3_Create`, `USP_GL_COAGroup3_Info`, `USP_GL_COAGroup3_Update`

### GL_M_COAType

Baris: 5 · PK: IDX_M_COAType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_COAType` | bigint | N | IDENTITY |
| 2 | `COATypeID` | char(2) | Y |  |
| 3 | `COATypeDesc` | varchar(256) | Y |  |
| 4 | `UCreate` | varchar(36) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_COAGroup1_Info`, `USP_GL_COA_Info`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GL_R_TrialBalance`, `usp_CM_ClosingPeriod`

### GL_M_FiscalPeriod

Baris: 0 · PK: IDX_M_FiscalPeriod

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_FiscalPeriod` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | Y |  |
| 4 | `FiscalPeriod` | varchar(6) | Y |  |
| 5 | `StartDate` | datetime | Y |  |
| 6 | `EndDate` | datetime | Y |  |
| 7 | `GLStatus` | char(1) | Y |  |
| 8 | `SalesStatus` | char(1) | Y |  |
| 9 | `PurchaseStatus` | char(1) | Y |  |
| 10 | `FinanceStatus` | char(1) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_ReverseValidate`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_PurchaseRefund_Approve`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Void`, `USP_GL_FiscalPeriod_Create`, `USP_GL_FiscalPeriod_Update`, `USP_GL_Journal_Posting`, `USP_GL_Journal_Unposting`

### GL_M_JournalType

Baris: 11 · PK: IDX_M_JournalType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_JournalType` | bigint | N | IDENTITY |
| 2 | `JournalTypeID` | varchar(32) | Y |  |
| 3 | `JournalTypeDesc` | varchar(64) | Y |  |
| 4 | `AllowJournalEntry` | char(1) | Y |  |
| 5 | `JournalLabel` | varchar(32) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_InsertJournal`, `USP_CM_FinancialPayment_Journal_List`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_Void`, `USP_CM_InternalTransfer_Validate`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PurchaseInvoice_Journal_Inquiry`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefund_Journal_List`, `USP_CM_SalesRefund_Void`, `USP_GL_JournalHeader_Info`, `USP_GL_JournalType_Create`, `USP_GL_JournalType_Info`, `USP_GL_JournalType_Update`, `USP_GL_Journal_Posting`, `USP_MC_SalesOrderJournal_List`

### GL_M_RecurringJournal

Baris: 1 · PK: IDX_M_RecurringJournal

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_RecurringJournal` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Branch` | int | Y |  |
| 4 | `RecurringCode` | varchar(32) | Y |  |
| 5 | `RecurringName` | varchar(200) | Y |  |
| 6 | `RecurringDesc` | varchar(5000) | Y |  |
| 7 | `IDX_M_COA_Debet` | bigint | Y |  |
| 8 | `IDX_M_COA_Credit` | bigint | Y |  |
| 9 | `RecurringAmount` | decimal(18,2) | Y |  |
| 10 | `TotalAmount` | decimal(18,2) | Y |  |
| 11 | `AdjustLastPeriod` | char(1) | Y |  |
| 12 | `StartPeriod` | varchar(6) | Y |  |
| 13 | `EndPeriod` | varchar(6) | Y |  |
| 14 | `RecurringStatus` | char(1) | Y |  |
| 15 | `UCreate` | varchar(36) | Y |  |
| 16 | `DCreate` | datetime | Y |  |
| 17 | `UModified` | varchar(36) | Y |  |
| 18 | `DModified` | datetime | Y |  |
| 19 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_RecurringJournal_Create`, `USP_GL_RecurringJournal_Generate`, `USP_GL_RecurringJournal_Info`, `USP_GL_RecurringJournal_Update`

### GL_M_Tax

Baris: 0 · PK: IDX_M_Tax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Tax` | bigint | N | IDENTITY |
| 2 | `TaxID` | varchar(64) | Y |  |
| 3 | `TaxName` | varchar(256) | Y |  |
| 4 | `TaxRate` | decimal(5,2) | Y |  |
| 5 | `BaseAmount` | decimal(5,2) | Y |  |
| 6 | `Flag` | varchar(8) | Y |  |
| 7 | `Notes` | varchar(8000) | Y |  |
| 8 | `COAIn` | bigint | Y |  |
| 9 | `COAOut` | bigint | Y |  |
| 10 | `IsWithHoldingTax` | bit | Y |  |
| 11 | `DCreate` | datetime | Y |  |
| 12 | `UCreate` | varchar(36) | Y |  |
| 13 | `DModified` | datetime | Y |  |
| 14 | `UModified` | varchar(36) | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PurchaseInvoiceDetail_Create`, `USP_CM_PurchaseInvoiceDetail_Update`, `USP_CM_PurchaseInvoiceTax_Create`, `USP_CM_PurchaseInvoiceTax_Update`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_PurchaseRefund_Approve`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_SalesInvoiceDetail_Create`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceDetail_Update`, `USP_CM_SalesInvoiceTax_Create`, `USP_CM_SalesInvoiceTax_Update`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesRefund_Approve`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_PurchaseOrderDetail_Save`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `USP_MC_SalesOrderDetail_Save`

### GL_T_AccountBalance

Baris: 0 · PK: IDX_GL_T_AccountBalance

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_GL_T_AccountBalance` | bigint | N | IDENTITY |
| 2 | `JournalPeriod` | char(6) | N |  |
| 3 | `IDX_M_Company` | bigint | N |  |
| 4 | `IDX_M_Department` | bigint | Y |  |
| 5 | `IDX_M_Project` | bigint | Y |  |
| 6 | `IDX_M_Branch` | bigint | Y |  |
| 7 | `IDX_M_COA` | bigint | N |  |
| 8 | `COADescription` | varchar(8000) | Y |  |
| 9 | `CurrencyID` | char(3) | Y |  |
| 10 | `BBBalance` | decimal(20,4) | Y |  |
| 11 | `BDebetAmount` | decimal(20,4) | Y |  |
| 12 | `BCreditAmount` | decimal(20,4) | Y |  |
| 13 | `BEndingBalance` | decimal(20,4) | Y |  |
| 14 | `TBBalance` | decimal(20,4) | Y |  |
| 15 | `TDebetAmount` | decimal(20,4) | Y |  |
| 16 | `TCreditAmount` | decimal(20,4) | Y |  |
| 17 | `TEndingBalance` | decimal(20,4) | Y |  |
| 18 | `Notes` | varchar(8000) | Y |  |
| 19 | `UCreate` | varchar(36) | Y |  |
| 20 | `DCreate` | datetime | Y |  |
| 21 | `UModified` | varchar(36) | Y |  |
| 22 | `DModified` | datetime | Y |  |
| 23 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_BankTransfer_Period`, `USP_CM_R_CashflowBank`, `USP_GL_R_GeneralLedger`, `USP_GL_R_TrialBalance`, `usp_CM_ClosingPeriod`

### GL_T_JournalCashflow

Baris: 0 · PK: IDX_T_JournalCashflow

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_JournalCashflow` | bigint | N | IDENTITY |
| 2 | `IDX_T_JournalDetail` | bigint | Y |  |
| 3 | `IDX_M_CashflowID` | bigint | Y |  |
| 4 | `Amount` | decimal(22,4) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(10) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GL_T_JournalDetail

Baris: 32093 · PK: IDX_T_JournalDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_JournalDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_JournalHeader` | bigint | N |  |
| 3 | `IDX_M_Project` | bigint | Y |  |
| 4 | `IDX_M_Department` | bigint | Y |  |
| 5 | `IDX_M_COA` | bigint | N |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `IDX_M_CashflowID` | bigint | Y |  |
| 8 | `JournalSeqNo` | int | Y |  |
| 9 | `COADescription` | varchar(8000) | N |  |
| 10 | `RemarkDetail` | varchar(8000) | Y |  |
| 11 | `OriginalCurrencyID` | int | Y |  |
| 12 | `ODebetAmount` | decimal(22,4) | Y |  |
| 13 | `OCreditAmount` | decimal(22,4) | Y |  |
| 14 | `ExchangeRate` | decimal(22,4) | N |  |
| 15 | `BaseCurrencyID` | int | N |  |
| 16 | `BDebetAmount` | decimal(22,4) | Y |  |
| 17 | `BCreditAmount` | decimal(22,4) | Y |  |
| 18 | `UCreate` | varchar(36) | Y |  |
| 19 | `DCreate` | datetime | Y |  |
| 20 | `UModified` | varchar(36) | Y |  |
| 21 | `DModified` | datetime | Y |  |
| 22 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_InsertJournal`, `USP_CM_BankStatement_LedgerBalance`, `USP_CM_BankStatement_LedgerLines`, `USP_CM_BankStatement_Match_Save`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialPayment_Journal_List`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Delete`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_FinancialReceive_Void`, `USP_CM_InternalTransfer_Approve`, `USP_CM_InternalTransfer_Journal_List`, `USP_CM_InternalTransfer_ReverseValidate`, `USP_CM_InternalTransfer_Validate`, `USP_CM_InternalTransfer_Void`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Journal_List`, `USP_CM_PettyCash_Reopen`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Journal_Inquiry`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_PurchaseInvoice_ReverseValidate`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_PurchaseRefund_Approve`, `USP_CM_R_Cashflow`, `USP_CM_R_CashflowBank`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Journal_List`, `USP_CM_SalesRefund_Void`, `USP_FA_AssetDisposal_Save`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_Reconciliation`, `USP_GL_CheckJournalBalance`, `USP_GL_JournalDetail_Create`, `USP_GL_JournalDetail_Delete`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List`, `USP_GL_JournalDetail_Update`, `USP_GL_Journal_Duplicate`, `USP_GL_Journal_Posting`, `USP_GL_R_CashflowStatement`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GL_R_TrialBalance`, `USP_GL_RecurringJournal_Generate`, `USP_MC_A_Cash_Trend`, `USP_MC_A_Liquidity_Summary`, `USP_MC_A_Profitability_Trend`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasJournal_Create`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderJournal_List`, `USP_MC_SalesOrder_Reverse`, `usp_CM_ClosingPeriod`

### GL_T_JournalHeader

Baris: 10438 · PK: IDX_T_JournalHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_JournalHeader` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `IDX_M_JournalType` | int | Y |  |
| 5 | `IDX_M_Partner` | bigint | Y |  |
| 6 | `ApplicationID` | bigint | Y |  |
| 7 | `IDX_ReferenceNo` | bigint | Y |  |
| 8 | `ReferenceNo` | varchar(32) | Y |  |
| 9 | `VoucherNo` | varchar(32) | Y |  |
| 10 | `VoucherNoManual` | varchar(50) | Y |  |
| 11 | `JournalDate` | datetime | Y |  |
| 12 | `JournalPeriod` | varchar(6) | Y |  |
| 13 | `RemarkHeader` | varchar(8000) | Y |  |
| 14 | `PartnerDesc` | varchar(256) | Y |  |
| 15 | `PostingStatus` | char(1) | Y |  |
| 16 | `PostingDate` | datetime | Y |  |
| 17 | `PostedBy` | varchar(36) | Y |  |
| 18 | `PostingNotes` | varchar(150) | Y |  |
| 19 | `DebetAmount` | decimal(22,4) | Y |  |
| 20 | `CreditAmount` | decimal(22,4) | Y |  |
| 21 | `JournalSource` | char(1) | Y |  |
| 22 | `UCreate` | varchar(36) | Y |  |
| 23 | `DCreate` | datetime | Y |  |
| 24 | `UModified` | varchar(36) | Y |  |
| 25 | `DModified` | datetime | Y |  |
| 26 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatementDetail_List`, `USP_CM_BankStatementDetail_SetAdminFee`, `USP_CM_BankStatement_AdjustmentLinks`, `USP_CM_BankStatement_CreateAdjustmentJournal`, `USP_CM_BankStatement_CreateAdminFeeJournal`, `USP_CM_BankStatement_CreateJournal`, `USP_CM_BankStatement_CreateMergedJournal`, `USP_CM_BankStatement_Delete`, `USP_CM_BankStatement_Info`, `USP_CM_BankStatement_InsertJournal`, `USP_CM_BankStatement_LedgerBalance`, `USP_CM_BankStatement_LedgerLines`, `USP_CM_BankStatement_List`, `USP_CM_BankStatement_Match_Save`, `USP_CM_BankStatement_MonthEndRows`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialPayment_Journal_List`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Delete`, `USP_CM_FinancialReceive_Journal_List`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_FinancialReceive_Void`, `USP_CM_InternalTransfer_Approve`, `USP_CM_InternalTransfer_Journal_List`, `USP_CM_InternalTransfer_ReverseValidate`, `USP_CM_InternalTransfer_Validate`, `USP_CM_InternalTransfer_Void`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Journal_List`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Journal_List`, `USP_CM_PettyCash_Reopen`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Journal_Inquiry`, `USP_CM_PurchaseInvoice_Journal_List`, `USP_CM_PurchaseInvoice_ReverseValidate`, `USP_CM_PurchaseInvoice_Void`, `USP_CM_PurchaseRefund_Approve`, `USP_CM_R_Cashflow`, `USP_CM_R_CashflowBank`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Journal_List`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Journal_List`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Journal_List`, `USP_CM_SalesRefund_Void`, `USP_FA_AssetDisposal_Save`, `USP_FA_GenerateJournalDepreciation`, `USP_FA_R_Reconciliation`, `USP_GL_CheckJournalBalance`, `USP_GL_JournalDetail_Create`, `USP_GL_JournalDetail_Delete`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List`, `USP_GL_JournalDetail_Update`, `USP_GL_JournalHeader_Create`, `USP_GL_JournalHeader_Info`, `USP_GL_JournalHeader_Update`, `USP_GL_Journal_Duplicate`, `USP_GL_Journal_Posting`, `USP_GL_Journal_Unposting`, `USP_GL_R_CashflowStatement`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GL_R_TrialBalance`, `USP_GL_RecurringJournal_Generate`, `USP_GN_Attachment_Save`, `USP_MC_A_Cash_Trend`, `USP_MC_A_Liquidity_Summary`, `USP_MC_A_Profitability_Trend`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasJournal_Create`, `USP_MC_GenerateJournalCOGSValas`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderJournal_List`, `USP_MC_SalesOrder_Reverse`, `usp_CM_ClosingPeriod`

### GL_T_JournalHeaderLog

Baris: 224 · PK: IDX_T_JournalHeaderLog

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_JournalHeaderLog` | bigint | N | IDENTITY |
| 2 | `IDX_T_JournalHeader` | bigint | N |  |
| 3 | `LogType` | varchar(50) | Y |  |
| 4 | `LogDate` | datetime | Y |  |
| 5 | `LogRemark` | varchar(500) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_PurchaseInvoice_ReverseValidate`, `USP_CM_SalesInvoice_ReverseValidate`, `USP_CM_SalesRefund_Approve`, `USP_GL_Journal_Posting`, `USP_GL_Journal_Unposting`

### GL_T_ReconcileDetail

Baris: 0 · PK: IDX_GL_T_ReconcileDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_GL_T_ReconcileDetail` | bigint | N |  |
| 2 | `IDX_GL_T_ReconcileHeader` | bigint | N |  |
| 3 | `ReconcileDate` | datetime | Y |  |
| 4 | `IDX_JournalItem` | bigint | Y |  |
| 5 | `IDX_GL_M_COA` | bigint | Y |  |
| 6 | `DebetAmount` | decimal(22,2) | Y |  |
| 7 | `CreditAmount` | decimal(22,2) | Y |  |
| 8 | `UCreate` | varchar(36) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UModified` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

### GL_T_ReconcileHeader

Baris: 0 · PK: IDX_GL_T_ReconcileHeader

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_GL_T_ReconcileHeader` | bigint | N |  |
| 2 | `ReconcileDate` | bigint | N |  |
| 3 | `IDX_JournalItem` | bigint | Y |  |
| 4 | `IDX_GL_M_COA` | bigint | Y |  |
| 5 | `TotalDebetAmount` | decimal(22,2) | Y |  |
| 6 | `TotalCreditAmount` | decimal(22,2) | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `RecordStatus` | varchar(1) | Y |  |

### GL_T_RecurringJournalLog

Baris: 4 · PK: IDX_T_RecurringJournalLog

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_RecurringJournalLog` | bigint | N | IDENTITY |
| 2 | `IDX_M_RecurringJournal` | bigint | Y |  |
| 3 | `RecurringPeriod` | varchar(6) | Y |  |
| 4 | `IDX_T_JournalHeader` | bigint | Y |  |
| 5 | `GeneratedAmount` | decimal(18,2) | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GL_RecurringJournal_Generate`, `USP_GL_RecurringJournal_Update`

### GN_M_AddressType

Baris: 3 · PK: IDX_M_AddressType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_AddressType` | bigint | N | IDENTITY |
| 2 | `AddressTypeName` | varchar(256) | Y |  |
| 3 | `AddressTypeAlias` | varchar(50) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PartnerAddress_Info`, `USP_GN_PartnerAddress_Info`, `USP_GN_PartnerAddress_List`

### GN_M_Bank

Baris: 2 · PK: IDX_M_Bank

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Bank` | bigint | N | IDENTITY |
| 2 | `BankCode` | varchar(32) | Y |  |
| 3 | `BankName` | varchar(64) | Y |  |
| 4 | `BankAlias` | varchar(32) | Y |  |
| 5 | `Notes` | varchar(8000) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `Recordstatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialAccount_Info`, `USP_GN_Bank_Info`, `USP_GN_Bank_Save`, `USP_GN_PartnerBank_Info`, `USP_GN_PartnerBank_List`

### GN_M_BankCardPattern

Baris: 0 · PK: IDX_M_CardPattern

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_CardPattern` | bigint | N | IDENTITY |
| 2 | `IDX_M_CardType` | bigint | Y |  |
| 3 | `CardPattern` | float | Y |  |
| 4 | `DCreate` | datetime | Y |  |
| 5 | `UCreate` | varchar(36) | Y |  |
| 6 | `DModified` | datetime | Y |  |
| 7 | `UModified` | varchar(36) | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_SalesInvoice_Item_Backup`

### GN_M_BankCardType

Baris: 0 · PK: IDX_M_CardType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_CardType` | bigint | N | IDENTITY |
| 2 | `IDX_M_Bank` | bigint | Y |  |
| 3 | `IDX_M_BankMerchant` | bigint | Y |  |
| 4 | `Name` | varchar(256) | Y |  |
| 5 | `Type` | varchar(32) | Y |  |
| 6 | `Alias` | varchar(64) | Y |  |
| 7 | `Notes` | varchar(8000) | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UCreate` | varchar(36) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `UModified` | varchar(36) | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_SalesInvoice_Item_Backup`

### GN_M_BankMerchant

Baris: 0 · PK: IDX_M_BankMerchant

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_BankMerchant` | bigint | N | IDENTITY |
| 2 | `BankMerchantCode` | varchar(32) | Y |  |
| 3 | `BankMerchantName` | varchar(64) | Y |  |
| 4 | `BankMerchantAlias` | varchar(32) | Y |  |
| 5 | `Notes` | varchar(8000) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `Recordstatus` | varchar(1) | Y |  |

### GN_M_Branch

Baris: 2 · PK: IDX_M_Branch

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Branch` | bigint | N | IDENTITY |
| 2 | `IDX_M_Parent` | int | Y |  |
| 3 | `IDX_M_Company` | bigint | Y |  |
| 4 | `IDX_M_LocationInventory` | bigint | Y |  |
| 5 | `BranchID` | varchar(50) | Y |  |
| 6 | `BranchName` | varchar(250) | Y |  |
| 7 | `BranchAlias` | varchar(50) | Y |  |
| 8 | `BranchAddress` | varchar(500) | Y |  |
| 9 | `BranchRemark` | varchar(500) | Y |  |
| 10 | `COAAR` | int | Y |  |
| 11 | `COASales` | int | Y |  |
| 12 | `FlagSystem` | varchar(5) | Y |  |
| 13 | `IsProfitSharing` | bit | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UCreate` | varchar(10) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `UModified` | varchar(10) | Y |  |
| 18 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_Save`, `USP_CM_Branch_Info`, `USP_CM_Branch_Update`, `USP_CM_FinancialAccount_Create`, `USP_CM_FinancialAccount_Info`, `USP_CM_FinancialPaymentHeader_Create`, `USP_CM_FinancialPayment_Approve`, `USP_CM_FinancialPayment_Info`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_FinancialReceiveHeader_Create`, `USP_CM_FinancialReceiveHeader_Update`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_Info`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_FinancialReceive_Void`, `USP_CM_InternalTransfer_Info`, `USP_CM_InternalTransfer_Validate`, `USP_CM_PettyCashHeader_Create`, `USP_CM_PettyCash_Close`, `USP_CM_PettyCash_Info`, `USP_CM_PettyCash_List`, `USP_CM_PurchaseInvoiceHeader_Create`, `USP_CM_PurchaseInvoiceHeader_Update`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_FinancialReceive_Period`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_SalesInvoiceHeader_Create`, `USP_CM_SalesInvoiceHeader_Update`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefund_Approve`, `USP_CM_SalesRefund_Void`, `USP_FA_Asset_Create`, `USP_FA_Asset_GenerateCode`, `USP_FA_R_AssetCard`, `USP_FA_R_AssetList`, `USP_FA_R_DepreciationSchedule`, `USP_GL_FiscalPeriod_Create`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List`, `USP_GL_JournalHeader_Create`, `USP_GL_JournalHeader_Info`, `USP_GL_Journal_Posting`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GL_R_TrialBalance`, `USP_GN_Branch_Info`, `USP_GN_Branch_Save`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasJournal_Create`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_PurchaseOrder_Payment`, `USP_MC_R_AP`, `USP_MC_R_AR`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_StockCard`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrder_Approve`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_NotaKasir`, `USP_MC_SalesOrder_Payment`, `USP_SM_UserBranch_List`

### GN_M_BusinessType

Baris: 0 · PK: IDX_M_BusinessType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_BusinessType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_Company

Baris: 1 · PK: IDX_M_Company

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Company` | int | N | IDENTITY |
| 2 | `IDX_M_Parent` | int | Y |  |
| 3 | `IDX_M_Currency` | int | Y |  |
| 4 | `CompanyID` | varchar(32) | Y |  |
| 5 | `CompanyName` | varchar(128) | Y |  |
| 6 | `CompanyAlias` | varchar(32) | Y |  |
| 7 | `SIUP` | varchar(64) | Y |  |
| 8 | `NPWP` | varchar(64) | Y |  |
| 9 | `PKPIdentityNumber` | varchar(64) | Y |  |
| 10 | `PKPDate` | date | Y |  |
| 11 | `Phone` | varchar(32) | Y |  |
| 12 | `WhatsappNo` | varchar(50) | Y |  |
| 13 | `Fax` | varchar(32) | Y |  |
| 14 | `Email` | varchar(256) | Y |  |
| 15 | `LegalAddress` | varchar(256) | Y |  |
| 16 | `Country` | varchar(64) | Y |  |
| 17 | `Province` | varchar(64) | Y |  |
| 18 | `City` | varchar(64) | Y |  |
| 19 | `Subdistrict` | varchar(64) | Y |  |
| 20 | `District` | varchar(64) | Y |  |
| 21 | `Zip` | varchar(16) | Y |  |
| 22 | `BankAccountNumber` | varchar(25) | Y |  |
| 23 | `BankName` | varchar(100) | Y |  |
| 24 | `Logo` | varchar(256) | Y |  |
| 25 | `Website` | varchar(256) | Y |  |
| 26 | `Remarks` | varchar(256) | Y |  |
| 27 | `RetainedEarningAccount` | int | Y |  |
| 28 | `CurrentEarningAccount` | int | Y |  |
| 29 | `DCreate` | datetime | Y |  |
| 30 | `UCreate` | varchar(36) | Y |  |
| 31 | `DModified` | datetime | Y |  |
| 32 | `UModified` | varchar(36) | Y |  |
| 33 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_Company_Info`, `USP_CM_FinancialAccount_Info`, `USP_CM_FinancialPayment_Info`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialReceive_Info`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_InternalTransfer_Info`, `USP_CM_PettyCash_Info`, `USP_CM_PettyCash_List`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_FinancialReceive_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_SalesInvoice_Info`, `USP_GL_JournalDetail_Create`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List`, `USP_GL_JournalDetail_Update`, `USP_GL_JournalHeader_Info`, `USP_GL_R_BalanceSheet`, `USP_GL_R_BalanceSheet_V2`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GL_R_TrialBalance`, `USP_GN_Company_Info`, `USP_GN_Company_Save`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_R_InventoryCalculation`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_NotaKasir`, `usp_CM_ClosingPeriod`

### GN_M_Country

Baris: 26 · PK: IDX_M_Country

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Country` | int | N | IDENTITY |
| 2 | `CountryID` | varchar(50) | Y |  |
| 3 | `CountryName` | varchar(500) | Y |  |
| 4 | `DCreate` | datetime | Y |  |
| 5 | `UCreate` | varchar(36) | Y |  |
| 6 | `DModified` | datetime | Y |  |
| 7 | `UModified` | varchar(36) | Y |  |
| 8 | `Recordstatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GN_Country_Info`, `USP_GN_Country_Save`, `USP_GN_Currency_Info`, `USP_MC_Currency_Info`

### GN_M_Currency

Baris: 19 · PK: IDX_M_Currency

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Currency` | int | N | IDENTITY |
| 2 | `IDX_M_Country` | int | Y |  |
| 3 | `CurrencyID` | varchar(3) | Y |  |
| 4 | `CurrencyName` | varchar(32) | Y |  |
| 5 | `Symbol` | varchar(8) | Y |  |
| 6 | `Remarks` | varchar(128) | Y |  |
| 7 | `Rounding` | decimal(18,4) | Y |  |
| 8 | `Accuracy` | int | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `Recordstatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_InsertJournal`, `USP_CM_FinancialAccount_Info`, `USP_CM_PettyCash_Close`, `USP_CM_PurchaseInvoiceDetail_Info`, `USP_CM_PurchaseInvoiceDetail_List`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_FinancialReceive_Period`, `USP_CM_SalesInvoiceDetail_Info`, `USP_CM_SalesInvoiceDetail_List`, `USP_GL_JournalDetail_List`, `USP_GN_Currency_Info`, `USP_GN_Currency_Save`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `usp_CM_ClosingPeriod`

### GN_M_CurrencyRate

Baris: 0 · PK: IDX_M_CurrencyRate

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_CurrencyRate` | int | N | IDENTITY |
| 2 | `IDX_M_Currency` | int | N |  |
| 3 | `TransactionDate` | date | N |  |
| 4 | `SellingRate` | decimal(18,2) | Y |  |
| 5 | `BuyingRate` | decimal(18,2) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `Recordstatus` | varchar(1) | Y |  |

### GN_M_Department

Baris: 4 · PK: IDX_M_Department

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Department` | bigint | N | IDENTITY |
| 2 | `DepartmentID` | varchar(50) | Y |  |
| 3 | `DepartmentName` | varchar(150) | Y |  |
| 4 | `DCreate` | datetime | Y |  |
| 5 | `UCreate` | varchar(36) | Y |  |
| 6 | `DModified` | datetime | Y |  |
| 7 | `UModified` | varchar(36) | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_FA_R_AssetList`, `USP_GN_Department_Info`, `USP_GN_Department_Save`, `USP_SM_UserDepartment_List`

### GN_M_DocumentType

Baris: 13 · PK: IDX_M_DocumentType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_DocumentType` | bigint | N | IDENTITY |
| 2 | `DocumentTypeCategory` | varchar(50) | Y |  |
| 3 | `DocumentTypeID` | varchar(5) | Y |  |
| 4 | `DocumentTypeDesc` | varchar(50) | Y |  |
| 5 | `TableReferenceHeader` | varchar(150) | Y |  |
| 6 | `TableReferenceDetail` | varchar(150) | Y |  |
| 7 | `InFlag` | char(1) | Y |  |
| 8 | `OutFlag` | char(1) | Y |  |
| 9 | `ARAccount` | bigint | Y |  |
| 10 | `APAccount` | bigint | Y |  |
| 11 | `UCreate` | varchar(10) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(10) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Info`, `USP_CM_FinancialPaymentDetail_List`, `USP_CM_FinancialPayment_ReverseApproval`, `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialReceiveDetail_Info`, `USP_CM_FinancialReceiveDetail_List`, `USP_CM_FinancialReceive_Approve`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_FinancialReceive_ReverseValidate`, `USP_CM_InternalTransferDetail_Info`, `USP_CM_InternalTransferDetail_List`, `USP_CM_InternalTransfer_Validate`, `USP_CM_PaymentAllocation_Info`, `USP_CM_PaymentAllocation_List`, `USP_CM_PettyCashDetail_List`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_PurchaseRefund_Approve`, `USP_CM_ReceiveAllocation_Info`, `USP_CM_ReceiveAllocation_List`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_OS_List`, `USP_CM_SalesInvoice_Payment`, `USP_CM_SalesRefund_Approve`, `USP_GN_DocumentType_Info`, `USP_GN_DocumentType_Update`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_PurchaseOrder_Payment`, `USP_MC_SalesOrder_Approve`, `USP_MC_SalesOrder_Payment`

### GN_M_DTTOT

Baris: 531 · PK: IDX_M_DTTOT

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_DTTOT` | bigint | N | IDENTITY |
| 2 | `FullName` | varchar(1000) | Y |  |
| 3 | `Description` | varchar(max) | Y |  |
| 4 | `SuspectType` | varchar(50) | Y |  |
| 5 | `DensusCode` | varchar(50) | Y |  |
| 6 | `PlaceOfBirth` | varchar(500) | Y |  |
| 7 | `DateOfBirth` | varchar(200) | Y |  |
| 8 | `Nationality` | varchar(500) | Y |  |
| 9 | `Address` | varchar(2000) | Y |  |
| 10 | `FileName` | varchar(256) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GN_DTTOT_Clear`, `USP_GN_DTTOT_Save`, `USP_GN_DTTOT_Screening`

### GN_M_Gender

Baris: 2 · PK: IDX_M_Gender

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Gender` | bigint | N | IDENTITY |
| 2 | `GenderID` | varchar(64) | Y |  |
| 3 | `GenderName` | varchar(256) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_Global

Baris: 0 · PK: IDX_M_Global

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Global` | bigint | N | IDENTITY |
| 2 | `CodeGlobal` | varchar(256) | Y |  |
| 3 | `CodeGroup` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `Attribute1` | varchar(8000) | Y |  |
| 6 | `Attribute2` | varchar(8000) | Y |  |
| 7 | `Attribute3` | varchar(8000) | Y |  |
| 8 | `Attribute4` | varchar(8000) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `Recordstatus` | varchar(1) | Y |  |

### GN_M_IDType

Baris: 5 · PK: IDX_M_IDType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_IDType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GN_Partner_Info`, `USP_GN_Partner_Save`

### GN_M_Membership

Baris: 0 · PK: IDX_M_Membership

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Membership` | bigint | N | IDENTITY |
| 2 | `IDX_M_Partner` | bigint | N |  |
| 3 | `IDX_M_MemberType` | bigint | Y |  |
| 4 | `MembershipCode` | varchar(32) | Y |  |
| 5 | `JoinDate` | date | Y |  |
| 6 | `ExpiredDate` | date | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UCreate` | varchar(36) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `UModified` | varchar(36) | Y |  |
| 11 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_MemberType

Baris: 0 · PK: IDX_M_MemberType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_MemberType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Code` | varchar(32) | Y |  |
| 5 | `Notes` | varchar(8000) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_Menu

Baris: 0 · PK: IDX_M_Menu

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Menu` | bigint | N | IDENTITY |
| 2 | `IDX_M_Parent` | bigint | N |  |
| 3 | `FormID` | varchar(32) | Y |  |
| 4 | `OrderNo` | int | Y |  |
| 5 | `Name` | varchar(64) | Y |  |
| 6 | `Alias` | varchar(64) | Y |  |
| 7 | `Notes` | varchar(8000) | Y |  |
| 8 | `Url` | varchar(8000) | Y |  |
| 9 | `Host` | varchar(64) | Y |  |
| 10 | `Logo` | varchar(64) | Y |  |
| 11 | `Status` | varchar(32) | Y |  |
| 12 | `Category` | varchar(1) | Y |  |
| 13 | `IsVerification` | varchar(1) | Y |  |
| 14 | `IsExternal` | varchar(1) | Y |  |
| 15 | `Domain` | varchar(64) | Y |  |
| 16 | `CodeGlobal` | varchar(64) | Y |  |
| 17 | `DCreate` | datetime | Y |  |
| 18 | `UCreate` | varchar(36) | Y |  |
| 19 | `DModified` | datetime | Y |  |
| 20 | `UModified` | varchar(36) | Y |  |
| 21 | `Recordstatus` | varchar(1) | Y |  |

### GN_M_Partner

Baris: 2609 · PK: IDX_M_Partner

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Partner` | bigint | N | IDENTITY |
| 2 | `IDX_M_Parent` | bigint | Y |  |
| 3 | `Prefix` | varchar(8) | Y |  |
| 4 | `PartnerID` | varchar(32) | N |  |
| 5 | `BarcodeMember` | varchar(50) | Y |  |
| 6 | `PartnerName` | varchar(256) | Y |  |
| 7 | `PartnerAlias` | varchar(256) | Y |  |
| 8 | `Gender` | char(1) | Y |  |
| 9 | `SingleIdentityNumber` | varchar(64) | Y |  |
| 10 | `TaxIdentityNumber` | varchar(64) | Y |  |
| 11 | `DateOfBirth` | date | Y |  |
| 12 | `PlaceOfBirth` | varchar(64) | Y |  |
| 13 | `Email` | varchar(128) | Y |  |
| 14 | `Phone1` | varchar(128) | Y |  |
| 15 | `Phone2` | varchar(128) | Y |  |
| 16 | `FaxNo` | varchar(128) | Y |  |
| 17 | `MobilePhone` | varchar(128) | Y |  |
| 18 | `Remarks` | varchar(1000) | Y |  |
| 19 | `IsSupplier` | char(1) | Y |  |
| 20 | `IsCustomer` | char(1) | Y |  |
| 21 | `IsCompany` | char(1) | Y |  |
| 22 | `IsMember` | char(1) | Y |  |
| 23 | `IsDTTOT` | char(1) | Y |  |
| 24 | `StartDate` | date | Y |  |
| 25 | `EndDate` | date | Y |  |
| 26 | `StartPeriod` | date | Y |  |
| 27 | `EndPeriod` | date | Y |  |
| 28 | `ARAccount` | bigint | Y |  |
| 29 | `APAccount` | bigint | Y |  |
| 30 | `ActiveStatus` | char(1) | Y |  |
| 31 | `CreditLimit` | decimal(22,2) | Y |  |
| 32 | `DiscountMember` | decimal(5,2) | Y |  |
| 33 | `BankName` | varchar(256) | Y |  |
| 34 | `BranchName` | varchar(256) | Y |  |
| 35 | `BranchCode` | varchar(64) | Y |  |
| 36 | `AccountNumber` | varchar(32) | Y |  |
| 37 | `AccountName` | varchar(256) | Y |  |
| 38 | `DCreate` | datetime | Y |  |
| 39 | `UCreate` | varchar(36) | Y |  |
| 40 | `DModified` | datetime | Y |  |
| 41 | `UModified` | varchar(36) | Y |  |
| 42 | `RecordStatus` | varchar(1) | Y |  |
| 43 | `IDX_M_IDType` | bigint | Y |  |

Dipakai oleh: `USP_CM_BankStatement_InsertJournal`, `USP_CM_FinancialDetail_DocumentSearch`, `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialPayment_Info`, `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Validate-BACKUP`, `USP_CM_FinancialPayment_Void`, `USP_CM_FinancialReceive_CreateJournal`, `USP_CM_FinancialReceive_Info`, `USP_CM_FinancialReceive_Void`, `USP_CM_PartnerAddress_Info`, `USP_CM_Partner_Create`, `USP_CM_Partner_Info`, `USP_CM_Partner_Save`, `USP_CM_Partner_Update`, `USP_CM_PaymentAllocation_Approve`, `USP_CM_PaymentAllocation_Info`, `USP_CM_PaymentAllocation_List`, `USP_CM_PurchaseInvoiceDetail_Info`, `USP_CM_PurchaseInvoice_Approve`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_R_PurchaseInvoice_Period`, `USP_CM_R_PurchaseInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`, `USP_CM_ReceiveAllocation_Approve`, `USP_CM_ReceiveAllocation_Info`, `USP_CM_ReceiveAllocation_List`, `USP_CM_SalesInvoiceDetail_Info`, `USP_CM_SalesInvoice_Approve`, `USP_CM_SalesInvoice_FakturHeader_Export`, `USP_CM_SalesInvoice_Info`, `USP_CM_SalesRefund_Approve`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List`, `USP_GL_JournalHeader_Info`, `USP_GL_R_GeneralLedger`, `USP_GN_DTTOT_Screening`, `USP_GN_PartnerAddress_Info`, `USP_GN_PartnerAddress_List`, `USP_GN_PartnerBank_Info`, `USP_GN_PartnerBank_List`, `USP_GN_Partner_Info`, `USP_GN_Partner_Save`, `USP_GN_Partner_SetDTTOT`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasJournal_Create`, `USP_MC_LTKM_Preview`, `USP_MC_LTKM_Save`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_R_AP`, `USP_MC_R_AR`, `USP_MC_R_Customer`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_Transaction`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_NotaKasir`

### GN_M_Partner_MergeBackup_20260815

Baris: 4 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Partner` | bigint | Y |  |
| 2 | `IDX_Dipertahankan` | bigint | Y |  |
| 3 | `PartnerID` | varchar(50) | Y |  |
| 4 | `PartnerName` | varchar(150) | Y |  |
| 5 | `SingleIdentityNumber` | varchar(64) | Y |  |
| 6 | `MobilePhone` | varchar(50) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UCreate` | varchar(36) | Y |  |
| 9 | `DBackup` | datetime | Y |  |

### GN_M_PartnerAccountHistory

Baris: 0 · PK: IDX_M_PartnerAccountHistory

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerAccountHistory` | bigint | N | IDENTITY |
| 2 | `IDX_M_Partner` | bigint | N |  |
| 3 | `BankName` | varchar(256) | N |  |
| 4 | `BranchName` | varchar(256) | Y |  |
| 5 | `BranchCode` | varchar(64) | Y |  |
| 6 | `AccountNumber` | varchar(32) | N |  |
| 7 | `AccountName` | varchar(256) | N |  |
| 8 | `StartDate` | datetime | Y |  |
| 9 | `EndDate` | datetime | Y |  |
| 10 | `DCreate` | datetime | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DModified` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_PartnerAddress

Baris: 2275 · PK: IDX_M_PartnerAddress

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerAddress` | bigint | N | IDENTITY |
| 2 | `IDX_M_Partner` | bigint | N |  |
| 3 | `IDX_M_AddressType` | bigint | N |  |
| 4 | `IDX_M_PostalCode` | bigint | Y |  |
| 5 | `IsDefault` | char(1) | Y |  |
| 6 | `Street` | varchar(1024) | Y |  |
| 7 | `Zip` | varchar(32) | Y |  |
| 8 | `Notes` | varchar(8000) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PartnerAddress_Create`, `USP_CM_PartnerAddress_Delete`, `USP_CM_PartnerAddress_Info`, `USP_CM_PartnerAddress_Update`, `USP_CM_SalesInvoice_FakturHeader_Export`, `USP_CM_SalesInvoice_Info`, `USP_GN_PartnerAddress_Info`, `USP_GN_PartnerAddress_List`, `USP_GN_PartnerQuickAddress_Create`, `USP_MC_LTKM_Save`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_R_Customer`, `USP_MC_SalesOrder_NotaKasir`

### GN_M_PartnerAddress_MergeBackup_20260815

Baris: 4 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerAddress` | bigint | Y |  |
| 2 | `IDX_M_Partner` | bigint | Y |  |
| 3 | `IDX_M_AddressType` | bigint | Y |  |
| 4 | `IDX_M_PostalCode` | bigint | Y |  |
| 5 | `IsDefault` | char(1) | Y |  |
| 6 | `Street` | varchar(1024) | Y |  |
| 7 | `Zip` | varchar(32) | Y |  |
| 8 | `Tindakan` | varchar(20) | Y |  |
| 9 | `DBackup` | datetime | Y |  |

### GN_M_PartnerBank

Baris: 7 · PK: IDX_M_PartnerBank

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerBank` | bigint | N | IDENTITY |
| 2 | `IDX_M_Partner` | bigint | N |  |
| 3 | `IDX_M_Bank` | bigint | Y |  |
| 4 | `IsDefault` | char(1) | Y |  |
| 5 | `BankAccountNo` | varchar(50) | Y |  |
| 6 | `BankAccountName` | varchar(50) | Y |  |
| 7 | `BankAccountBranch` | varchar(50) | Y |  |
| 8 | `Remarks` | varchar(50) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GN_PartnerBank_Delete`, `USP_GN_PartnerBank_Info`, `USP_GN_PartnerBank_List`, `USP_GN_PartnerBank_Save`

### GN_M_PartnerContact

Baris: 0 · PK: IDX_M_PartnerContact

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerContact` | bigint | N | IDENTITY |
| 2 | `IDX_M_Partner` | bigint | N |  |
| 3 | `ContactType` | int | Y |  |
| 4 | `IsDefault` | char(1) | Y |  |
| 5 | `Prefix` | varchar(50) | Y |  |
| 6 | `ContactName` | varchar(500) | Y |  |
| 7 | `Phone` | varchar(64) | Y |  |
| 8 | `Fax` | varchar(64) | Y |  |
| 9 | `Mobile` | varchar(64) | Y |  |
| 10 | `Email` | varchar(128) | Y |  |
| 11 | `Remarks` | varchar(150) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_PartnerImage

Baris: 0 · PK: IDX_M_PartnerImage

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerImage` | bigint | N | IDENTITY |
| 2 | `IDX_M_Partner` | bigint | N |  |
| 3 | `PhysicalPath1` | varchar(8000) | Y |  |
| 4 | `VirtualPath1` | varchar(8000) | Y |  |
| 5 | `PhysicalPath2` | varchar(8000) | Y |  |
| 6 | `VirtualPath2` | varchar(8000) | Y |  |
| 7 | `FileName` | varchar(256) | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UCreate` | varchar(36) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `UModified` | varchar(36) | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_PartnerTitle

Baris: 0 · PK: IDX_M_PartnerTitle

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerTitle` | bigint | N | IDENTITY |
| 2 | `IDX_M_BusinessType` | bigint | N |  |
| 3 | `Name` | varchar(256) | Y |  |
| 4 | `Alias` | varchar(64) | Y |  |
| 5 | `Notes` | varchar(8000) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_PartnerType

Baris: 0 · PK: IDX_M_PartnerType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PartnerType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_PaymentTerms

Baris: 0 · PK: IDX_M_PaymentTerms

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PaymentTerms` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_PaymentType

Baris: 0 · PK: IDX_M_PaymentType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PaymentType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_FinancialPayment_Period`, `USP_CM_R_FinancialReceive_Period`

### GN_M_PostalCode

Baris: 82712 · PK: IDX_M_PostalCode

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PostalCode` | bigint | N |  |
| 2 | `IDX_M_Country` | bigint | Y |  |
| 3 | `Province` | varchar(150) | Y |  |
| 4 | `Info` | varchar(150) | Y |  |
| 5 | `City` | varchar(150) | Y |  |
| 6 | `Subdistrict` | varchar(150) | Y |  |
| 7 | `District` | varchar(150) | Y |  |
| 8 | `Zip` | varchar(150) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `Recordstatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_PartnerAddress_Info`, `USP_CM_SalesInvoice_FakturHeader_Export`, `USP_GN_PartnerAddress_Info`, `USP_GN_PartnerAddress_List`, `USP_GN_PartnerQuickAddress_Create`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_SalesOrder_NotaKasir`

### GN_M_Project

Baris: 1 · PK: IDX_M_Project

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Project` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | bigint | Y |  |
| 3 | `IDX_M_Branch` | bigint | Y |  |
| 4 | `ProjectID` | varchar(50) | Y |  |
| 5 | `ProjectName` | varchar(150) | Y |  |
| 6 | `ProjectAddress` | varchar(500) | Y |  |
| 7 | `StartDate` | datetime | Y |  |
| 8 | `EndDate` | datetime | Y |  |
| 9 | `ProjectDesc` | varchar(500) | Y |  |
| 10 | `FlagSystem` | varchar(5) | Y |  |
| 11 | `IsProfitSharing` | bit | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialPaymentDetail_Create`, `USP_CM_FinancialPaymentDetail_List`, `USP_CM_FinancialPaymentDetail_Update`, `USP_CM_FinancialPayment_PrintJournal`, `USP_CM_FinancialReceiveDetail_Create`, `USP_CM_FinancialReceiveDetail_List`, `USP_CM_FinancialReceiveDetail_Update`, `USP_CM_FinancialReceive_PrintJournal`, `USP_CM_PurchaseInvoiceDetail_Create`, `USP_CM_PurchaseInvoiceDetail_Info`, `USP_CM_PurchaseInvoiceDetail_List`, `USP_CM_PurchaseInvoiceDetail_Update`, `USP_CM_PurchaseInvoice_Payment`, `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period`, `USP_CM_SalesInvoiceDetail_Create`, `USP_CM_SalesInvoiceDetail_Info`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceDetail_Update`, `USP_CM_SalesInvoice_Payment`, `USP_GL_JournalDetail_Create`, `USP_GL_JournalDetail_Update`, `USP_GL_R_GeneralLedger`, `USP_GL_R_ProfitLoss`, `USP_GN_Project_Create`, `USP_GN_Project_Info`, `USP_GN_Project_Update`, `USP_SM_UserProject_List`

### GN_M_PurchaseType

Baris: 0 · PK: IDX_M_PurchaseType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PurchaseType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_Religion

Baris: 0 · PK: IDX_M_Religion

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Religion` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_SalesPerson

Baris: 0 · PK: IDX_M_SalesPerson

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_SalesPerson` | bigint | N | IDENTITY |
| 2 | `IDX_M_SalesTeam` | bigint | N |  |
| 3 | `IDX_M_User` | bigint | Y |  |
| 4 | `SalesPersonID` | varchar(50) | Y |  |
| 5 | `SalesPersonName` | varchar(250) | Y |  |
| 6 | `Notes` | varchar(500) | Y |  |
| 7 | `IsActive` | bit | Y |  |
| 8 | `UCreate` | varchar(10) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UModified` | varchar(10) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_R_SalesInvoice_Period`, `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_SalesInvoice_Info`

### GN_M_SalesTeam

Baris: 0 · PK: IDX_M_SalesTeam

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_SalesTeam` | bigint | N | IDENTITY |
| 2 | `SalesTeamID` | varchar(50) | Y |  |
| 3 | `SalesTeamName` | varchar(250) | Y |  |
| 4 | `Notes` | varchar(500) | Y |  |
| 5 | `UCreate` | varchar(10) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UModified` | varchar(10) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_ShippingTerms

Baris: 0 · PK: IDX_M_ShippingTerms

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_ShippingTerms` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_TransactionType

Baris: 0 · PK: IDX_M_TransactionType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_TransactionType` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `FormID` | varchar(32) | Y |  |
| 6 | `ReferenceTable` | varchar(1024) | Y |  |
| 7 | `DefaultLocation` | bigint | Y |  |
| 8 | `JournalTypeID` | varchar(32) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_Voucher

Baris: 0 · PK: IDX_M_Voucher

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Voucher` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(32) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `Source` | varchar(1) | N |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

### GN_M_VoucherLine

Baris: 0 · PK: IDX_M_VoucherLine

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_VoucherLine` | bigint | N | IDENTITY |
| 2 | `IDX_M_Voucher` | bigint | N |  |
| 3 | `Prefix` | varchar(3) | Y |  |
| 4 | `StartNumber` | int | Y |  |
| 5 | `Digit` | int | Y |  |
| 6 | `SeqNo` | int | Y |  |
| 7 | `VoucherNo` | varchar(64) | N |  |
| 8 | `Amount` | decimal(18,2) | N |  |
| 9 | `IsUsed` | int | N |  |
| 10 | `TransactionReff` | int | Y |  |
| 11 | `StartDate` | date | N |  |
| 12 | `ExpiredDate` | date | N |  |
| 13 | `IsReuseable` | int | Y |  |
| 14 | `IsDisable` | int | Y |  |
| 15 | `DCreate` | datetime | Y |  |
| 16 | `UCreate` | varchar(36) | Y |  |
| 17 | `DModified` | datetime | Y |  |
| 18 | `UModified` | varchar(36) | Y |  |
| 19 | `RecordStatus` | varchar(1) | Y |  |

### GN_T_Attachment

Baris: 0 · PK: IDX_T_Attachment

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_Attachment` | bigint | N | IDENTITY |
| 2 | `SourceType` | varchar(10) | N |  |
| 3 | `SourceID` | bigint | N |  |
| 4 | `Category` | varchar(50) | Y |  |
| 5 | `FileName` | varchar(255) | N |  |
| 6 | `StoredName` | varchar(100) | N |  |
| 7 | `FileSize` | bigint | N |  |
| 8 | `Description` | varchar(500) | Y |  |
| 9 | `UCreate` | varchar(36) | Y |  |
| 10 | `DCreate` | datetime | Y |  |
| 11 | `UModified` | varchar(36) | Y |  |
| 12 | `DModified` | datetime | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_GN_Attachment_Delete`, `USP_GN_Attachment_Info`, `USP_GN_Attachment_List`, `USP_GN_Attachment_Save`

### MC_M_Currency

Baris: 26 · PK: IDX_M_Currency

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Currency` | int | N | IDENTITY |
| 2 | `IDX_M_Country` | int | Y |  |
| 3 | `CurrencyID` | varchar(3) | Y |  |
| 4 | `CurrencyName` | varchar(32) | Y |  |
| 5 | `Symbol` | varchar(8) | Y |  |
| 6 | `Remarks` | varchar(128) | Y |  |
| 7 | `Rounding` | decimal(18,4) | Y |  |
| 8 | `Accuracy` | int | Y |  |
| 9 | `BuyRate` | decimal(18,4) | Y |  |
| 10 | `SellRate` | decimal(18,4) | Y |  |
| 11 | `IconFlag` | varchar(50) | Y |  |
| 12 | `SortPriority` | smallint | Y |  |
| 13 | `PurchaseAccount` | int | Y |  |
| 14 | `SalesAccount` | int | Y |  |
| 15 | `COGSAccount` | int | Y |  |
| 16 | `DCreate` | datetime | Y |  |
| 17 | `UCreate` | varchar(36) | Y |  |
| 18 | `DModified` | datetime | Y |  |
| 19 | `UModified` | varchar(36) | Y |  |
| 20 | `Recordstatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_A_Margin_ByCurrency`, `USP_MC_A_Position_ByCurrency`, `USP_MC_A_Volume_ByCurrency`, `USP_MC_BIMiddleRate_List`, `USP_MC_BIMonthly_List`, `USP_MC_BIMonthly_Preview`, `USP_MC_COGSCalculation`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasCalculation`, `USP_MC_COGSValasJournal_Create`, `USP_MC_CurrencyRate_History_List`, `USP_MC_CurrencyRate_Save`, `USP_MC_Currency_Info`, `USP_MC_Currency_Save`, `USP_MC_Currency_UpdateRate`, `USP_MC_InventoryCalculation`, `USP_MC_OpenCloseDailyDetail_Info`, `USP_MC_OpenCloseDailyDetail_List`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_R_COGSCalculation`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_Dashboard_Average`, `USP_MC_R_Dashboard_PurchaseValas`, `USP_MC_R_Dashboard_SalesValas`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_InventoryCalculation`, `USP_MC_R_StockCard`, `USP_MC_R_StockMutationRecap`, `USP_MC_R_Transaction`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `USP_MC_Valas_Info`, `USP_MC_Valas_Save`

### MC_M_TransactionType

Baris: 5 · PK: IDX_M_TransactionType

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_TransactionType` | int | N | IDENTITY |
| 2 | `TransactionTypeID` | varchar(50) | Y |  |
| 3 | `TransactionTypeName` | varchar(500) | Y |  |
| 4 | `UCreate` | varchar(36) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_StockCard`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`

### MC_M_Valas

Baris: 143 · PK: IDX_M_Valas

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Valas` | int | N | IDENTITY |
| 2 | `IDX_M_Currency` | int | Y |  |
| 3 | `IDX_M_ValasChange` | int | Y |  |
| 4 | `ValasSKU` | varchar(50) | Y |  |
| 5 | `ValasName` | varchar(250) | Y |  |
| 6 | `EffectiveDate` | date | Y |  |
| 7 | `BuyValue` | decimal(18,4) | Y |  |
| 8 | `SellValue` | decimal(18,4) | Y |  |
| 9 | `UCreate` | varchar(36) | Y |  |
| 10 | `DCreate` | datetime | Y |  |
| 11 | `UModified` | varchar(36) | Y |  |
| 12 | `DModified` | datetime | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_A_Margin_ByCurrency`, `USP_MC_A_Position_ByCurrency`, `USP_MC_A_Volume_ByCurrency`, `USP_MC_BIMonthly_Preview`, `USP_MC_COGSCalculation`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasCalculation`, `USP_MC_COGSValasJournal_Create`, `USP_MC_InventoryCalculation`, `USP_MC_OpenCloseDailyDetail_Info`, `USP_MC_OpenCloseDailyDetail_List`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_OpenCloseDaily_Save`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_PurchaseOrderDetail_Save`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_R_COGSCalculation`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_Dashboard_Average`, `USP_MC_R_Dashboard_PurchaseValas`, `USP_MC_R_Dashboard_SalesValas`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_InventoryCalculation`, `USP_MC_R_StockCard`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `USP_MC_SalesOrderDetail_Save`, `USP_MC_SalesOrder_Approve`, `USP_MC_ValasStock_List`, `USP_MC_Valas_Info`, `USP_MC_Valas_Save`

### MC_M_ValasChange

Baris: 19 · PK: IDX_M_ValasChange

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_ValasChange` | int | N | IDENTITY |
| 2 | `ValasChangeID` | varchar(50) | Y |  |
| 3 | `ValasChangeName` | varchar(500) | Y |  |
| 4 | `ValasChangeNumber` | int | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `Recordstatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_A_Position_ByCurrency`, `USP_MC_COGSCalculation`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasCalculation`, `USP_MC_COGSValasJournal_Create`, `USP_MC_InventoryCalculation`, `USP_MC_OpenCloseDailyDetail_Info`, `USP_MC_OpenCloseDailyDetail_List`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_PurchaseOrderDetail_Save`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_Dashboard_Average`, `USP_MC_R_Dashboard_PurchaseValas`, `USP_MC_R_Dashboard_SalesValas`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_InventoryCalculation`, `USP_MC_R_StockCard`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `USP_MC_SalesOrderDetail_Save`, `USP_MC_SalesOrder_Approve`, `USP_MC_ValasChange_Info`, `USP_MC_ValasChange_Save`, `USP_MC_Valas_Info`, `USP_MC_Valas_Save`

### MC_T_BIMiddleRate

Baris: 182 · PK: IDX_T_BIMiddleRate

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BIMiddleRate` | bigint | N | IDENTITY |
| 2 | `RateDate` | date | Y |  |
| 3 | `CurrencyID` | varchar(3) | Y |  |
| 4 | `RateUnit` | int | Y |  |
| 5 | `SellRate` | decimal(18,4) | Y |  |
| 6 | `BuyRate` | decimal(18,4) | Y |  |
| 7 | `MiddleRate` | decimal(18,4) | Y |  |
| 8 | `FileName` | varchar(256) | Y |  |
| 9 | `UCreate` | varchar(36) | Y |  |
| 10 | `DCreate` | datetime | Y |  |
| 11 | `UModified` | varchar(36) | Y |  |
| 12 | `DModified` | datetime | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_BIMiddleRate_Clear`, `USP_MC_BIMiddleRate_List`, `USP_MC_BIMiddleRate_Save`, `USP_MC_BIMonthly_Preview`

### MC_T_BIMonthly

Baris: 154 · PK: IDX_T_BIMonthly

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_BIMonthly` | bigint | N | IDENTITY |
| 2 | `ReportPeriod` | varchar(6) | Y |  |
| 3 | `CurrencyID` | varchar(3) | Y |  |
| 4 | `ProductType` | char(1) | Y |  |
| 5 | `OpeningForeign` | decimal(18,2) | Y |  |
| 6 | `OpeningIDR` | decimal(18,2) | Y |  |
| 7 | `BuyForeign` | decimal(18,2) | Y |  |
| 8 | `BuyIDR` | decimal(18,2) | Y |  |
| 9 | `SellForeign` | decimal(18,2) | Y |  |
| 10 | `SellIDR` | decimal(18,2) | Y |  |
| 11 | `ClosingForeign` | decimal(18,2) | Y |  |
| 12 | `MiddleRate` | decimal(18,4) | Y |  |
| 13 | `ClosingIDR` | decimal(18,2) | Y |  |
| 14 | `UCreate` | varchar(36) | Y |  |
| 15 | `DCreate` | datetime | Y |  |
| 16 | `UModified` | varchar(36) | Y |  |
| 17 | `DModified` | datetime | Y |  |
| 18 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_BIMonthly_Clear`, `USP_MC_BIMonthly_List`, `USP_MC_BIMonthly_Preview`, `USP_MC_BIMonthly_Save`

### MC_T_COGSCalculation

Baris: 16 · PK: IDX_T_COGSCalculation

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_COGSCalculation` | bigint | N | IDENTITY |
| 2 | `IDX_M_Currency` | int | Y |  |
| 3 | `COGSPeriod` | varchar(6) | Y |  |
| 4 | `BB_ForeignAmount` | decimal(18,4) | Y |  |
| 5 | `BB_BaseAmount` | decimal(18,4) | Y |  |
| 6 | `IN_ForeignAmount` | decimal(18,4) | Y |  |
| 7 | `IN_BaseAmount` | decimal(18,4) | Y |  |
| 8 | `EB_ForeignAmount` | decimal(18,4) | Y |  |
| 9 | `EB_BaseAmount` | decimal(18,4) | Y |  |
| 10 | `AverageAmount` | decimal(18,4) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_COGSCalculation`, `USP_MC_COGSJournal_Create`, `USP_MC_GenerateJournalCOGS`

### MC_T_COGSValasCalculation

Baris: 995 · PK: IDX_T_COGSValasCalculation

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_COGSValasCalculation` | bigint | N | IDENTITY |
| 2 | `IDX_M_Currency` | int | Y |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `COGSPeriod` | varchar(6) | Y |  |
| 5 | `ValasChangeNumber` | decimal(18,2) | Y |  |
| 6 | `BB_ForeignAmount` | decimal(18,4) | Y |  |
| 7 | `BB_Qty` | int | Y |  |
| 8 | `BB_BaseAmount` | decimal(18,4) | Y |  |
| 9 | `IN_ForeignAmount` | decimal(18,4) | Y |  |
| 10 | `IN_Qty` | int | Y |  |
| 11 | `IN_BaseAmount` | decimal(18,4) | Y |  |
| 12 | `AverageAmount` | decimal(18,4) | Y |  |
| 13 | `Sold_Qty` | int | Y |  |
| 14 | `Sold_ForeignAmount` | decimal(18,4) | Y |  |
| 15 | `Sold_BaseAmount` | decimal(18,4) | Y |  |
| 16 | `COGSAmount` | decimal(18,4) | Y |  |
| 17 | `GrossProfitAmount` | decimal(18,4) | Y |  |
| 18 | `EB_ForeignAmount` | decimal(18,4) | Y |  |
| 19 | `EB_Qty` | int | Y |  |
| 20 | `EB_BaseAmount` | decimal(18,4) | Y |  |
| 21 | `UCreate` | varchar(36) | Y |  |
| 22 | `DCreate` | datetime | Y |  |
| 23 | `UModified` | varchar(36) | Y |  |
| 24 | `DModified` | datetime | Y |  |
| 25 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_BIMonthly_Preview`, `USP_MC_COGSValasCalculation`, `USP_MC_COGSValasJournal_Create`, `USP_MC_GenerateJournalCOGSValas`, `USP_MC_R_COGSCalculation`, `USP_MC_R_Dashboard_Average`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_StockMutationRecap`, `USP_MC_R_Transaction`

### MC_T_CurrencyRateHistory

Baris: 0 · PK: IDX_T_CurrencyRateHistory

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_CurrencyRateHistory` | bigint | N | IDENTITY |
| 2 | `IDX_M_Currency` | int | N |  |
| 3 | `CurrencyID` | varchar(3) | Y |  |
| 4 | `BuyRate` | decimal(18,4) | Y |  |
| 5 | `SellRate` | decimal(18,4) | Y |  |
| 6 | `NewBuyRate` | decimal(18,4) | Y |  |
| 7 | `NewSellRate` | decimal(18,4) | Y |  |
| 8 | `ChangeDate` | datetime | Y |  |
| 9 | `ChangeSource` | varchar(32) | Y |  |
| 10 | `Remarks` | varchar(256) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_CurrencyRate_History_List`, `USP_MC_CurrencyRate_Save`

### MC_T_InventoryCalculation

Baris: 321 · PK: IDX_T_InventoryCalculation

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_InventoryCalculation` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `CalculationPeriod` | varchar(6) | Y |  |
| 5 | `OpeningQty` | decimal(18,2) | Y |  |
| 6 | `OpeningValue` | decimal(22,4) | Y |  |
| 7 | `InQty` | decimal(18,2) | Y |  |
| 8 | `InValue` | decimal(22,4) | Y |  |
| 9 | `OutQty` | decimal(18,2) | Y |  |
| 10 | `OutValue` | decimal(22,4) | Y |  |
| 11 | `ClosingQty` | decimal(18,2) | Y |  |
| 12 | `AverageValue` | decimal(22,4) | Y |  |
| 13 | `COGSValue` | decimal(22,4) | Y |  |
| 14 | `InventoryValue` | decimal(22,4) | Y |  |
| 15 | `UCreate` | varchar(36) | Y |  |
| 16 | `DCreate` | datetime | Y |  |
| 17 | `UModified` | varchar(36) | Y |  |
| 18 | `DModified` | datetime | Y |  |
| 19 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_InventoryCalculation`, `USP_MC_R_InventoryCalculation`

### MC_T_KursBI

Baris: 0 · PK: IDX_T_KursBI

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_KursBI` | bigint | N | IDENTITY |
| 2 | `TanggalKurs` | date | N |  |
| 3 | `CurrencyID` | varchar(10) | N |  |
| 4 | `Nilai` | decimal(18,4) | Y |  |
| 5 | `KursBeli` | decimal(18,4) | Y |  |
| 6 | `KursJual` | decimal(18,4) | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_KursBI_Latest`, `USP_MC_KursBI_Save`

### MC_T_LTKM

Baris: 0 · PK: IDX_T_LTKM

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_LTKM` | bigint | N | IDENTITY |
| 2 | `LTKMPeriod` | varchar(6) | Y |  |
| 3 | `IDX_T_SalesOrder` | bigint | Y |  |
| 4 | `SONumber` | varchar(50) | Y |  |
| 5 | `TransactionDate` | date | Y |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `PartnerID` | varchar(32) | Y |  |
| 8 | `PartnerName` | varchar(256) | Y |  |
| 9 | `SingleIdentityNumber` | varchar(64) | Y |  |
| 10 | `PlaceOfBirth` | varchar(64) | Y |  |
| 11 | `DateOfBirth` | date | Y |  |
| 12 | `Street` | varchar(1024) | Y |  |
| 13 | `IsDTTOT` | char(1) | Y |  |
| 14 | `TotalSalesAmount` | decimal(18,4) | Y |  |
| 15 | `PaymentCashAmount` | decimal(18,4) | Y |  |
| 16 | `TKMDate` | date | Y |  |
| 17 | `TKMIndicator` | varchar(1000) | Y |  |
| 18 | `ReportDueDate` | date | Y |  |
| 19 | `ReportStatus` | char(1) | Y |  |
| 20 | `UCreate` | varchar(36) | Y |  |
| 21 | `DCreate` | datetime | Y |  |
| 22 | `UModified` | varchar(36) | Y |  |
| 23 | `DModified` | datetime | Y |  |
| 24 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_LTKM_Clear`, `USP_MC_LTKM_List`, `USP_MC_LTKM_Preview`, `USP_MC_LTKM_Save`

### MC_T_LTKT

Baris: 0 · PK: IDX_T_LTKT

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_LTKT` | bigint | N | IDENTITY |
| 2 | `LTKTPeriod` | varchar(6) | Y |  |
| 3 | `IDX_T_SalesOrder` | bigint | Y |  |
| 4 | `SONumber` | varchar(50) | Y |  |
| 5 | `TransactionDate` | date | Y |  |
| 6 | `IDX_M_Partner` | bigint | Y |  |
| 7 | `PartnerID` | varchar(32) | Y |  |
| 8 | `PartnerName` | varchar(256) | Y |  |
| 9 | `SingleIdentityNumber` | varchar(64) | Y |  |
| 10 | `PlaceOfBirth` | varchar(64) | Y |  |
| 11 | `DateOfBirth` | date | Y |  |
| 12 | `Street` | varchar(1024) | Y |  |
| 13 | `TotalSalesAmount` | decimal(18,4) | Y |  |
| 14 | `PaymentCashAmount` | decimal(18,4) | Y |  |
| 15 | `DailyCashAmount` | decimal(18,4) | Y |  |
| 16 | `ReportDueDate` | date | Y |  |
| 17 | `ReportStatus` | char(1) | Y |  |
| 18 | `UCreate` | varchar(36) | Y |  |
| 19 | `DCreate` | datetime | Y |  |
| 20 | `UModified` | varchar(36) | Y |  |
| 21 | `DModified` | datetime | Y |  |
| 22 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_LTKT_List`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`

### MC_T_NotaScan

Baris: 0 · PK: IDX_T_MC_NotaScan

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_MC_NotaScan` | bigint | N | IDENTITY |
| 2 | `TipeTransaksi` | char(1) | N |  |
| 3 | `TanggalNota` | date | Y |  |
| 4 | `NoNota` | varchar(100) | Y |  |
| 5 | `NamaKonsumen` | varchar(200) | Y |  |
| 6 | `NoKTP` | varchar(50) | Y |  |
| 7 | `NoTelp` | varchar(50) | Y |  |
| 8 | `SumberDana` | varchar(200) | Y |  |
| 9 | `TujuanTransaksi` | varchar(200) | Y |  |
| 10 | `Keterangan` | varchar(500) | Y |  |
| 11 | `FileName` | varchar(255) | Y |  |
| 12 | `FilePath` | varchar(1000) | Y |  |
| 13 | `OCRRawText` | nvarchar(max) | Y |  |
| 14 | `Status` | char(1) | N |  |
| 15 | `RecordStatus` | char(1) | N |  |
| 16 | `UCreate` | varchar(50) | Y |  |
| 17 | `DCreate` | datetime | Y |  |
| 18 | `UModified` | varchar(50) | Y |  |
| 19 | `DModified` | datetime | Y |  |

Dipakai oleh: `USP_MC_NotaScanDetail_DeleteAll`, `USP_MC_NotaScanDetail_Save`, `USP_MC_NotaScan_Info`, `USP_MC_NotaScan_Save`

### MC_T_NotaScanDetail

Baris: 0 · PK: IDX_T_MC_NotaScanDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_MC_NotaScanDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_MC_NotaScan` | bigint | N |  |
| 3 | `Nomor` | int | Y |  |
| 4 | `KeteranganValas` | varchar(200) | Y |  |
| 5 | `NilaiValas` | decimal(18,2) | Y |  |
| 6 | `NilaiTukar` | decimal(18,4) | Y |  |
| 7 | `TotalNilai` | decimal(18,2) | Y |  |
| 8 | `CatatanDetail` | varchar(500) | Y |  |
| 9 | `RecordStatus` | char(1) | N |  |
| 10 | `UCreate` | varchar(50) | Y |  |
| 11 | `DCreate` | datetime | Y |  |

Dipakai oleh: `USP_MC_NotaScanDetail_DeleteAll`, `USP_MC_NotaScanDetail_List`, `USP_MC_NotaScanDetail_Save`, `USP_MC_NotaScan_Info`

### MC_T_OpenCloseDaily

Baris: 1 · PK: IDX_T_OpenCloseDaily

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_OpenCloseDaily` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | N |  |
| 3 | `IDX_M_Branch` | int | N |  |
| 4 | `TransactionDate` | date | Y |  |
| 5 | `TransactionStatus` | char(1) | Y |  |
| 6 | `TellerID` | varchar(50) | Y |  |
| 7 | `HeaderNotes` | varchar(500) | Y |  |
| 8 | `UCreate` | varchar(36) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UModified` | varchar(36) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_OpenCloseDailyDetail_Info`, `USP_MC_OpenCloseDailyDetail_List`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_OpenCloseDaily_Info`, `USP_MC_OpenCloseDaily_Save`, `USP_MC_R_DailyCalculation`

### MC_T_OpenCloseDailyDetail

Baris: 130 · PK: IDX_T_OpenCloseDailyDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_OpenCloseDailyDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_OpenCloseDaily` | bigint | N |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `OpenQty` | decimal(18,2) | Y |  |
| 5 | `InQty` | decimal(18,2) | Y |  |
| 6 | `OutQty` | decimal(18,2) | Y |  |
| 7 | `CloseQty` | decimal(18,2) | Y |  |
| 8 | `DiffQty` | decimal(18,2) | Y |  |
| 9 | `DetailNotes` | varchar(5000) | Y |  |
| 10 | `UCreate` | varchar(36) | Y |  |
| 11 | `DCreate` | datetime | Y |  |
| 12 | `UModified` | varchar(36) | Y |  |
| 13 | `DModified` | datetime | Y |  |
| 14 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_OpenCloseDailyDetail_Info`, `USP_MC_OpenCloseDailyDetail_List`, `USP_MC_OpenCloseDailyDetail_Save`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_OpenCloseDaily_Save`, `USP_MC_R_DailyCalculation`

### MC_T_POSValas

Baris: 0 · PK: IDX_T_POSValas

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_POSValas` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Branch` | int | Y |  |
| 4 | `IDX_M_Partner` | bigint | Y |  |
| 5 | `TransactionDate` | date | Y |  |
| 6 | `TransactionNotes` | varchar(5000) | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DCreate` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `DModified` | datetime | Y |  |
| 11 | `RecordStatus` | varchar(1) | Y |  |

### MC_T_POSValasDetail

Baris: 0 · PK: IDX_T_POSValasDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_POSValasDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_POSValas` | bigint | N |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `IDX_M_TransactionType` | int | Y |  |
| 5 | `CustomerCurrency` | int | Y |  |
| 6 | `CustomerAmount` | decimal(18,4) | Y |  |
| 7 | `ExchangeRate` | decimal(18,4) | Y |  |
| 8 | `BaseCurrency` | int | Y |  |
| 9 | `BaseCurrencyAmount` | decimal(18,4) | Y |  |
| 10 | `DetailNotes` | varchar(5000) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

### MC_T_PurchaseOrder

Baris: 2349 · PK: IDX_T_PurchaseOrder

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseOrder` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Branch` | int | Y |  |
| 4 | `IDX_M_DocumentType` | int | Y |  |
| 5 | `IDX_M_Partner` | bigint | Y |  |
| 6 | `PONumber` | varchar(50) | Y |  |
| 7 | `PODate` | date | Y |  |
| 8 | `PONotes` | varchar(5000) | Y |  |
| 9 | `POStatus` | char(1) | Y |  |
| 10 | `ReferenceNo` | varchar(50) | Y |  |
| 11 | `POApprovalDate` | date | Y |  |
| 12 | `POApprovalNotes` | varchar(5000) | Y |  |
| 13 | `POApprovalBy` | varchar(50) | Y |  |
| 14 | `UCreate` | varchar(36) | Y |  |
| 15 | `DCreate` | datetime | Y |  |
| 16 | `UModified` | varchar(36) | Y |  |
| 17 | `DModified` | datetime | Y |  |
| 18 | `RecordStatus` | varchar(1) | Y |  |
| 19 | `FundSource` | varchar(250) | Y |  |
| 20 | `TransactionPurpose` | varchar(250) | Y |  |

Dipakai oleh: `USP_CM_FinancialDetail_DocumentSearch`, `USP_CM_FinancialPaymentDetail_LinkDocument`, `USP_GL_R_GeneralLedger`, `USP_MC_A_Margin_ByCurrency`, `USP_MC_A_Position_ByCurrency`, `USP_MC_A_Volume_ByCurrency`, `USP_MC_A_Volume_Trend`, `USP_MC_BIMonthly_Preview`, `USP_MC_COGSCalculation`, `USP_MC_COGSValasCalculation`, `USP_MC_InventoryCalculation`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrderDetail_Delete`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_PurchaseOrderPayment_List`, `USP_MC_PurchaseOrderUpload_List`, `USP_MC_PurchaseOrderUpload_Save`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_PurchaseOrder_Payment`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_PurchaseOrder_Save`, `USP_MC_R_AP`, `USP_MC_R_DashboardSales`, `USP_MC_R_Dashboard_Average`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_StockCard`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`

### MC_T_PurchaseOrderDetail

Baris: 4739 · PK: IDX_T_PurchaseOrderDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseOrderDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseOrder` | bigint | N |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `IDX_M_Tax` | int | Y |  |
| 5 | `ForeignCurrency` | int | Y |  |
| 6 | `Quantity` | int | Y |  |
| 7 | `ForeignAmount` | decimal(22,4) | Y |  |
| 8 | `ExchangeRate` | decimal(22,4) | Y |  |
| 9 | `BaseCurrency` | int | Y |  |
| 10 | `BaseCurrencyAmount` | decimal(22,4) | Y |  |
| 11 | `DetailNotes` | varchar(5000) | Y |  |
| 12 | `UCreate` | varchar(36) | Y |  |
| 13 | `DCreate` | datetime | Y |  |
| 14 | `UModified` | varchar(36) | Y |  |
| 15 | `DModified` | datetime | Y |  |
| 16 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialDetail_DocumentSearch`, `USP_MC_A_Margin_ByCurrency`, `USP_MC_A_Position_ByCurrency`, `USP_MC_A_Volume_ByCurrency`, `USP_MC_A_Volume_Trend`, `USP_MC_BIMonthly_Preview`, `USP_MC_COGSCalculation`, `USP_MC_COGSValasCalculation`, `USP_MC_InventoryCalculation`, `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrderDetail_Delete`, `USP_MC_PurchaseOrderDetail_Info`, `USP_MC_PurchaseOrderDetail_List`, `USP_MC_PurchaseOrderDetail_Save`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_PurchaseOrder_Info`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_R_AP`, `USP_MC_R_DashboardSales`, `USP_MC_R_Dashboard_Average`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`

### MC_T_PurchaseOrderTax

Baris: 0 · PK: IDX_T_PurchaseOrderTax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseOrderTax` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseOrder` | bigint | N |  |
| 3 | `IDX_T_PurchaseOrderDetail` | bigint | Y |  |
| 4 | `IDX_M_Tax` | bigint | Y |  |
| 5 | `TaxID` | varchar(50) | Y |  |
| 6 | `TaxDesc` | varchar(50) | Y |  |
| 7 | `TaxRate` | decimal(5,2) | Y |  |
| 8 | `TaxAmount` | decimal(20,3) | Y |  |
| 9 | `TaxCOA` | bigint | Y |  |
| 10 | `AllowEdit` | char(1) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

### MC_T_PurchaseOrderUpload

Baris: 4527 · PK: IDX_T_PurchaseOrderUpload

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseOrderUpload` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseOrder` | bigint | N |  |
| 3 | `UploadCategory` | varchar(50) | Y |  |
| 4 | `FilePath` | varchar(5000) | Y |  |
| 5 | `FileName` | varchar(250) | Y |  |
| 6 | `FileDescription` | varchar(500) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UCreate` | varchar(50) | Y |  |
| 9 | `DModifed` | datetime | Y |  |
| 10 | `UModified` | varchar(50) | Y |  |
| 11 | `RecordStatus` | char(1) | Y |  |

Dipakai oleh: `USP_MC_PurchaseOrderUpload_List`, `USP_MC_PurchaseOrderUpload_Save`

### MC_T_SalesOrder

Baris: 1855 · PK: IDX_T_SalesOrder

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesOrder` | bigint | N | IDENTITY |
| 2 | `IDX_M_Company` | int | Y |  |
| 3 | `IDX_M_Branch` | int | Y |  |
| 4 | `IDX_M_DocumentType` | int | Y |  |
| 5 | `IDX_M_Partner` | bigint | Y |  |
| 6 | `SONumber` | varchar(50) | Y |  |
| 7 | `SODate` | date | Y |  |
| 8 | `SONotes` | varchar(5000) | Y |  |
| 9 | `SOStatus` | char(1) | Y |  |
| 10 | `ReferenceNo` | varchar(50) | Y |  |
| 11 | `FundSource` | varchar(250) | Y |  |
| 12 | `TransactionPurpose` | varchar(250) | Y |  |
| 13 | `SOApprovalDate` | date | Y |  |
| 14 | `SOApprovalNotes` | varchar(5000) | Y |  |
| 15 | `SOApprovalBy` | varchar(50) | Y |  |
| 16 | `UCreate` | varchar(36) | Y |  |
| 17 | `DCreate` | datetime | Y |  |
| 18 | `UModified` | varchar(36) | Y |  |
| 19 | `DModified` | datetime | Y |  |
| 20 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialDetail_DocumentSearch`, `USP_CM_FinancialReceiveDetail_LinkDocument`, `USP_GL_R_GeneralLedger`, `USP_MC_A_Margin_ByCurrency`, `USP_MC_A_Volume_ByCurrency`, `USP_MC_A_Volume_Trend`, `USP_MC_BIMonthly_Preview`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasCalculation`, `USP_MC_COGSValasJournal_Create`, `USP_MC_GenerateJournalCOGS`, `USP_MC_GenerateJournalCOGSValas`, `USP_MC_InventoryCalculation`, `USP_MC_LTKM_Preview`, `USP_MC_LTKM_Save`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_R_AR`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_StockCard`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderDetail_Delete`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `USP_MC_SalesOrderDetail_Save`, `USP_MC_SalesOrderJournal_List`, `USP_MC_SalesOrderPayment_List`, `USP_MC_SalesOrderUpload_List`, `USP_MC_SalesOrderUpload_Save`, `USP_MC_SalesOrder_Approve`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_NotaKasir`, `USP_MC_SalesOrder_Payment`, `USP_MC_SalesOrder_Reverse`, `USP_MC_SalesOrder_Save`

### MC_T_SalesOrderDetail

Baris: 4215 · PK: IDX_T_SalesOrderDetail

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesOrderDetail` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesOrder` | bigint | N |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `IDX_M_Tax` | int | Y |  |
| 5 | `IDX_M_TransactionType` | int | Y |  |
| 6 | `ForeignCurrency` | int | Y |  |
| 7 | `Quantity` | int | Y |  |
| 8 | `ForeignAmount` | decimal(22,4) | Y |  |
| 9 | `ExchangeRate` | decimal(22,4) | Y |  |
| 10 | `BaseCurrency` | int | Y |  |
| 11 | `BaseCurrencyAmount` | decimal(22,4) | Y |  |
| 12 | `DetailNotes` | varchar(5000) | Y |  |
| 13 | `UCreate` | varchar(36) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(36) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_FinancialDetail_DocumentSearch`, `USP_MC_A_Margin_ByCurrency`, `USP_MC_A_Volume_ByCurrency`, `USP_MC_A_Volume_Trend`, `USP_MC_BIMonthly_Preview`, `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasCalculation`, `USP_MC_COGSValasJournal_Create`, `USP_MC_InventoryCalculation`, `USP_MC_LTKM_Preview`, `USP_MC_LTKM_Save`, `USP_MC_LTKT_Preview`, `USP_MC_LTKT_Process`, `USP_MC_OpenCloseDaily_Approve`, `USP_MC_OpenCloseDaily_Closing`, `USP_MC_R_AR`, `USP_MC_R_DailyCalculation`, `USP_MC_R_DashboardSales`, `USP_MC_R_Transaction`, `USP_MC_R_TransactionCustomer`, `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrderDetail_Delete`, `USP_MC_SalesOrderDetail_Info`, `USP_MC_SalesOrderDetail_List`, `USP_MC_SalesOrderDetail_Save`, `USP_MC_SalesOrder_Approve`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_Reverse`

### MC_T_SalesOrderUpload

Baris: 4448 · PK: IDX_T_SalesOrderUpload

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SalesOrderUpload` | bigint | N | IDENTITY |
| 2 | `IDX_T_SalesOrder` | bigint | N |  |
| 3 | `UploadCategory` | varchar(50) | Y |  |
| 4 | `FilePath` | varchar(5000) | Y |  |
| 5 | `FileName` | varchar(250) | Y |  |
| 6 | `FileDescription` | varchar(500) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UCreate` | varchar(50) | Y |  |
| 9 | `DModifed` | datetime | Y |  |
| 10 | `UModified` | varchar(50) | Y |  |
| 11 | `RecordStatus` | char(1) | Y |  |

Dipakai oleh: `USP_MC_SalesOrderUpload_List`, `USP_MC_SalesOrderUpload_Save`

### MC_T_StockCardValas

Baris: 8944 · PK: IDX_T_StockCardValas

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_StockCardValas` | bigint | N | IDENTITY |
| 2 | `IDX_M_Branch` | int | Y |  |
| 3 | `IDX_M_Valas` | int | Y |  |
| 4 | `IDX_M_TransactionType` | int | Y |  |
| 5 | `IDX_Transaction` | bigint | Y |  |
| 6 | `TransactionNo` | varchar(50) | Y |  |
| 7 | `TransactionDate` | date | Y |  |
| 8 | `StockInQty` | decimal(18,4) | Y |  |
| 9 | `ExchangeRateIn` | decimal(18,4) | Y |  |
| 10 | `StockInForeignAmount` | decimal(18,4) | Y |  |
| 11 | `StockInBaseAmount` | decimal(18,4) | Y |  |
| 12 | `StockOutQty` | decimal(18,4) | Y |  |
| 13 | `ExchangeRateOut` | decimal(18,4) | Y |  |
| 14 | `StockOutForeignAmount` | decimal(18,4) | Y |  |
| 15 | `StockOutBaseAmount` | decimal(18,4) | Y |  |
| 16 | `UCreate` | varchar(36) | Y |  |
| 17 | `DCreate` | datetime | Y |  |
| 18 | `UModified` | varchar(36) | Y |  |
| 19 | `DModified` | datetime | Y |  |
| 20 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_MC_A_Position_ByCurrency`, `USP_MC_PurchaseOrder_Approve`, `USP_MC_PurchaseOrder_Reverse`, `USP_MC_R_Dashboard_PurchaseValas`, `USP_MC_R_Dashboard_SalesValas`, `USP_MC_R_Dashboard_Stock`, `USP_MC_R_StockCard`, `USP_MC_SalesOrderDetail_Save`, `USP_MC_SalesOrder_Approve`, `USP_MC_SalesOrder_Reverse`, `USP_MC_ValasStock_List`

### PR_T_PurchaseOrderTax

Baris: 0 · PK: IDX_T_PurchaseOrderTax

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_PurchaseOrderTax` | bigint | N | IDENTITY |
| 2 | `IDX_T_PurchaseOrder` | bigint | N |  |
| 3 | `IDX_T_PurchaseOrderDetail` | bigint | Y |  |
| 4 | `IDX_M_Tax` | bigint | Y |  |
| 5 | `TaxID` | varchar(50) | Y |  |
| 6 | `TaxDesc` | varchar(50) | Y |  |
| 7 | `TaxRate` | decimal(5,2) | Y |  |
| 8 | `TaxAmount` | decimal(20,3) | Y |  |
| 9 | `TaxCOA` | bigint | Y |  |
| 10 | `AllowEdit` | char(1) | Y |  |
| 11 | `UCreate` | varchar(36) | Y |  |
| 12 | `DCreate` | datetime | Y |  |
| 13 | `UModified` | varchar(36) | Y |  |
| 14 | `DModified` | datetime | Y |  |
| 15 | `RecordStatus` | varchar(1) | Y |  |

### SM_M_Application

Baris: 2 · PK: IDX_M_Application

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Application` | int | N | IDENTITY |
| 2 | `ApplicationID` | varchar(50) | Y |  |
| 3 | `ApplicationName` | varchar(150) | Y |  |
| 4 | `ApplicationLabel` | varchar(150) | Y |  |
| 5 | `ApplicationURL` | varchar(250) | Y |  |
| 6 | `IconClass1` | varchar(150) | Y |  |
| 7 | `IconClass2` | varchar(150) | Y |  |
| 8 | `IconClass3` | varchar(150) | Y |  |
| 9 | `UCreate` | varchar(10) | Y |  |
| 10 | `DCreate` | datetime | Y |  |
| 11 | `UModified` | varchar(10) | Y |  |
| 12 | `DModified` | datetime | Y |  |
| 13 | `RecordStatus` | char(1) | N |  |

Dipakai oleh: `USP_SM_ApplicationByUser_List`, `USP_SM_FormByUser_List`, `USP_SM_Form_CheckList_ByGroupID`, `USP_SM_Form_CheckList_ByUserID`

### SM_M_Form

Baris: 141 · PK: IDX_M_Form

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Form` | bigint | N | IDENTITY |
| 2 | `IDX_M_Application` | int | Y |  |
| 3 | `IDX_M_Module` | int | Y |  |
| 4 | `ApplicationID` | varchar(50) | Y |  |
| 5 | `FormID` | varchar(50) | N |  |
| 6 | `FormName` | varchar(150) | Y |  |
| 7 | `FormURL` | varchar(150) | Y |  |
| 8 | `FormDescription` | varchar(500) | Y |  |
| 9 | `IconClass1` | varchar(50) | Y |  |
| 10 | `IconClass2` | varchar(50) | Y |  |
| 11 | `IconClass3` | varchar(50) | Y |  |
| 12 | `ShowInSidebar` | char(1) | Y |  |
| 13 | `UCreate` | varchar(10) | Y |  |
| 14 | `DCreate` | datetime | Y |  |
| 15 | `UModified` | varchar(10) | Y |  |
| 16 | `DModified` | datetime | Y |  |
| 17 | `RecordStatus` | char(1) | N |  |

Dipakai oleh: `USP_SM_CheckUserForm`, `USP_SM_FormByGroup_List`, `USP_SM_FormByUser_List`, `USP_SM_Form_CheckList_ByGroupID`, `USP_SM_Form_CheckList_ByUserID`, `USP_SM_Form_Create`, `USP_SM_Form_Info`, `USP_SM_Form_Save`, `USP_SM_Form_Update`, `USP_SM_GroupForm_List`, `USP_SM_Group_Create`, `USP_SM_Group_Update`

### SM_M_Group

Baris: 6 · PK: IDX_M_Group

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Group` | bigint | N | IDENTITY |
| 2 | `GroupID` | varchar(50) | Y |  |
| 3 | `GroupName` | varchar(150) | Y |  |
| 4 | `Notes` | varchar(500) | Y |  |
| 5 | `UCreate` | varchar(10) | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UModified` | varchar(10) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_SM_CheckUserForm`, `USP_SM_FormByGroup_List`, `USP_SM_Form_CheckList_ByGroupID`, `USP_SM_Form_CheckList_ByUserID`, `USP_SM_GroupByUser_List`, `USP_SM_GroupForm_List`, `USP_SM_Group_Create`, `USP_SM_Group_Info`, `USP_SM_Group_Update`, `USP_SM_UserGroup_List`

### SM_M_GroupForm

Baris: 235 · PK: IDX_M_GroupForm

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_GroupForm` | bigint | N | IDENTITY |
| 2 | `IDX_M_Group` | bigint | Y |  |
| 3 | `IDX_M_Form` | bigint | Y |  |
| 4 | `UCreate` | varchar(10) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_SM_CheckUserForm`, `USP_SM_FormByGroup_List`, `USP_SM_Form_CheckList_ByGroupID`, `USP_SM_Form_CheckList_ByUserID`, `USP_SM_GroupForm_List`, `USP_SM_Group_Create`, `USP_SM_Group_DeleteForm`, `USP_SM_Group_Update`

### SM_M_Module

Baris: 1 · PK: IDX_M_Module

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Module` | int | N | IDENTITY |
| 2 | `IDX_M_Application` | int | Y |  |
| 3 | `ModuleID` | varchar(50) | Y |  |
| 4 | `ModuleName` | varchar(250) | Y |  |
| 5 | `IconClass1` | varchar(150) | Y |  |
| 6 | `UCreate` | varchar(10) | Y |  |
| 7 | `DCreate` | datetime | Y |  |
| 8 | `UModified` | varchar(10) | Y |  |
| 9 | `DModified` | datetime | Y |  |
| 10 | `RecordStatus` | char(1) | N |  |

Dipakai oleh: `USP_SM_FormByUser_List`

### SM_M_Position

Baris: 0 · PK: IDX_M_Position

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_Position` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | N |  |
| 3 | `Alias` | varchar(64) | Y |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `Level` | int | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

### SM_M_RoleAction

Baris: 0 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_RoleAction` | bigint | N | IDENTITY |
| 2 | `Name` | varchar(256) | Y |  |
| 3 | `Alias` | varchar(64) | N |  |
| 4 | `Notes` | varchar(8000) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UCreate` | varchar(36) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `UModified` | varchar(36) | Y |  |
| 9 | `RecordStatus` | varchar(1) | Y |  |

### SM_M_RolePosition

Baris: 0 · PK: IDX_M_RolePosition

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_RolePosition` | bigint | N | IDENTITY |
| 2 | `IDX_M_Position` | bigint | N |  |
| 3 | `IDX_M_Menu` | bigint | N |  |
| 4 | `RoleAction` | varchar(1) | N |  |
| 5 | `RoleValue` | int | N |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `RecordStatus` | varchar(1) | Y |  |

### SM_M_User

Baris: 17 · PK: IDX_M_User

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_User` | bigint | N | IDENTITY |
| 2 | `IDX_M_Gender` | bigint | Y |  |
| 3 | `LoginID` | varchar(32) | Y |  |
| 4 | `Name` | varchar(256) | Y |  |
| 5 | `Alias` | varchar(64) | Y |  |
| 6 | `Password` | varchar(32) | Y |  |
| 7 | `Password2` | varchar(32) | Y |  |
| 8 | `Pin` | varchar(32) | Y |  |
| 9 | `Email` | varchar(256) | Y |  |
| 10 | `Notes` | varchar(8000) | Y |  |
| 11 | `LastLogin` | datetime | Y |  |
| 12 | `LastLogout` | datetime | Y |  |
| 13 | `LastIPAddress` | varchar(16) | Y |  |
| 14 | `IsLocked` | int | Y |  |
| 15 | `LockDate` | datetime | Y |  |
| 16 | `FailedLoginAttemps` | int | Y |  |
| 17 | `VerificationCode` | varchar(16) | Y |  |
| 18 | `DCreate` | datetime | Y |  |
| 19 | `UCreate` | varchar(36) | Y |  |
| 20 | `DModified` | datetime | Y |  |
| 21 | `UModified` | varchar(36) | Y |  |
| 22 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_List`, `USP_CM_Branch_Info`, `USP_CM_CashflowID_Info`, `USP_CM_Company_Info`, `USP_CM_FakturNumber_Info2`, `USP_CM_FinancialAccount_Info`, `USP_CM_FinancialPayment_Info`, `USP_CM_FinancialReceive_Info`, `USP_CM_Partner_Info`, `USP_CM_PettyCash_Info`, `USP_CM_PettyCash_List`, `USP_CM_PurchaseInvoice_Info`, `USP_CM_SalesInvoice_Info`, `USP_GL_COAGroup1_Info`, `USP_GL_COAGroup2_Info`, `USP_GL_COAGroup3_Info`, `USP_GL_COA_Info`, `USP_GL_JournalHeader_Info`, `USP_GN_Attachment_List`, `USP_GN_DocumentType_Info`, `USP_GN_Partner_Info`, `USP_GN_Project_Info`, `USP_MC_OpenCloseDailyDetail_Info`, `USP_MC_OpenCloseDaily_Info`, `USP_MC_PurchaseOrder_NotaKasir`, `USP_MC_SalesOrder_Info`, `USP_MC_SalesOrder_NotaKasir`, `USP_SM_CheckLoginValidation`, `USP_SM_CheckUserForm`, `USP_SM_Form_Info`, `USP_SM_Group_Info`, `USP_SM_UserBranch_List`, `USP_SM_UserDepartment_List`, `USP_SM_UserGroup_List`, `USP_SM_UserProject_List`, `USP_SM_User_Create`, `USP_SM_User_Info`, `USP_SM_User_ResetPassword`, `USP_SM_User_SaveResetPassword`, `USP_SM_User_SendResetPassword`, `USP_SM_User_Update`

### SM_M_UserBranch

Baris: 19 · PK: IDX_M_UserBranch

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_UserBranch` | bigint | N | IDENTITY |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `IDX_M_Branch` | bigint | N |  |
| 4 | `UCreate` | varchar(10) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_CM_BankStatement_List`, `USP_CM_PettyCash_List`, `USP_SM_UserBranch_List`, `USP_SM_User_ActivateBranch`, `USP_SM_User_DeleteBranch`

### SM_M_UserCompany

Baris: 0 · PK: IDX_M_UserCompany

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_UserCompany` | bigint | N | IDENTITY |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `IDX_M_Company` | bigint | N |  |
| 4 | `UCreate` | varchar(10) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

### SM_M_UserDepartment

Baris: 0 · PK: IDX_M_UserDepartment

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_UserDepartment` | bigint | N | IDENTITY |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `IDX_M_Department` | bigint | N |  |
| 4 | `UCreate` | varchar(10) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_SM_UserDepartment_List`

### SM_M_UserGroup

Baris: 19 · PK: IDX_M_UserGroup

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_UserGroup` | bigint | N | IDENTITY |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `IDX_M_Group` | bigint | N |  |
| 4 | `UCreate` | varchar(10) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_SM_CheckUserForm`, `USP_SM_GroupByUser_List`, `USP_SM_UserGroup_List`, `USP_SM_User_ActivateGroup`, `USP_SM_User_DeleteGroup`

### SM_M_UserProject

Baris: 0 · PK: IDX_M_UserProject

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_UserProject` | bigint | N | IDENTITY |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `IDX_M_Project` | bigint | N |  |
| 4 | `UCreate` | varchar(10) | Y |  |
| 5 | `DCreate` | datetime | Y |  |
| 6 | `UModified` | varchar(10) | Y |  |
| 7 | `DModified` | datetime | Y |  |
| 8 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_SM_UserProject_List`, `USP_SM_User_ActivateProject`, `USP_SM_User_DeleteProject`

### SM_T_CustomerResetPassword

Baris: 0 · PK: IDX_T_CustomerResetPassword

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_CustomerResetPassword` | bigint | N | IDENTITY |
| 2 | `EmailAddress` | varchar(50) | Y |  |
| 3 | `ResetPasswordKey` | varchar(150) | Y |  |
| 4 | `ExpiredDate` | datetime | Y |  |
| 5 | `IsExpired` | bit | Y |  |
| 6 | `IsReset` | bit | Y |  |
| 7 | `ResetDate` | datetime | Y |  |
| 8 | `UCreate` | varchar(50) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UModified` | varchar(50) | Y |  |
| 11 | `DModified` | datetime | Y |  |
| 12 | `RecordStatus` | varchar(1) | Y |  |

Dipakai oleh: `USP_SM_User_CheckResetPassword`, `USP_SM_User_SaveResetPassword`, `USP_SM_User_SendResetPassword`

### SM_T_RolePosition

Baris: 0 · PK: IDX_T_RolePosition

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_RolePosition` | bigint | N | IDENTITY |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `IDX_M_Position` | bigint | N |  |
| 4 | `StartDate` | date | Y |  |
| 5 | `EndDate` | date | Y |  |
| 6 | `DCreate` | datetime | Y |  |
| 7 | `UCreate` | varchar(36) | Y |  |
| 8 | `DModified` | datetime | Y |  |
| 9 | `UModified` | varchar(36) | Y |  |
| 10 | `Recordstatus` | varchar(1) | Y |  |

### SM_T_Session

Baris: 0 · PK: SessionID

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `SessionID` | uniqueidentifier | N |  |
| 2 | `IDX_M_User` | bigint | N |  |
| 3 | `LoginID` | varchar(32) | N |  |
| 4 | `LoginName` | varchar(64) | N |  |
| 5 | `LoginDate` | datetime | N |  |
| 6 | `ExpiredDate` | datetime | N |  |
| 7 | `IPAddress` | varchar(16) | N |  |

### SM_T_SessionHistory

Baris: 0 · PK: IDX_T_SessionHistory

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_T_SessionHistory` | bigint | N | IDENTITY |
| 2 | `SessionID` | varchar(36) | Y |  |
| 3 | `IDX_M_User` | bigint | Y |  |
| 4 | `LoginID` | varchar(32) | Y |  |
| 5 | `LoginName` | varchar(64) | Y |  |
| 6 | `LoginDate` | datetime | Y |  |
| 7 | `ExpiredDate` | datetime | Y |  |
| 8 | `IPAddress` | varchar(16) | Y |  |

### X_PostalCode

Baris: 65535 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PostalCode` | float | Y |  |
| 2 | `IDX_M_Country` | float | Y |  |
| 3 | `Province` | nvarchar(255) | Y |  |
| 4 | `Info` | nvarchar(255) | Y |  |
| 5 | `City` | nvarchar(255) | Y |  |
| 6 | `Subdistrict` | nvarchar(255) | Y |  |
| 7 | `District` | nvarchar(255) | Y |  |
| 8 | `Zip` | nvarchar(255) | Y |  |
| 9 | `DCreate` | datetime | Y |  |
| 10 | `UCreate` | nvarchar(255) | Y |  |
| 11 | `DModified` | nvarchar(255) | Y |  |
| 12 | `UModified` | nvarchar(255) | Y |  |
| 13 | `Recordstatus` | nvarchar(255) | Y |  |

### X_PostalCodeAll

Baris: 17177 · PK: (tidak ada)

| # | Kolom | Tipe | Null | Keterangan |
|---:|---|---|---|---|
| 1 | `IDX_M_PostalCode` | float | Y |  |
| 2 | `IDX_M_Country` | float | Y |  |
| 3 | `Province` | nvarchar(255) | Y |  |
| 4 | `Info` | nvarchar(255) | Y |  |
| 5 | `City` | nvarchar(255) | Y |  |
| 6 | `Subdistrict` | nvarchar(255) | Y |  |
| 7 | `District` | nvarchar(255) | Y |  |
| 8 | `Zip` | float | Y |  |
| 9 | `DCreate` | nvarchar(255) | Y |  |
| 10 | `UCreate` | nvarchar(255) | Y |  |
| 11 | `DModified` | nvarchar(255) | Y |  |
| 12 | `UModified` | nvarchar(255) | Y |  |
| 13 | `Recordstatus` | nvarchar(255) | Y |  |
