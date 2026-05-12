# CLAUDE.md — AVK Project

## Project Overview

**AVK** (Aset & Valuasi Keuangan) is a Laravel 7 enterprise financial management system for a financial services company. The application handles accounting, finance, money exchange, loans, pawning, procurement, inventory, and general business operations. UI and business logic are in Indonesian.

**Stack:** Laravel 7.29 · PHP 7.2.5+/8.0+ · SQL Server · Blade templates · Bootstrap · DataTables · Laravel Mix

---

## Getting Started

```bash
# Install dependencies
composer install
npm install

# Configure environment
cp .env.example .env
php artisan key:generate

# Start development server
php artisan serve

# Compile frontend (watch mode)
npm run watch
# Or for production
npm run production
```

**Default URL:** `http://localhost:8000` → entry point is `/login`

---

## Architecture

### Key Pattern: Stored Procedures over Eloquent

This app calls SQL Server stored procedures directly — **not** Eloquent ORM. Virtually all business logic lives in the database layer.

```php
// Typical controller data fetch
$result = DB::connection('sqlsrv')->select("EXEC [dbo].[USP_FM_SalesInvoice_List] ...");
```

**Procedure naming convention:** `USP_[Module]_[Entity]_[Action]`
- `USP_GN_Company_List` — General, Company, list
- `USP_FM_SalesInvoice_Save` — Finance, SalesInvoice, save
- `USP_AC_Journal_Delete` — Accounting, Journal, delete

### Controller Base Class

All controllers extend `MyController` (`app/Http/Controllers/MyController.php`), which handles:
- Session-based authentication checks
- Common `$data` array structure
- Shared helper methods

### Standard Controller Properties

```php
protected $sp_getinquiry = 'USP_Module_Entity_List'; // Stored procedure for list
protected $array_column   = [...];                    // DataTable column definitions
protected $array_filter   = [...];                    // Filter parameters
```

### Standard Controller Methods

| Method | Purpose |
|--------|---------|
| `inquiry()` | Render list view |
| `inquiry_data()` | Return DataTable JSON (server-side) |
| `create()` | Render create form |
| `update($id)` | Render edit form |
| `save(Request $r)` | Insert or update via stored procedure |

---

## Directory Structure

```
app/
├── Http/Controllers/
│   ├── MyController.php          # Base controller — extend this
│   ├── Accounting/               # COA, journals, GL/PL reports
│   ├── Finance/                  # Invoices, payments, cashflow, banks
│   ├── General/                  # Company, branch, department, partners
│   ├── MoneyChanger/             # Currency exchange operations
│   ├── Loan/                     # Loan management
│   ├── Pawn/                     # Pawning/pledge management
│   ├── Procurement/              # Purchase orders
│   ├── Inventory/                # Stock management
│   └── UserManagement/           # Users, roles, permissions
├── Imports/                      # Maatwebsite Excel import classes
├── View/Components/              # 30+ reusable Blade components
resources/views/
├── layouts/                      # Master layouts per module
├── navigation/                   # Sidebars & navbars per module
├── components/                   # Shared UI components (Textbox, Dropdown, etc.)
├── accounting/                   # Accounting views
├── finance/                      # Finance views
├── money_changer/                # Money changer views
├── general/                      # General settings views
└── ...                           # One folder per module
routes/web/
├── finance.php
├── accounting.php
├── general.php
├── money_changer.php
├── loan.php
├── pawn.php
├── procurement.php
├── inventory.php
└── security.php
```

---

## Routing Conventions

Routes follow the pattern `/{prefix}-{entity}` grouped by module file:

| Prefix | Module |
|--------|--------|
| `gn-` | General |
| `fm-` | Finance |
| `ac-` | Accounting |
| `mc-` | Money Changer |
| `ln-` | Loan |
| `pw-` | Pawn |
| `pr-` | Procurement |

Standard CRUD route set per entity:
```php
Route::get('/gn-company',            [CompanyController::class, 'inquiry']);
Route::get('/gn-company-data',       [CompanyController::class, 'inquiry_data']);
Route::get('/gn-company-create',     [CompanyController::class, 'create']);
Route::get('/gn-company-update/{id}',[CompanyController::class, 'update']);
Route::post('/gn-company-save',      [CompanyController::class, 'save']);
```

---

## View Conventions

### `$data` Array Structure

All controllers pass a consistent `$data` array to views:

```php
$data = [
    'form_title'     => 'Company Management',
    'form_sub_title' => 'Master Data',
    'form_desc'      => 'Manage company profiles',
    'breads'         => [...],        // Breadcrumb array
    'url_inquiry'    => '/gn-company',
    'url_save'       => '/gn-company-save',
    'state'          => 'create',     // 'create' | 'update' | 'read'
    'table_header'   => [...],        // DataTable column headers
    'table_footer'   => [...],
    'fields'         => $record,      // Form data object/array
];
```

### Blade Components

Reusable form components live in `app/View/Components/` and `resources/views/components/`:

```blade
<x-textbox     name="company_name" label="Company Name" />
<x-dropdown    name="status"       label="Status" />
<x-checkbox    name="is_active"    label="Active" />
<x-date-picker name="start_date"   label="Start Date" />
```

### List Views with DataTables

List views use server-side DataTables. The `inquiry_data()` method returns a JSON payload consumed by DataTables on the frontend.

---

## Authentication

- Session-based (no Laravel Sanctum/Passport)
- Session keys: `user_id`, `user_name`, `user_index`
- Auth check happens in `MyController`
- Login route: `/login` → `LoginController`

---

## Database

- **Driver:** `sqlsrv` (SQL Server)
- **Database:** `AVKDB`
- All schema and business logic live in SQL Server stored procedures
- Only 3 Laravel migrations exist (users, password_resets, failed_jobs) — do not rely on `php artisan migrate` for business tables
- When debugging data issues, check the stored procedure first

---

## Key Packages

| Package | Purpose |
|---------|---------|
| `barryvdh/laravel-dompdf` | PDF report generation |
| `maatwebsite/excel` | Excel import/export |
| `guzzlehttp/guzzle` | HTTP client |
| `fruitcake/laravel-cors` | CORS headers |
| `laravel/tinker` | REPL debugging |

---

## Testing

```bash
php artisan test
# or
vendor/bin/phpunit
```

- Framework: PHPUnit 8/9
- Tests in `tests/Unit/` and `tests/Feature/`
- Test coverage is minimal — most logic is in SQL Server procedures which are not unit tested here

---

## Common Tasks

### Adding a New Feature/Module

1. Create controller in `app/Http/Controllers/[Module]/[Entity]Controller.php` extending `MyController`
2. Add routes to `routes/web/[module].php`
3. Create views in `resources/views/[module]/`
4. Add sidebar link in `resources/views/navigation/sidebar_[module].blade.php`
5. Implement stored procedures in SQL Server following `USP_[Module]_[Entity]_[Action]` naming

### Generating PDF Reports

Use `barryvdh/laravel-dompdf`:
```php
$pdf = PDF::loadView('module.report_view', $data);
return $pdf->download('report.pdf');
```

### Excel Export/Import

Use `maatwebsite/excel` with import classes in `app/Imports/`.

---

## Important Notes

- **Do not use Eloquent** for business data — use stored procedures via `DB::connection('sqlsrv')->select("EXEC ...")`
- **Do not add Laravel migrations** for business tables — the schema is managed directly in SQL Server
- Session auth checks are in `MyController` — new controllers that extend it inherit auth protection automatically
- Frontend assets must be recompiled (`npm run dev`) after modifying files in `resources/js/` or `resources/sass/`
