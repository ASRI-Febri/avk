<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

// MODEL
use App\Models\General\DocumentTypeStatus;

class DropdownController extends Controller
{
    public function company($id='',$connection = 'sqlsrv')
    {
        if ($id != '')
        {
            $sql = "SELECT D.IDX_M_Company, D.CompanyID, D.CompanyName
                    FROM SM_M_User A WITH(NOLOCK)
                        INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
                        INNER JOIN GN_M_Branch C WITH(NOLOCK) ON B.IDX_M_Branch = C.IDX_M_Branch
                        INNER JOIN GN_M_Company D WITH(NOLOCK) ON C.IDX_M_Company = D.IDX_M_Company
                    WHERE A.LoginID = '$id' AND B.RecordStatus = 'A'
                    ORDER BY D.CompanyID";
        }
        else
        {
            $sql = "SELECT IDX_M_Company, CompanyID, CompanyName FROM GN_M_Company WITH(NOLOCK) ORDER BY IDX_M_Company";
        }

        $result =  DB::connection($connection)->select($sql);        

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Company)] = trim($row->CompanyName);
        }
        
        return $value;
    }

    public function branch($id='',$connection = 'sqlsrv')
    {
        if ($id != '')
        {
            // $sql = "SELECT IDX_M_Branch, BranchName + ' - ' + BranchAlias + ' / ' + BranchID AS BranchName
            //         FROM GN_M_Branch 
            //         WHERE IDX_M_Company = $ID AND RecordStatus = 'A'
            //         ORDER BY IDX_M_Branch";

            $sql = "SELECT C.IDX_M_Branch, C.BranchName + ' - ' + C.BranchAlias + ' / ' + C.BranchID AS BranchName
                    FROM SM_M_User A WITH(NOLOCK)
                        INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
                        INNER JOIN GN_M_Branch C WITH(NOLOCK) ON B.IDX_M_Branch = C.IDX_M_Branch
                    WHERE A.LoginID = '$id' AND B.RecordStatus = 'A'
                    ORDER BY C.BranchName";
        } 
        else 
        {
            $sql = "SELECT IDX_M_Branch, BranchName + ' - ' + BranchAlias + ' / ' + BranchID AS BranchName
                    FROM GN_M_Branch WITH(NOLOCK)	
                    WHERE RecordStatus = 'A'				
                    ORDER BY IDX_M_Branch";
        }

        $result =  DB::connection($connection)->select($sql);        

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Branch)] = trim($row->BranchName);
        }
        
        return $value;
    }

    public function document_type($category = '', $connection = 'sqlsrv')
    {
        $sql_where = '';

        if ($category !== '') {
            $sql_where = " WHERE DocumentTypeCategory LIKE '%$category%' ";
        }

        $sql = "SELECT IDX_M_DocumentType, DocumentTypeID, DocumentTypeDesc 
                FROM GN_M_DocumentType 
                $sql_where 
                ORDER BY IDX_M_DocumentType";

        $result =  DB::connection($connection)->select($sql);        

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_DocumentType)] = trim($row->DocumentTypeDesc);
        }
        
        return $value;
    }

    public function document_type_selected($idx,$connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_DocumentType, DocumentTypeID, DocumentTypeDesc 
                FROM GN_M_DocumentType 
                WHERE IDX_M_DocumentType = $idx 
                ORDER BY IDX_M_DocumentType";

        $result =  DB::connection($connection)->select($sql);        

        //$value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_DocumentType)] = trim($row->DocumentTypeDesc);
        }
        
        return $value;
    }

    public function asbs_application($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Application, ApplicationID, ApplicationName, RecordStatus 
                FROM SM_M_Application 
                WHERE RecordStatus = 'A'
                ORDER BY IDX_M_Application";

        $result =  DB::connection($connection)->select($sql);        

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Application)] = trim($row->ApplicationName);
        }
        
        return $value;
    }

    public function asbs_module($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Application, ApplicationID, ApplicationName, RecordStatus 
                FROM SM_M_Application 
                WHERE RecordStatus = 'A'
                ORDER BY IDX_M_Application";

        $result =  DB::connection($connection)->select($sql);        

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Application)] = trim($row->ApplicationName);
        }
        
        return $value;
    }

    public function gender($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Gender, GenderName FROM GN_M_Gender ORDER BY IDX_M_Gender";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Gender)] = trim($row->GenderName);
        }
        return $value;
    }

    public function country($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Country, CountryName FROM GN_M_Country WHERE RecordStatus = 'A' ORDER BY CountryName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Country)] = trim($row->CountryName);
        }
        return $value;
    }

    public function currency($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Currency, CurrencyID, CurrencyName FROM GN_M_Currency WHERE RecordStatus = 'A' ORDER BY CurrencyName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Currency)] = trim($row->CurrencyID) . ' - ' .trim($row->CurrencyName);
        }
        return $value;
    }

    function yes_no()
    {
        $value[''] = '--SELECT--';
        $value['Y'] = 'Yes';
        $value['N'] = 'No';

        return $value;
    }

    function yes_no_bit()
    {
        $value[''] = '--SELECT--';
        $value['1'] = 'Yes';
        $value['0'] = 'No';

        return $value;
    }

    function flag_system()
    {
        $value[''] = '--SELECT--';
        $value['IH'] = 'INHOUSE';
        $value['EZ'] = 'EZITAMA';

        return $value;
    }

    function active_status()
    {
        $value[''] = '--SELECT--';
        $value['A'] = 'Active';
        $value['I'] = 'In-Active';

        return $value;
    }

    public function project($id='',$connection = 'sqlsrv')
    {
        if ($id != '')
        {
            $sql = "SELECT IDX_M_Project, ProjectID, ProjectName 
                    FROM SM_M_User A WITH(NOLOCK)
                        INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
                        INNER JOIN GN_M_Project PJ WITH(NOLOCK) ON B.IDX_M_Branch = PJ.IDX_M_Branch
                    WHERE A.LoginID = '$id' AND B.RecordStatus = 'A'
                    ORDER BY PJ.ProjectName";
        }
        else
        {
            $sql = "SELECT IDX_M_Project, ProjectID, ProjectName 
                    FROM GN_M_Project WITH(NOLOCK)
                    ORDER BY ProjectName";
        }

        $result =  DB::connection($connection)->select($sql);    

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Project)] = trim($row->ProjectName);
        }

        return $value;
    }

    public function department($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Department, DepartmentID, DepartmentName 
                FROM GN_M_Department
                ORDER BY DepartmentName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Department)] = trim($row->DepartmentName);
        }
        return $value;
    }

    public function payment_terms($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_PaymentTerms, Name, Notes 
                FROM GN_M_PaymentTerms 
                WHERE RecordStatus = 'A'
                ORDER BY Name";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_PaymentTerms)] = trim($row->Name);
        }
        return $value;
    }

    public function shipping_terms($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_ShippingTerms, Name, Alias, Notes 
                FROM GN_M_ShippingTerms 
                WHERE RecordStatus = 'A'
                ORDER BY Name";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_ShippingTerms)] = trim($row->Name);
        }
        return $value;
    }

    function getMonth()
    {
        $value[''] = '--';
        $value['01'] = '01';
        $value['02'] = '02';
        $value['03'] = '03';
        $value['04'] = '04';
        $value['05'] = '05';
        $value['06'] = '06';
        $value['07'] = '07';
        $value['08'] = '08';
        $value['09'] = '09';
        $value['10'] = '10';
        $value['11'] = '11';
        $value['12'] = '12';

        return $value;
    }

    function getMonthName()
    {
        $value['00'] = '--';
        $value['01'] = 'January';
        $value['02'] = 'February';
        $value['03'] = 'March';
        $value['04'] = 'April';
        $value['05'] = 'May';
        $value['06'] = 'June';
        $value['07'] = 'July';
        $value['08'] = 'August';
        $value['09'] = 'September';
        $value['10'] = 'October';
        $value['11'] = 'November';
        $value['12'] = 'December';

        return $value;
    }
    
    function getYear()
    {

        $year = 2005;

        $value[''] = '--';
        while ($year <= date('Y')) {
            $value["$year"] = $year;
            $year += 1;
        }

        return $value;
    }

    function ytd_mtd()
    {
        $value[''] = '--SELECT--';
        $value['YTD'] = 'YTD';
        $value['MTD'] = 'MTD';

        return $value;
    }

    function detail_summary()
    {
        $value[''] = '--SELECT--';
        $value['D'] = 'Detail';
        $value['S'] = 'Summary';

        return $value;
    }

    public function address_type($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_AddressType, AddressTypeName  
        FROM GN_M_AddressType 					
        ORDER BY IDX_M_AddressType";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_AddressType)] = trim($row->AddressTypeName);
        }
        return $value;
    }

    public function bank($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Bank, BankCode, BankName
        FROM GN_M_Bank 					
        ORDER BY BankName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Bank)] = trim($row->BankName);
        }
        return $value;
    }

    // BEGIN::INVENTORY
    public function brand($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_Brand, BrandName FROM IN_M_Brand ORDER BY IDX_M_Brand";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Brand)] = trim($row->BrandName);
        }
        return $value;
    }

    public function item_type($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_IN_M_ItemType, ItemTypeID FROM IN_M_ItemType WHERE RecordStatus = 'A' ORDER BY ItemTypeID";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_IN_M_ItemType)] = trim($row->ItemTypeID);
        }
        return $value;
    }

    public function item_category($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_ItemCategory, ItemCategoryName
                FROM IN_M_ItemCategory
                WHERE RecordStatus = 'A'
                ORDER BY ItemCategoryName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_ItemCategory)] = trim($row->ItemCategoryName);
        }
        return $value;
    }

    public function sub_category($IDX_M_ItemCategory, $connection = 'sqlsrv')
    {
        if ($IDX_M_ItemCategory == '') {
            $where = "WHERE RecordStatus = 'A'";
        } else {
            $where = "WHERE RecordStatus = 'A' AND IDX_M_ItemCategory = $IDX_M_ItemCategory ";
        }
        
        $sql = "SELECT IDX_M_SubCategory, SubCategoryName 
                FROM IN_M_SubCategory 
                $where
                ORDER BY IDX_M_SubCategory";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_SubCategory)] = trim($row->SubCategoryName);
        }
        return $value;
    }

    public function material_group($IDX_M_SubCategory, $connection = 'sqlsrv')
    {
        if ($IDX_M_SubCategory == '') {
            $where = "WHERE RecordStatus = 'A'";
        } else {
            $where = "WHERE RecordStatus = 'A' AND IDX_M_SubCategory = $IDX_M_SubCategory ";
        }

        $sql = "SELECT IDX_M_MaterialGroup, MaterialGroupName  
                FROM IN_M_MaterialGroup 
                $where
                ORDER BY IDX_M_MaterialGroup";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_MaterialGroup)] = trim($row->MaterialGroupName);
        }
        return $value;
    }

    public function stock_category($connection = 'sqlsrv')
    {  
        $sql = "SELECT IDX_M_StockCategory, StockCategoryName FROM IN_M_StockCategory WHERE RecordStatus = 'A' ORDER BY IDX_M_StockCategory";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_StockCategory)] = trim($row->StockCategoryName);
        }
        return $value;
    }

    public function uom($connection = 'sqlsrv')
    {  
        $sql = "SELECT IDX_M_UoM, UoMName FROM IN_M_UOM WHERE RecordStatus = 'A' ORDER BY UoMName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_UoM)] = trim($row->UoMName);
        }
        return $value;
    }

    public function color($connection = 'sqlsrv')
    {  
        $sql = "SELECT IDX_M_Color, ColorName FROM IN_M_Color WHERE RecordStatus = 'A' ORDER BY ColorName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Color)] = trim($row->ColorName);
        }
        return $value;
    }

    public function inventory_location($connection = 'sqlsrv')
    {  
        $sql = "SELECT IDX_M_LocationInventory, LocationName
                FROM IN_M_LocationInventory
                WHERE RecordStatus = 'A'
                ORDER BY LocationName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_LocationInventory)] = trim($row->LocationName);
        }
        return $value;
    }
    // END::INVENTORY

    // BEGIN::PROPERTY MANAGEMENT
    public function charge_type($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_ChargeType, ChargeTypeID, ChargeTypeDesc FROM BM_M_ChargeType ORDER BY ChargeTypeID";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_ChargeType)] = trim($row->ChargeTypeID) . ' - ' . trim($row->ChargeTypeDesc);
        }
        return $value;
    }

    public function payment_type($connection = 'sqlsrv')
    {
        $sql = "SELECT Name AS PaymentType FROM GN_M_PaymentType ORDER BY PaymentType";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->PaymentType)] = trim($row->PaymentType);
        }
        return $value;
    }

    public function cluster_name($connection = 'sqlsrv')
    {
        $sql = "SELECT DISTINCT ClusterName FROM BM_T_ChargeMeter ORDER BY ClusterName";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->ClusterName)] = trim($row->ClusterName);
        }
        return $value;
    } 
    // END::PROPERTY MANAGEMENT

    // BEGIN::FINANCE
    function include_tax()
    {
        $value[''] = '--SELECT--';
        $value['1'] = 'Include Tax';
        $value['0'] = 'Exclude Tax';

        return $value;
    }

    public function tax($flag = '', $connection = 'sqlsrv')
    {
        $filter_flag = '';

        if($flag <> '')
        {
            $filter_flag = " AND Flag = 'PPN' ";
        }

        $sql = "SELECT IDX_M_Tax, TaxID, TaxName 
                FROM GL_M_Tax
                WHERE RecordStatus = 'A' $filter_flag";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Tax)] = trim($row->TaxID);
        }
        return $value;
    }    

    // public function coa_1($connection = 'sqlsrv')
    // {
    //     $sql = "SELECT IDX_M_COAGroup1, COAGroup1Name1 
    //     FROM GL_M_COAGroup1
    //     WHERE RecordStatus = 'A'";

    //     $result =  DB::connection($connection)->select($sql);     

    //     $value[''] = '--SELECT--';
    //     foreach ($result as $row){
    //         $value[trim($row->IDX_M_COAGroup1)] = trim($row->COAGroup1Name1);
    //     }
    //     return $value;
    // }
    
    // public function coa_2($connection = 'sqlsrv')
    // {
    //     $sql = "SELECT IDX_M_COAGroup2, COAGroup2Name1 
    //     FROM GL_M_COAGroup2
    //     WHERE RecordStatus = 'A'";

    //     $result =  DB::connection($connection)->select($sql);     

    //     $value[''] = '--SELECT--';
    //     foreach ($result as $row){
    //         $value[trim($row->IDX_M_COAGroup2)] = trim($row->COAGroup2Name1);
    //     }
    //     return $value;
    // }

    // public function coa_3($connection = 'sqlsrv')
    // {
    //     $sql = "SELECT IDX_M_COAGroup3, COAGroup3Name1 
    //     FROM GL_M_COAGroup3
    //     WHERE RecordStatus = 'A'";

    //     $result =  DB::connection($connection)->select($sql);     

    //     $value[''] = '--SELECT--';
    //     foreach ($result as $row){
    //         $value[trim($row->IDX_M_COAGroup3)] = trim($row->COAGroup3Name1);
    //     }
    //     return $value;
    // }
    
    public function account_type()
    {
        $value[''] = '--SELECT--';
        $value['B'] = 'Bank';
        $value['C'] = 'Cash';
        $value['D'] = 'Deposito';

        return $value;
    }

    public function cashflow_flag()
    {
        $value[''] = '--SELECT--';
        $value['A'] = 'Account';
        $value['H'] = 'Header';

        return $value;
    }

    public function salesperson($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_SalesPerson, SalesPersonID, SalesPersonName 
        FROM GN_M_SalesPerson
        WHERE RecordStatus = 'A'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_SalesPerson)] = trim($row->SalesPersonID . ' - ' . $row->SalesPersonName);
        }
        return $value;
    }

    public function payment_method($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_PaymentType, Name 
        FROM GN_M_PaymentType
        WHERE RecordStatus = 'A'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_PaymentType)] = trim($row->Name);
        }
        return $value;
    }

    public function financial_account($id='', $connection = 'sqlsrv')
    {
        if ($id != '')
        {
            $sql = "SELECT IDX_M_FinancialAccount, FinancialAccountID, FinancialAccountDesc
                    FROM CM_M_FinancialAccount A WITH(NOLOCK)
                        INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_Branch = B.IDX_M_Branch AND B.RecordStatus = 'A'
                        INNER JOIN SM_M_User C WITH(NOLOCK) ON B.IDX_M_User = C.IDX_M_User
                    WHERE C.LoginID = '$id' 
                    ORDER BY A.FinancialAccountDesc";
        }
        else
        {
            $sql = "SELECT IDX_M_FinancialAccount, FinancialAccountID, FinancialAccountDesc
            FROM CM_M_FinancialAccount WITH(NOLOCK)
            WHERE RecordStatus = 'A'";
        }

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_FinancialAccount)] = trim($row->FinancialAccountID . ' - ' . $row->FinancialAccountDesc);
        }
        return $value;
    }

    public function coa_transactionsi($id, $connection = 'sqlsrv')
    {
        if ($id != '')
        {
            $sql = "SELECT DISTINCT(COA.IDX_M_COA) AS IDX_M_COA, COA.COAID, COA.COADesc 
                    FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
                        INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON SIH.IDX_T_SalesInvoiceHeader = JH.IDX_ReferenceNo AND SIH.InvoiceNo = JH.ReferenceNo
                        INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
                        INNER JOIN GL_M_COA COA WITH(NOLOCK) ON JD.IDX_M_COA = COA.IDX_M_COA
                    WHERE JH.PostingStatus = 'P' AND JD.ODebetAmount > 0 AND SIH.IDX_T_SalesInvoiceHeader = '$id' ";
        }
        else
        {
            $sql = "";
        }

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_COA)] = trim($row->COAID . ' - ' . $row->COADesc);
        }
        return $value;
    }
    
    public function item_tax($connection = 'sqlsrv', $headerid)
    {
        $sql = "SELECT PID.IDX_M_Item, PID.IDX_T_PurchaseInvoiceDetail, CONCAT(RTRIM(LTRIM(ItemSKU)), ' - ', RTRIM(LTRIM(ItemName)), ' - ', P.ProjectName, ' - ', PID.RemarkDetail) AS ItemDesc
        FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) 
        LEFT JOIN CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
        LEFT JOIN IN_M_Item I WITH(NOLOCK) ON PID.IDX_M_Item = I.IDX_M_Item
        LEFT JOIN GN_M_Project P WITH(NOLOCK) ON PID.IDX_M_Project = P.IDX_M_Project
        WHERE PID.RecordStatus = 'A' AND PIH.IDX_T_PurchaseInvoiceHeader = " . $headerid;

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            // $value[trim($row->IDX_M_Item)] = trim($row->ItemDesc);
            $value[trim($row->IDX_T_PurchaseInvoiceDetail)] = trim($row->ItemDesc);
        }
        return $value;
    }

    public function item_tax_si($connection = 'sqlsrv', $headerid)
    {
        $sql = "SELECT SID.IDX_M_Item, SID.IDX_T_SalesInvoiceDetail, CONCAT(RTRIM(LTRIM(ItemSKU)), ' - ', RTRIM(LTRIM(ItemName)), ' - ', P.ProjectName, ' - ', SID.RemarkDetail) AS ItemDesc
        FROM CM_T_SalesInvoiceDetail SID WITH(NOLOCK) 
        LEFT JOIN CM_T_SalesInvoiceHeader SIH WITH(NOLOCK) ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
        LEFT JOIN IN_M_Item I WITH(NOLOCK) ON SID.IDX_M_Item = I.IDX_M_Item
        LEFT JOIN GN_M_Project P WITH(NOLOCK) ON SID.IDX_M_Project = P.IDX_M_Project
        WHERE SID.RecordStatus = 'A' AND SIH.IDX_T_SalesInvoiceHeader = " . $headerid;

        $result =  DB::connection($connection)->select($sql);    
        // dd($result); 

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            // $value[trim($row->IDX_M_Item)] = trim($row->ItemDesc);
            $value[trim($row->IDX_T_SalesInvoiceDetail)] = trim($row->ItemDesc);
        }
        return $value;
    }

    public function document_no_fp($connection = 'sqlsrv', $IDX_M_Partner)
    {
        // $sql = "SELECT IDX_T_PurchaseInvoiceHeader AS IDX_DocumentNo, InvoiceNo AS DocumentNo 
        //             FROM CM_T_PurchaseInvoiceHeader 
        //             WHERE InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $IDX_M_Partner;

        $sql = "SELECT a.IDX_T_PurchaseInvoiceHeader AS IDX_DocumentNo, a.InvoiceNo AS DocumentNo, a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) 
                + ' - Amount: ' + CONVERT(VARCHAR,sum(DPP.DPP+TAX.TAX)) AS DocumentNo2
                FROM CM_T_PurchaseInvoiceHeader a WITH(NOLOCK)
                    LEFT JOIN 
                    (
                        SELECT IDX_T_PurchaseInvoiceHeader, IDX_T_PurchaseInvoiceDetail, Quantity * (UntaxedAmount - isnull(DiscountAmount,0)) AS DPP 
                        FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK)
                    ) DPP ON a.IDX_T_PurchaseInvoiceHeader = DPP.IDX_T_PurchaseInvoiceHeader
                    LEFT JOIN 
                    (
                        SELECT a.IDX_T_PurchaseInvoiceDetail, a.Quantity * sum(isnull(b.TaxAmount,0)) AS TAX
                        FROM CM_T_PurchaseInvoiceDetail a WITH(NOLOCK)
                            LEFT JOIN CM_T_PurchaseInvoiceTax b WITH(NOLOCK) ON a.IDX_T_PurchaseInvoiceDetail = b.IDX_T_PurchaseInvoiceDetail
                        GROUP BY a.IDX_T_PurchaseInvoiceDetail, a.Quantity
                    ) TAX on DPP.IDX_T_PurchaseInvoiceDetail = TAX.IDX_T_PurchaseInvoiceDetail
                WHERE a.InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $IDX_M_Partner . "
                GROUP BY a.IDX_T_PurchaseInvoiceHeader, a.InvoiceNo, a.InvoiceDate";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_DocumentNo)] = trim($row->DocumentNo);
        }
        return $value;
    }

    public function document_no_fr($connection = 'sqlsrv', $IDX_M_Partner)
    {
        // $sql = "SELECT IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, InvoiceNo AS DocumentNo 
        //             FROM CM_T_SalesInvoiceHeader 
        //             WHERE InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $IDX_M_Partner;

        $sql = "SELECT a.IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, a.InvoiceNo AS DocumentNo, 
                CASE WHEN ISNULL(A.TotalSalesAmount,0) > 0 
                     THEN 
                          a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) + ' - Amount: ' + CONVERT(VARCHAR,A.TotalSalesAmount) 
                     ELSE
                          a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) + ' - Amount: ' + CONVERT(VARCHAR,sum(DPP.DPP+TAX.TAX)) 
                     END AS DocumentNo2
                FROM CM_T_SalesInvoiceHeader a WITH(NOLOCK)
                    LEFT JOIN 
                    (
                        SELECT IDX_T_SalesInvoiceHeader, IDX_T_SalesInvoiceDetail, Quantity * (UntaxedAmount - isnull(DiscountAmount,0)) AS DPP 
                        FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
                    ) DPP ON a.IDX_T_SalesInvoiceHeader = DPP.IDX_T_SalesInvoiceHeader
                    LEFT JOIN 
                    (
                        SELECT a.IDX_T_SalesInvoiceDetail, a.Quantity * sum(isnull(b.TaxAmount,0)) AS TAX
                        FROM CM_T_SalesInvoiceDetail a WITH(NOLOCK)
                            LEFT JOIN CM_T_SalesInvoiceTax b WITH(NOLOCK) ON a.IDX_T_SalesInvoiceDetail = b.IDX_T_SalesInvoiceDetail
                        GROUP BY a.IDX_T_SalesInvoiceDetail, a.Quantity
                    ) TAX on DPP.IDX_T_SalesInvoiceDetail = TAX.IDX_T_SalesInvoiceDetail
                WHERE a.InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $IDX_M_Partner . "
                GROUP BY a.IDX_T_SalesInvoiceHeader, a.InvoiceNo, a.InvoiceDate";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_DocumentNo)] = trim($row->DocumentNo);
        }
        return $value;
    }
    
    // END::FINANCE

    // BEGIN::ACCOUNTING 
    function posting_status()
    {
        $value[''] = '--SELECT--';
        $value['U'] = 'UNPOSTED';
        $value['P'] = 'POSTED';

        return $value;
    }

    function coa_flag()
    {
        $value[''] = '--SELECT--';
        $value['H'] = 'HEADER';
        $value['A'] = 'ACCOUNT';

        return $value;
    }

    function debet_credit()
    {
        $value[''] = '--SELECT--';
        $value['D'] = 'DEBET';
        $value['C'] = 'CREDIT';

        return $value;
    }

    public function coa_type($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_COAType, COATypeDesc 
        FROM GL_M_COAType
        WHERE RecordStatus = 'A'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_COAType)] = trim($row->COATypeDesc);
        }
        return $value;
    }

    public function coa_category($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_COACategory, COACategoryDesc 
        FROM GL_M_COACategory
        WHERE RecordStatus = 'A'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_COACategory)] = trim($row->COACategoryDesc);
        }
        return $value;
    }

    public function coa_reconcile()
    {
        $value[''] = '--SELECT--';
        $value['1'] = 'Yes';
        $value['0'] = 'No';

        return $value;
    }

    public function journal_type($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_JournalType, JournalTypeDesc 
        FROM GL_M_JournalType
        WHERE RecordStatus = 'A'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_JournalType)] = trim($row->JournalTypeDesc);
        }
        return $value;
    }

    public function journal_type_entry($connection = 'sqlsrv')
    {
        $sql = "SELECT IDX_M_JournalType, JournalTypeDesc 
        FROM GL_M_JournalType
        WHERE RecordStatus = 'A' AND AllowJournalEntry ='Y'";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_JournalType)] = trim($row->JournalTypeDesc);
        }
        return $value;
    }

    public function coa_group1($coa_type, $connection = 'sqlsrv')
    {
        if ($coa_type == '') {
            $filter = "";
        } else {
            $filter = " AND IDX_M_COAType = $coa_type ";
        }

        $sql = "SELECT IDX_M_COAGroup1, COAGroup1ID, COAGroup1Name1 
                FROM GL_M_COAGroup1
                WHERE RecordStatus = 'A' $filter ";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_COAGroup1)] = trim($row->COAGroup1Name1);
        }
        return $value;
    }

    public function coa_group2($IDX_M_COAGroup1, $connection = 'sqlsrv')
    {
        if ($IDX_M_COAGroup1 == '') {
            $filter = "";
        } else {
            $filter = " AND IDX_M_COAGroup1 = $IDX_M_COAGroup1 ";
        }

        $sql = "SELECT IDX_M_COAGroup2, COAGroup2ID, COAGroup2Name1 
                FROM GL_M_COAGroup2
                WHERE RecordStatus = 'A' $filter ";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_COAGroup2)] = trim($row->COAGroup2Name1);
        }
        return $value;
    }

    public function coa_group3($IDX_M_COAGroup2, $connection = 'sqlsrv')
    {
        if ($IDX_M_COAGroup2 == '') {
            $filter = "";
        } else {
            $filter = " AND IDX_M_COAGroup2 = $IDX_M_COAGroup2 ";
        }

        $sql = "SELECT IDX_M_COAGroup3, COAGroup3ID, COAGroup3Name1 
                FROM GL_M_COAGroup3
                WHERE RecordStatus = 'A' $filter ";

        $result =  DB::connection($connection)->select($sql);     

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_COAGroup3)] = trim($row->COAGroup3Name1);
        }
        return $value;
    }
    // END::ACCOUNTING 

}