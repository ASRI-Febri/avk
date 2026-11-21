# Modul General (GN), Security (SM) & Infrastruktur Aplikasi

> Cakupan: semua `USP_GN_*` (45) dan `USP_SM_*` (41) di AVKDB, tabel `GN_*` / `SM_*` / `X_*`, serta lapisan PHP yang dipakai aplikasi untuk berbicara dengan database (`MyController`, login, permission, DataTables, dropdown).
> Sumber: teks SP hasil ekstraksi dari DB lokal (read-only), metadata `meta/*` (params, deps, row count), dan kode di `app/Http/Controllers/{General,UserManagement}`, `LoginController`, `HomeController`, `Dropdown*Controller`, `MyController`, `routes/`.
> Bagian yang bertanda **[TIDAK PASTI]** adalah inferensi yang belum diverifikasi lewat runtime.

---

## 1. Infrastruktur akses database (lapisan PHP)

### 1.1 Gambaran umum

Seluruh controller bisnis meng-`extends` `App\Http\Controllers\MyController` (`app/Http/Controllers/MyController.php`). Tidak ada Eloquent model untuk data bisnis (`use App\Models\Security\Menu` di MyController mengacu ke class yang tidak ada dan tidak dipakai). `app/Repository/LoginRepository.php` hanya stub kosong. Koneksi selalu `sqlsrv` (DB `AVKDB`); beberapa controller menulis nama SP lengkap dengan database, mis. `'AVKDB.dbo.[USP_SM_User_List]'` (hard-coded nama DB).

### 1.2 `exec_sp($sp_name, $sp_param, $return_type = 'list', $connection = 'sqlsrv')`

Cara membangun perintah:

```php
foreach ($sp_param as $value) {
    if (is_numeric($value))            $list .= $value . ',';                 // tanpa kutip
    elseif (substr($value,0,3)=='XXX') $list .= "'" . substr($value,3) . "',"; // buang prefix, beri kutip
    else                               $list .= "'" . $value . "',";          // beri kutip
}
$sql = "EXEC $sp_name " . substr($list, 0, -1);
DB::connection($connection)->select($sql);
```

Konsekuensi yang harus dipahami saat recode:

| Aspek | Perilaku sekarang |
|---|---|
| **Positional** | Key array (`$param['UserID']`) **diabaikan**; hanya urutan insert yang menentukan parameter SP. Menambah parameter SP di tengah langsung menggeser semua nilai (contoh nyata: komentar di `General/PartnerController::save` tentang `@IsDTTOT`, dan `@IDX_M_IDType` sengaja ditaruh paling akhir dengan default `NULL` di `USP_GN_Partner_Save`). |
| **Prefix `XXX`** | Penanda "paksa sebagai string". Dipakai untuk nilai yang *kelihatan* numerik tapi harus string: LoginID (mis. `1406069`), NIK, NPWP, `FormList` (CSV id). Tanpa prefix, `'0012'` dikirim sebagai `0012` (integer 12, nol depan hilang). |
| **Tanpa escaping** | Nilai string dibungkus `'...'` **tanpa** menggandakan `'`. Satu tanda kutip di input = syntax error atau SQL injection. Hanya `AttachmentController::esc()` dan `DTTOTController::esc()` yang melakukan `str_replace("'", "''", ...)`. |
| **NULL** | `is_numeric(null)` false, jadi `null` dikirim sebagai `''` (string kosong). SP tidak pernah menerima NULL lewat jalur ini; SP harus memperlakukan `''`/`0` sebagai "kosong". |
| **`is_numeric` longgar** | `'1e5'`, `' 12'`, `'0x1A'` (PHP 7: tidak numeric), `'12.50'` dikirim tanpa kutip → bisa berubah tipe/nilai. |
| **Hanya result set pertama** | `DB::select` mengambil rowset pertama saja. |
| **`return_type='record'`** | Kalau hasil kosong, query **dieksekusi ulang** via PDO hanya untuk membaca metadata kolom, lalu dikembalikan array `kolom => ''` (dipakai untuk form "create" yang butuh objek kosong, mis. `USP_SM_User_Info` dengan `IDX_M_User=0`). Akibatnya SP dijalankan dua kali; berbahaya kalau SP tersebut menulis data. |

### 1.3 `exec_sp_multi`, `exec_sql`, `exec_insert/update/delete/statement`, `getColumnName`

- `exec_sp_multi($sp, $param)` — string `EXEC` dibangun sama persis (positional + `XXX`), lalu `$pdo->prepare($query)->execute()` **tanpa binding**; loop `nextRowset()` dan mengembalikan array semua rowset (rowset yang gagal di-fetch diganti objek `{ReturnStatus:'Error', ReturnMessage, ReturnUrl}`). Hanya dipakai `MoneyChanger/RptInventoryController`.
- `validate_return($data)` — memeriksa `$data[last][0]->StatusCode == 'success'`. **Tidak ada SP di DB yang mengembalikan kolom `StatusCode`**; ini sisa konvensi lama dan tidak dipakai.
- `exec_sql($sql, $return_type)` — menjalankan SQL mentah; perilaku `record` sama seperti `exec_sp`. Dipakai antara lain `PostalCodeController` dan `HomeController` (SQL di-interpolasi string).
- `exec_insert/update/delete/statement` — wrapper tipis `DB::insert/update/delete/statement` tanpa binding.
- `getColumnName` — duplikat `exec_sql` (nama menyesatkan).

### 1.4 Konvensi return set SP "tulis" (`@TableLog`)

Hampir semua SP Save/Create/Update/Delete di GN/SM memakai pola:

```sql
DECLARE @TableLog TABLE (Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500))
-- validasi: INSERT INTO @TableLog VALUES ('error', 0, '<pesan>')  (bisa lebih dari satu baris)
IF (SELECT COUNT(*) FROM @TableLog) = 0
BEGIN
   -- INSERT (bila PK = 0) atau UPDATE (bila PK <> 0)
   INSERT INTO @TableLog VALUES ('success', <ID>, 'Data Sudah Disimpan')
END
COMMIT; SELECT * FROM @TableLog
-- CATCH: INSERT ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE())); SELECT ...; rollback/commit by XACT_STATE
```

- Kolom: `Result` (`'success'`/`'error'`), `ID` (PK yang disimpan, atau ID parent untuk detail, dipakai untuk redirect), `LogDesc` (pesan untuk user).
- `USP_SM_User_SendResetPassword` menambah kolom ke-4 `MemberName`; `USP_SM_User_CheckResetPassword` memakai `ID VARCHAR(150)` (isinya email); `USP_SM_Group_AddForm`/`User_AddGroup/AddBranch/AddProject` memakai `ID VARCHAR(20)`.
- SP baru (Attachment, DTTOT, QuickAddress, SetDTTOT) mengembalikan langsung `SELECT 'success' AS Result, ... AS ID, ... AS LogDesc` atau hanya `Result`.

**Bug sistemik di blok CATCH:** `CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE())` menjumlahkan INT dengan VARCHAR → SQL Server mencoba mengonversi pesan error ke INT → **error baru di dalam CATCH**, sehingga yang sampai ke PHP adalah exception (HTTP 500 / respons JSON rusak), bukan baris `error`. Selain itu `CONVERT(VARCHAR, …)` tanpa panjang memotong ke 30 karakter, `SELECT * FROM @TableLog` dijalankan sebelum rollback, dan `XACT_STATE() = 1` di-**COMMIT** (perubahan parsial tersimpan). Hanya `USP_GN_PartnerQuickAddress_Create` yang menulis versi benar (`CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE()`).

### 1.5 `store($state, $data, $custom_next_url = '', $send_email = [...])`

1. Memilih SP berdasarkan `$state`: `create→$this->sp_create`, `update→sp_update`, `delete→sp_delete`, `activate→activate()` (method tidak ada di MyController → fatal bila dipakai), `approve→sp_approval`, `reverse_approve→sp_reverse_approval`, `validate→sp_validate`, `void→sp_void`, `renewal→sp_renewal`, `termination→sp_termination`. Semua lewat `exec_sp(..., 'list')`.
2. Iterasi semua baris hasil; **baris terakhir** menentukan `$flag = Result` dan `$id = ID`.
3. `success` → (opsional `Mail::send`; `Mail` tidak di-`use` di MyController → fatal bila `send_email=true`) → JSON `{flag:'success', message, id, next_action, url}` dengan `url = $this->next_url.'/'.$id` (atau `next_url` saja bila `$custom_next_url` diisi).
4. `error` → `{flag:'error', message, id, url}`.
5. Hasil kosong → `{flag:'error', message:'</div>'}`. Bila flag bukan `success`/`error`, `$obj` tidak terdefinisi (notice PHP).
6. Output di-`echo json_encode(...)` (bukan `return response()->json`).

`sweet_alert_message($query)` menggabungkan **semua** `LogDesc` menjadi `<span style="display:block;">…</span>` + `"</div>"` liar di akhir. `LogDesc` **tidak di-escape HTML** (mis. pesan `'NIK … sudah terdaftar atas nama ' + PartnerName` dapat membawa HTML dari data).

`validation_fails($errors, $id)` mengubah error `Validator` Laravel ke JSON `{flag:'error', id, message:'<span class="text-danger">…</span>…'}` (juga di-`echo`).

### 1.6 Server-side DataTables: `$array_column`, `$array_filter`, `get_datatables()`

Alur:

```
inquiry()       → view list, kirim table_header/table_footer/array_filter (nama input filter)
inquiry_data()  → $this->sp_getinquiry = 'USP_X_Entity_List'
                  $this->array_filter = [filter1 => $request->input(..), ...]   // URUTAN = urutan parameter SP
                  $this->array_column = ['RowNumber','IDX_…',...]                // kolom yang dikirim ke klien
                  return $this->get_datatables($request);
```

`get_datatables($request)` membangun array positional:

| Posisi | Nilai | Parameter SP |
|---|---|---|
| 1 | `page = (start + length) / length` | `@Page INT` |
| 2 | `row = length` (default 10) | `@Row INT` |
| 3 | `sort_by = columns[order[0].column].data` (nama kolom dari klien) | `@SortBy VARCHAR(50)` |
| 4 | `sort_dir = order[0].dir` | `@SortDir VARCHAR(50)` |
| 5 | `'R'` (lalu dipanggil ulang dengan `'C'`) | `@ReturnType CHAR(1)` |
| 6.. | nilai `array_filter` sesuai urutan | filter khusus SP |

SP dipanggil **dua kali**: `R` → baris data, `C` → `SELECT COUNT(*) AS TotalRows`. Respons: `{sEcho, iTotalRecords: <filtered>, iTotalDisplayRecords: <filtered>, aaData: [ {kolom: nilai} ... ]}` (total tanpa filter tidak pernah dihitung). `sSearch` (global search) dibaca tapi tidak dipakai; pencarian hanya lewat filter per kolom. `length = -1` ("All") menghasilkan halaman negatif/aneh.

Pola SP `*_List` (identik di semua GN/SM List paging):

```sql
SET @_Filter = '%' + RTRIM(@Filter) + '%'                 -- LIKE contains
SET @_Sort1  = @SortBy + ' ' + @SortDir                   -- string mentah dari klien!
IF RTRIM(@SortBy) IN ('RowNumber', 'ID' / '<PK>') SET @_Sort1 = '<PK> ' + @SortDir
@FromRow = (@Page-1)*@Row + 1 ; @ToRow = @FromRow + @Row - 1
SQL = 'SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber, <kolom>,
         StatusDesc = CASE RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END
       FROM … WHERE <kolom> LIKE ''' + @_Filter + ''' AND …) AS DerivedTable
       WHERE RowNumber BETWEEN @FromRow AND @ToRow'
EXEC(@SQL)  -- R ;  EXEC('SELECT COUNT(*) AS TotalRows ' + FROM + WHERE) -- C
```

Padanan Laravel: `->where(col, 'like', "%{$v}%")->orderBy(whitelist[$sortBy], $dir === 'desc' ? 'desc' : 'asc')->skip(($page-1)*$row)->take($row)` + `->count()`.

### 1.7 Helper di MyController

| Helper | Fungsi | Catatan |
|---|---|---|
| `penyebut($n)` / `terbilang($n)` | Angka → kata Bahasa Indonesia ("seratus dua puluh ribu …"), negatif diberi "minus". Mendukung sampai < 1.000 triliun. Desimal diabaikan (rekursi pakai `/` float + `%`). | Dipakai `Finance/{FinancialPayment,FinancialReceive,InternalTransfer,PettyCash,SalesInvoice}Controller` untuk kuitansi/print. |
| `indonesian_date('Y-m-d')` | → `"17 Agustus 2026"` | |
| `indonesian_month('Y-m-d')` | → nama bulan | |
| `PMT($rate, $nper, $pv, $fv=0, $type=0)` | Salinan rumus PMT Excel | Hanya relevan untuk modul Loan (dead, lihat §5). |
| `get_flat_installment($flat_rate, $principal, $tenor)` | `(P + P*rate/12/100*tenor) / tenor` | Loan. |
| `rate($nper, $pmt, $pv, $fv, $type, $guess)` | Rumus RATE Excel (secant, maks 20 iterasi) → **persen tahunan** (`rate*100*12`) | Loan. |
| `calculate_rate()` | Memakai `$this->input->post` / `$this->load->view` (API **CodeIgniter**) | Pasti fatal di Laravel; kode mati. |
| `get_avatar()` | Cek `public/img/user/<user_id>.jpg`, tapi URL yang dikembalikan `public/assets/media/users/...` (path beda). | |
| `get_detail_by_id` / `get_list_by_id` | Memanggil `$this->sp_getdata` / `sp_getdetail_list` dengan satu parameter `IDX`. | |
| `show_no_access` / `show_no_access_modal` | View `layouts/no_access_form` / `no_access_modal_form`. | |

### 1.8 Risiko SQL injection — konkret

1. **Login pra-autentikasi** (`LoginController::validate_user`):
   `"EXEC [USP_SM_CheckLoginValidation] '$user_id','$user_password'"` — input mentah dari form login. Payload `UserID = x';UPDATE SM_M_User SET Password2='…' WHERE LoginID='admin';--` dieksekusi **tanpa login** (stacked query didukung driver sqlsrv). Ini risiko paling kritis di aplikasi.
2. **Semua `exec_sp`** — setiap field form (nama partner, alamat, catatan, dll.) disisipkan dengan `'…'` tanpa escape. Input berisi `'` (mis. nama "Ma'ruf") sudah cukup untuk error; input yang disusun bisa menjalankan SQL apa pun dengan hak user DB aplikasi.
3. **Injeksi dua tingkat di SP `*_List`** — filter DataTables (`PartnerName`, `BranchID`, …) masuk ke `exec_sp` (tingkat 1) lalu ke string dinamis `EXEC(@SqlSelect …)` di SP (tingkat 2, `LIKE '''+@_X+'''` tanpa `QUOTENAME`/`REPLACE`). Kolom urut `@SortBy`/`@SortDir` berasal dari `columns[i][data]` milik klien dan langsung masuk `ORDER BY` (tidak bisa diparameterisasi; harus di-whitelist).
4. **SP mapping CSV** — `USP_SM_Group_AddForm`, `USP_SM_User_AddGroup/AddBranch/AddProject` membangun `... IN (' + @FormList + ')'` dan `''' + @UserID + '''` lalu `EXEC(@_Sql)`. Isi `@FormList` berasal dari nilai checkbox `chk_box[]` yang digabung koma di PHP.
5. **SQL mentah di PHP**: `MyController::check_permission` (`WHERE U.LoginID = '$user_id' … = '$menu_id'`), `PostalCodeController::search_postal_code` (`LIKE '%$search_value%'` dari `q`), `DropdownController::company/branch($id)` (`A.LoginID = '$id'`), `HomeController` (`$sql_po`, `$sql_spk`).
6. **Contoh yang sudah benar** (bisa dijadikan acuan): `PartnerController::quick_save` dan `tanda_dttot` memakai `DB::select("EXEC … @Param = ?", [...])` dengan named parameter + binding.

### 1.9 Risiko positional parameter — konkret

- `General/BankController::save` dan `Finance/BankController::save` mengirim **10** nilai hasil copy-paste dari Branch (`IDX_M_Bank, IDX_M_Parent, IDX_M_Company, IDX_M_LocationInventory, BankID, BankName, BankAlias, BankAddress, UserID, RecordStatus`) ke `USP_GN_Bank_Save` yang hanya punya **6** parameter (`@IDX_M_Bank, @BankCode, @BankName, @BankAlias, @UserID, @RecordStatus`) → SQL error "too many arguments"; validator juga mewajibkan field Branch (`IDX_M_Company`, `BranchID`, …). **Simpan Bank kemungkinan besar tidak pernah berhasil.**
- `CompanyController::save` mengirim `Logo = $data['Country']` (bug copy-paste) dan `PKPIdentityNumber='0'`, `Fax=''` hard-coded.
- `DocumentTypeController::save` mengirim 13 nilai (termasuk `TableReferenceHeader/Detail`) ke `USP_GN_DocumentType_Save` yang **tidak ada** di DB; SP yang ada (`USP_GN_DocumentType_Update`) punya 10 parameter tanpa TableReference.
- `PartnerController::save` harus menjaga urutan 33 parameter `USP_GN_Partner_Save` (lihat §3.9).

---

## 2. Autentikasi & otorisasi

### 2.1 Flow login

Routes (`routes/web.php`): `GET /` & `GET /login` → `LoginController@index` (view `login`), `POST /login/validate_user` → `validate_user`, `GET /logout` → `logout`.

`validate_user`:
1. `Validator`: `UserID` required ("User ID belum diisi!"), `UserPassword` required ("Password belum diisi!").
2. `trim()` keduanya, lalu `EXEC [USP_SM_CheckLoginValidation] '$user_id','$user_password'` (string mentah).
3. Jika ada baris `Result='success'` → session:
   - `user_id` = `$request['UserID']` (**nilai request asli, belum di-trim**, bukan `LoginID` dari DB)
   - `user_name` = `LogDesc` (= `RTRIM(SM_M_User.Name)`)
   - `user_index` = `ID` (= `IDX_M_User`)
   - `token` = `$request['_token']` (token CSRF dipakai ulang sebagai "token login")
   - JSON `{flag:'success', message:'Login Success!', url_next: /home}`
4. Selain itu: `{flag:'error', message:'Invalid User Name or Password!'}`.
5. Tidak ada `session()->regenerate()` (session fixation), tidak ada rate-limit/lockout, tidak ada update `LastLogin`/`LastIPAddress`/`FailedLoginAttemps` walau kolomnya ada.

`logout` → `session()->flush()` → redirect `/login`.

**`USP_SM_CheckLoginValidation(@UserID VARCHAR(50), @UserPassword VARCHAR(50))`**
- Error (boleh lebih dari satu): `'User ID required !'` bila kosong; `'User Password required !'` bila kosong; `'Invalid User ID or Password !'` bila tidak ada `SM_M_User` dengan `RTRIM(LoginID)=RTRIM(@UserID) AND RTRIM(Password2) = CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@UserPassword)), 2)`.
- Sukses: `('success', IDX_M_User, RTRIM(Name))` dengan `WHERE LoginID = @UserID`.
- **Tidak memeriksa** `RecordStatus`, `IsLocked`, `LockDate`, `FailedLoginAttemps` → user nonaktif tetap bisa login.

**Hashing password:** MD5 tanpa salt dari password yang di-`RTRIM`, hex **uppercase** 32 karakter, di kolom `SM_M_User.Password2` (kolom `Password` dan `Pin` legacy/tidak dipakai). Password lebih dari 50 karakter terpotong oleh tipe parameter. Saat recode: migrasi ke `password_hash()`/bcrypt dengan strategi "rehash on login" (verifikasi MD5 lama → simpan hash baru).

### 2.2 Proteksi route (pengganti middleware auth)

Tidak memakai middleware `auth` Laravel. Di `MyController::__construct` didaftarkan closure middleware: bila `$request->path()` **tidak** ada di `$route_exception` dan `session('token')` kosong → `redirect('login')`; jika ada, mengisi `$this->data['user_index'|'user_id'|'user_name']` dan avatar.

`$route_exception = ['register-new-account', 'register-new-account/save', 'sm-forgot-password', 'login', 'login/validate_user', 'logout', 'mc-display-kurs', 'test']` — `mc-display-kurs` (papan kurs publik) sengaja terbuka; `register-new-account`, `sm-forgot-password`, `test` tidak punya route aktif.

Catatan:
- Controller yang **tidak** extends MyController tidak terlindungi: `MoneyChanger/FileController` (route `/download-files/{filename}`, `/show-files/{filename}` → `storage/app/sop-pdf/` tanpa login), `Dropdown*Controller` (hanya di-`new` dari controller lain, tidak di-route), `LandingController`.
- Child controller wajib memanggil `parent::__construct($request)`; semua controller saat ini melakukannya.
- CSRF aktif untuk group `web` (`VerifyCsrfToken`, `$except` kosong). Session driver `file`, lifetime 120 menit.

### 2.3 Model otorisasi (Form ↔ Group ↔ User)

```
SM_M_Application (2) ─┐
SM_M_Module (1)  ─────┼─< SM_M_Form (141, FormID unik mis. 'SM-USER-R', 'FM-FP-U')
                      │        │
                      │   SM_M_GroupForm (235)  ─> SM_M_Group (6)
                      │                                 │
SM_M_User (17) ─< SM_M_UserGroup (19) ──────────────────┘
      ├─< SM_M_UserBranch (19)   ─> GN_M_Branch      (scoping data cabang)
      ├─< SM_M_UserProject (0)   ─> GN_M_Project
      ├─< SM_M_UserDepartment (0)─> GN_M_Department
      └─< SM_M_UserCompany (0)   (tidak dipakai)
```

Hak akses = **boolean per FormID**: user punya akses ke form X bila ada `GroupForm(group, form X)` untuk salah satu group user. Tidak ada granularitas aksi (R/C/U/D) selain lewat FormID terpisah (konvensi suffix `-R`, `-C`, `-U`, mis. `SM-USER-R/C/U`, `FM-FP-R/U`). Tabel `SM_M_Position`, `SM_M_RoleAction`, `SM_M_RolePosition`, `SM_T_RolePosition` (desain RBAC per posisi) kosong dan tidak dipakai.

**`MyController::check_permission($user_id, $menu_id)`** (argumen ke-3 seperti `'R'` diabaikan):

```sql
SELECT U.LoginID, MF.FormID
FROM SM_M_GroupForm MUGF
LEFT JOIN SM_M_Group MUG ON MUGF.IDX_M_Group = MUG.IDX_M_Group
LEFT JOIN SM_M_UserGroup MU ON MUGF.IDX_M_Group = MU.IDX_M_Group
LEFT JOIN SM_M_User U ON U.IDX_M_User = MU.IDX_M_User
INNER JOIN SM_M_Form MF ON MUGF.IDX_M_Form = MF.IDX_M_Form
WHERE U.LoginID = '$user_id' AND RTRIM(ISNULL(MF.FormID,'')) = '$menu_id'
```

→ `TRUE` bila ada baris. **Tidak memfilter `RecordStatus` di tabel mana pun.** Dampak:
- `USP_SM_User_DeleteGroup` hanya men-set `SM_M_UserGroup.RecordStatus='I'` → **akses user TIDAK tercabut** (cek permission tetap lolos). Bug keamanan nyata.
- Group/Form/User yang di-nonaktifkan tetap memberi akses.
- Hanya `USP_SM_Group_DeleteForm` yang benar-benar `DELETE` (komentar di SP menyebut alasan ini).

`USP_SM_CheckUserForm(@UserID, @FormID, @Output INT OUTPUT)` berisi query yang sama (output 1/0) tetapi **tidak dipanggil** dari kode maupun SP lain.

**Pemakaian:** sekitar 80 file controller memanggil `check_permission`, umumnya hanya di `inquiry()`, `create()`, `update()` (menampilkan form). Endpoint `save`, `inquiry_data`, `delete`, `reset_password`, `save_*` **pada umumnya tidak** memeriksa permission → user yang login bisa POST langsung. Di GN hampir semua pemanggilan dikomentari (`//$access = …'AAA'…`), kecuali `CountryController` (memakai FormID salah hasil copy-paste: `'CF-LO-R'`, `'FM-FA-C'`, `'FM-FA-U'`), `Finance/CurrencyController` (sama), dan `AttachmentController` (`FP` → `FM-FP-R`/`FM-FP-U`; `JE` → tanpa cek). `UserController` memakai `SM-USER-R/C/U` untuk view saja. `DTTOTController` tidak memeriksa permission sama sekali.

### 2.4 Menu / sidebar

Menu **statis** di Blade: `resources/views/navigation/sidebar_{portal,money_changer,finance,accounting,general,user_management,pawn,loan}.blade.php`, dipilih lewat `$this->data['sidebar']` di constructor tiap controller. Menu **tidak** difilter permission dan tidak membaca `SM_M_Form.ShowInSidebar`/`IconClass*` (kolom ini hanya disimpan lewat `USP_SM_Form_Save`). `HomeController::user_management` masih memanggil `USP_SM_FormByUser_List` ke `records_form` (SP ini mengabaikan parameter `@UserID` dan mengembalikan semua form × application × module — hasilnya cross join dengan `SM_M_Module` per application). `USP_SM_ApplicationByUser_List` hanya ada di komentar MyController. `GN_M_Menu` kosong.

### 2.5 Scoping cabang / project

`SM_M_UserBranch` (aktif `RecordStatus='A'`) dipakai untuk membatasi pilihan: `DropdownController::branch($login_id)` dan `company($login_id)` (company diturunkan dari branch user), serta SP `USP_CM_BankStatement_List` dan `USP_CM_PettyCash_List`. Scoping lain (transaksi MC, jurnal) **tidak** konsisten memakai tabel ini [TIDAK PASTI per modul; lihat dokumen modul masing-masing]. `SM_M_UserProject`/`UserDepartment` kosong.

### 2.6 Manajemen User / Group / Form — controller & SP

Routes di `routes/web/security.php` (prefix `sm-`).

**User** (`UserManagement/UserController`):

| Aksi | Route | SP | Parameter (urutan) |
|---|---|---|---|
| List | `POST /sm-user-list` | `USP_SM_User_List` | paging + `@UserID` (LIKE LoginID), `@UserName` (LIKE Name). SortBy `UserName`/`UserAlias` dipetakan ke `Name`/`Alias`. |
| Form create/update | `GET /sm-user/create`, `/sm-user/update/{id}` | `USP_SM_User_Info(@UserID, @IDX_M_User)` + `USP_SM_UserGroup_List`, `USP_SM_UserBranch_List`, `USP_SM_UserProject_List`, `USP_SM_UserDepartment_List` (semua `@IDX_M_User`) | Info: bila `@IDX_M_User=0` SP memakai **LoginID hard-coded `1009095`** (bug; hanya untuk mendapatkan struktur kolom). Info mengembalikan `MU.*` termasuk hash `Password2` ke view. |
| Simpan | `POST /sm-user/save` | create: `USP_SM_User_Create(@IDX_M_Gender, @LoginID, @Name, @Alias, @Email, @Password2, @Password2Confirm, @Notes, @CompanyCheck, @BranchCheck, @GroupCheck, @UserID, @RecordStatus)`; update: `USP_SM_User_Update(@IDX_M_User, …sama…)` | Validator PHP: `IDX_M_Gender`, `LoginID`, `Name` required. Controller selalu kirim `CompanyCheck/BranchCheck/GroupCheck=''`, `RecordStatus='A'`, password kosong saat update. |
| Reset password | `POST /sm-user/reset` (konfirmasi), `/sm-user/save-reset-password` | `USP_SM_User_ResetPassword(@IDX_M_User, @UserID, @RecordStatus)` | `@UserID` = **LoginID user target** → `Password2 = MD5(LoginID)`. Artinya password direset menjadi sama dengan User ID. Tidak ada cek permission. |
| Ganti password | `GET /sm-user/change-password/{id}`, `POST /sm-user/save-change-password` | `USP_SM_User_ChangePassword` | **SP tidak ada di DB** → fitur rusak. Validator: `NewPassword` min 5. `{id}` dari URL (IDOR: bisa membuka data user lain). |
| Group user | `/sm-user-group/*` | `USP_SM_User_AddGroup(@IDX_M_User, @GroupList, @UserID, @RecordStatus)`, `USP_SM_User_DeleteGroup(@IDX_M_UserGroup, @UserID, @RecordStatus)`, `USP_SM_User_ActivateGroup(...)`, picker: `USP_SM_Group_List` dengan `@UserID` | |
| Branch user | `/sm-user-branch/*` (`UserBranchController`) | `USP_SM_User_AddBranch`, `_DeleteBranch`, `_ActivateBranch`, picker `USP_GN_Branch_Selected_List` | |
| Project user | `/sm-user-project/*` (`UserProjectController`) | `USP_SM_User_AddProject`, `_DeleteProject`, `_ActivateProject`, picker `USP_CM_Project_Selected_List` (**tidak ada**) | |

Aturan SP User:
- `USP_SM_User_Create`: error `'User ID Already Exists!'` (cek `RTRIM(UPPER(LoginID))`, case-insensitive), `'Password is required!'`, `'Different Password & Password Confirmation !'`. Insert `Password2 = MD5(RTRIM(@Password2))` upper hex. Loop parsing `@CompanyCheck/@BranchCheck/@GroupCheck` **dikomentari** (tidak melakukan apa pun). Return ID = `IDX_M_User` baru.
- `USP_SM_User_Update`: error `'User ID Already Exists!'` (LoginID lain). Update `LoginID, IDX_M_Gender, Name, Email, Alias, Notes, UModified, DModified, RecordStatus`. **Password tidak diubah.** `@_FormID='SM-USID-002'` dideklarasi tapi tidak dipakai.
- `USP_SM_User_AddGroup/AddBranch/AddProject`: error `'No data selected !'` bila list kosong; untuk tiap id yang **sudah ada** (termasuk yang berstatus `I`) error `'Group <id> - <GroupName> already exists!'` / `'Branch <id> - <BranchName> already exists!'` / `'Project <id> - <ProjectName> already exists!'` → satu duplikat membatalkan seluruh batch. Bila lolos: `INSERT … SELECT … FROM SM_M_Group/GN_M_Branch/GN_M_Project WHERE RecordStatus='A' AND id IN (list)` (id nonaktif dilewati diam-diam). Return ID = `IDX_M_User`. Mapping yang di-nonaktifkan harus diaktifkan lewat Activate, bukan ditambah ulang.
- `USP_SM_User_DeleteX`: `UPDATE … SET RecordStatus='I'` (soft); `USP_SM_User_ActivateX`: `SET RecordStatus='A'`. Keduanya tidak mengisi `UModified/DModified` (parameter `@UserID`, `@RecordStatus` diabaikan). Return ID = `IDX_M_User` (untuk reload tabel). Pesan sukses `'Data Sudah Dihapus!'` (DeleteBranch) atau `'Data Sudah Disimpan'`.

**Group** (`UserManagement/GroupUserController`):

| Aksi | SP | Catatan |
|---|---|---|
| List | `USP_SM_Group_List(paging, @GroupID, @GroupName, @UserID='')` | Bila `@UserID` diisi, hanya group yang **belum** dimiliki user (dipakai picker "tambah group ke user"). |
| Info | `USP_SM_Group_Info(@IDX_M_Group)` | + nama pembuat/pengubah dari `SM_M_User`. |
| Daftar form milik group | `USP_SM_GroupForm_List(@IDX_M_Group)` | |
| Create | `USP_SM_Group_Create(@GroupID, @GroupName, @Notes, @FormCheck, @UserID, @RecordStatus)` | error `'Group ID Already Exists!'` (case-insensitive). Lalu `DELETE GroupForm` milik group baru dan parsing CSV `@FormCheck`. |
| Update | `USP_SM_Group_Update(@IDX_M_Group SMALLINT, @GroupID, @GroupName, @Notes, @FormCheck, @UserID, @RecordStatus)` | error `'Group ID Already Exists!'`. **Selalu `DELETE SM_M_GroupForm WHERE IDX_M_Group=@IDX`** lalu insert ulang dari `@FormCheck`. Controller mengirim `FormCheck=''` bila tidak ada di request, dan tidak ada view yang mengirim `FormCheck` → **mengedit header group kemungkinan besar menghapus seluruh hak akses group tersebut** [perlu verifikasi di UI, tetapi kodenya jelas]. |
| Tambah form | `USP_SM_Group_AddForm(@IDX_M_Group, @FormList, @UserID, @RecordStatus)` | Sama seperti User_AddGroup: error `'No data selected !'`, `'Group <idgroup> - <FormName> already exists!'`; insert hanya form `RecordStatus='A'`. |
| Hapus form | `USP_SM_Group_DeleteForm(@IDX_M_GroupForm, @UserID, @RecordStatus)` | Hard `DELETE`; error `'Group access not found!'`; return ID = `IDX_M_Group`. |

Parsing CSV di Create/Update: loop `CHARINDEX(',')` — **item terakhir tanpa koma penutup diabaikan**; `CONVERT(INT, @value)` gagal bila ada spasi/teks.

**Form** (`UserManagement/FormController`):
- List: `USP_SM_Form_List(paging, @ApplicationID [LIKE ApplicationName], @FormID, @FormName, @FormDescription, @FormURL, @GroupID='')` — bila `@GroupID` diisi hanya form yang belum ada di group tsb (picker). Ada `PRINT` dynamic SQL (sisa debug).
- Info: `USP_SM_Form_Info(@IDX_M_Form)`.
- Simpan (create & update): `USP_SM_Form_Save(@IDX_M_Form, @IDX_M_Application, @IDX_M_Module, @FormID, @FormName, @FormDescription, @FormURL, @IconClass1..3, @ShowInSidebar, @UserID, @RecordStatus)`; error `'Form ID Already Exists!'` (case-insensitive, kecuali dirinya). Controller selalu `IDX_M_Module='0'`, `ShowInSidebar` default `'N'`. Insert **tidak mengisi `IDX_M_Module`** dan `ApplicationID` (kolom teks) — hanya `IDX_M_Application`.
- `USP_IN_LocationInventory_List` disebut di FormController tetapi hanya di komentar.

### 2.7 Lupa password (tidak aktif)

`USP_SM_User_SendResetPassword(@EmailAddress, @ResetPasswordKey)` → validasi `'Alamat Email tidak terdaftar!'`, `'Link already expired!'`; insert `SM_T_CustomerResetPassword(EmailAddress, ResetPasswordKey=MD5(key), IsExpired=0, IsReset=0)`; return `MemberName`.
`USP_SM_User_CheckResetPassword(@ResetPasswordKey)` → `'Invalid request!'` / `'Link already expired!'`, sukses mengembalikan email di kolom `ID`.
`USP_SM_User_SaveResetPassword(@EmailAddress, @AccountPassword, @AccountPasswordConfirm)` → `'Password and Password confirmation not match!'`; `UPDATE SM_M_User SET Password2=MD5(pwd) WHERE Email=@EmailAddress` (**semua** user dengan email itu), tandai semua token email tsb `IsExpired=1, IsReset=1`. `ExpiredDate` tidak pernah diisi/dicek.
Route `ForgotPasswordController` dikomentari di `routes/web.php`; ketiga SP tidak dipanggil. Tabel kosong.

---

## 3. Master data GN

Konvensi umum master GN: PK `IDX_M_<Entity>` (IDENTITY), kode bisnis `<Entity>ID`, audit `UCreate/DCreate/UModified/DModified`, `RecordStatus` (`'A'` aktif, `'I'` nonaktif, `'D'` dihapus — hanya Attachment). Save SP: `@IDX=0` → INSERT, selain itu UPDATE (upsert by PK). `@UserID` sering `VARCHAR(10)` (LoginID lebih panjang terpotong di audit). Tidak ada unique index di DB (hanya PK); semua aturan unik ada di SP dan tidak aman terhadap race condition. FK fisik hanya satu: `GN_M_Partner.IDX_M_IDType → GN_M_IDType`.

### 3.1 Company — `GN_M_Company` (1 baris)

Routes `gn-company*` → `General/CompanyController`.

| SP | Parameter | Logika |
|---|---|---|
| `USP_GN_Company_List` | paging, `@CompanyID`, `@CompanyName`, `@CompanyAlias` | LIKE; tidak filter RecordStatus. |
| `USP_GN_Company_Info` | `@IDX_M_Company` | kolom utama (tanpa Country, WhatsappNo, BankAccount*, RetainedEarningAccount, CurrentEarningAccount). |
| `USP_GN_Company_Save` | `@IDX_M_Company, @IDX_M_Parent, @IDX_M_Currency, @CompanyID CHAR(1), @CompanyName, @CompanyAlias, @SIUP, @NPWP, @PKPIdentityNumber, @PKPDate, @Phone, @Fax, @Email, @LegalAddress, @Country, @Province, @City, @Subdistrict, @District, @Zip, @Logo, @Website, @Remarks, @UserID, @RecordStatus` | Error `'Company ID already exists!'`. **`@CompanyID` bertipe `CHAR(1)`** → kode perusahaan terpotong 1 karakter sebelum cek duplikat & simpan. Pada INSERT, ID yang dikembalikan tetap `0` (tidak membaca `SCOPE_IDENTITY()`), sehingga redirect ke `/gn-company/update/0`. |

Kolom `RetainedEarningAccount`/`CurrentEarningAccount` (COA laba ditahan/berjalan) tidak bisa diisi lewat aplikasi tetapi kemungkinan dibaca modul Accounting [TIDAK PASTI].

### 3.2 Branch — `GN_M_Branch` (2 baris)

Routes `gn-branch*` → `General/BranchController`.

| SP | Parameter | Logika |
|---|---|---|
| `USP_GN_Branch_List` | paging, `@BranchID`, `@BranchName`, `@BranchAlias`, `@UserID=''` | Hanya `RecordStatus='A'`; join COA (`COASales`). Join ke UserBranch dibuat tapi tidak memfilter apa pun. |
| `USP_GN_Branch_Selected_List` | sama | Hanya branch aktif yang **belum** dimiliki `@UserID` (picker User → Branch). |
| `USP_GN_Branch_Info` | `@IDX_M_Branch` | Join `IN_M_LocationInventory ON LI.IDX_M_LocationInventory = C.IDX_M_Branch` (**bug: seharusnya `C.IDX_M_LocationInventory`**), join COA sales. |
| `USP_GN_Branch_Save` | `@IDX_M_Branch, @IDX_M_Parent, @IDX_M_Company, @IDX_M_LocationInventory, @BranchID, @BranchName, @BranchAlias, @BranchAddress, @BranchRemark, @COASales, @UserID, @RecordStatus` | Error `'Branch ID already exists!'`. INSERT mengembalikan ID `0` (bug sama dengan Company). Kolom `COAAR`, `FlagSystem`, `IsProfitSharing` tidak diisi. |

Validator PHP: `IDX_M_Company`, `IDX_M_Branch`, `IDX_M_LocationInventory`, `BranchID`, `BranchName` required. `BranchID` dipakai sebagai segmen nomor dokumen di SP transaksi (mis. `USP_CM_SalesInvoice_Approve`).

### 3.3 Department — `GN_M_Department` (4 baris)

`USP_GN_Department_List` (paging, `@DepartmentID`, `@DepartmentName`), `USP_GN_Department_Info(@IDX_M_Department)`, `USP_GN_Department_Save(@IDX_M_Department, @DepartmentID, @DepartmentName, @UserID, @RecordStatus)` → error `'Department ID already exists!'`. Controller: `General/DepartmentController`.

### 3.4 Project — `GN_M_Project` (1 baris)

Ada 4 SP GN tetapi **tidak dipakai**; `General/ProjectController` memanggil `USP_CM_Project_List`, `USP_CM_Project_Selected_List`, `USP_CM_Project_Info`, `USP_CM_Project_Save` yang **tidak ada di DB** → menu Project (`/gn-project`) dan tab Project di User rusak. Controller mengirim `IDX_M_Project, IDX_M_Company, IDX_M_Branch, ProjectID, ProjectName, ProjectDesc, ProjectAddress, FlagSystem, IsProfitSharing, UserID, RecordStatus`.

Logika SP GN yang ada (acuan recode):
- `USP_GN_Project_List` (paging, `@ProjectID`, `@ProjectName`, `@ProjectDesc`).
- `USP_GN_Project_Info(@IDX_M_Project)`.
- `USP_GN_Project_Create(@ProjectID, @ProjectName, @ProjectDesc, @UserID, @RecordStatus)` → error `'Project ID Already Exist!'`, `'Project Name Already Exist!'` (`LTRIM(RTRIM)` exact); insert `StartDate/EndDate = NULL`.
- `USP_GN_Project_Update(@IDX_M_Project, @ProjectID, @ProjectName, @ProjectDesc, @UserID, @RecordStatus)` → error `'Project ID/Name Cannot Blank!'`, `'Project Name Already Exists!'`, `'Project ID Already Exists!'`, dan **`'Master data cannot be changed! Already used in transaction!'` bila ada `PR_T_PurchaseOrder.IDX_M_Project = @IDX`** (satu-satunya master GN yang punya proteksi "sudah dipakai transaksi").

### 3.5 Bank — `GN_M_Bank` (2 baris)

Dipakai `General/BankController` (`gn-bank*`) **dan** `Finance/BankController` (`fm-bank*`), keduanya dengan kode simpan yang rusak (§1.9).
- `USP_GN_Bank_List` (paging, `@BankCode`, `@BankName`, `@BankAlias`) — tidak filter status.
- `USP_GN_Bank_Info(@IDX_M_Bank)`.
- `USP_GN_Bank_Save(@IDX_M_Bank, @BankCode, @BankName, @BankAlias, @UserID, @RecordStatus)` → error `'Bank ID already exists!'` (cek `BankCode`).

### 3.6 Country — `GN_M_Country` (26 baris)

`USP_GN_Country_List` (paging, `@CountryID`, `@CountryName`), `USP_GN_Country_Info`, `USP_GN_Country_Save(@IDX_M_Country, @CountryID, @CountryName, @UserID, @RecordStatus)` → error `'Country ID already exists!'` **dan** `'Country name already exists!'` (nama juga unik). Controller `General/CountryController` (permission FormID salah, §2.3).

### 3.7 Currency — `GN_M_Currency` (19 baris)

Controller `Finance/CurrencyController` (route di modul Finance; modul MC punya `MoneyChanger/CurrencyController` sendiri untuk kurs).
- `USP_GN_Currency_List` (paging, `@CurrencyName`, `@CountryName`) — join Country.
- `USP_GN_Currency_Info(@IDX_M_Currency)` — + CountryID/Name.
- `USP_GN_Currency_Save(@IDX_M_Currency, @IDX_M_Country, @CurrencyID, @CurrencyName, @Symbol, @Remarks, @Rounding DECIMAL(18,4), @Accuracy INT, @UserID, @RecordStatus)` → error `'Currency ID already exists!'`. **UPDATE tidak mengubah `IDX_M_Country`** (negara hanya bisa diset saat create). Controller: `Remarks=''`, `Rounding/Accuracy` dari input (koma dibuang), `RecordStatus` dari input.
- `Rounding` (kelipatan pembulatan) dan `Accuracy` (jumlah desimal) dipakai modul MC untuk pembulatan nominal valas [TIDAK PASTI detailnya; lihat dokumen MC].
- `GN_M_CurrencyRate` kosong — kurs harian ada di tabel modul MC.

### 3.8 DocumentType — `GN_M_DocumentType` (13 baris) & penomoran dokumen

Kolom: `DocumentTypeCategory`, `DocumentTypeID` (maks 5 karakter), `DocumentTypeDesc`, `TableReferenceHeader/Detail`, `InFlag`/`OutFlag` (arah kas/dokumen masuk/keluar), `ARAccount`/`APAccount` (COA default piutang/hutang).

- `USP_GN_DocumentType_List` (paging, `@DocumentTypeDesc`, `@DocumentTypeID`, `@DocumentTypeCategory`) + deskripsi COA AR/AP.
- `USP_GN_DocumentType_Info(@IDX_GN_M_DocumentType)`.
- `USP_GN_DocumentType_Update(@IDX_M_DocumentType, @DocumentTypeCategory, @DocumentTypeID VARCHAR(5), @DocumentTypeDesc, @InFlag, @OutFlag, @ARAccount, @APAccount, @UserID, @RecordStatus)` — **tanpa validasi apa pun** (tidak cek duplikat), tidak ada INSERT. **Tidak dipanggil**; controller memanggil `USP_GN_DocumentType_Save` yang tidak ada → simpan DocumentType rusak.

**Penomoran dokumen:** tidak ada tabel counter. SP transaksi (31 SP menyentuh `GN_M_DocumentType`, mis. `USP_CM_SalesInvoice_Approve`, `USP_CM_FinancialReceiveHeader_Create`) mengambil `RTRIM(DocumentTypeID)` sebagai prefix, menambah `BranchID`, tahun/bulan, lalu nomor urut = `MAX(RIGHT(No,4)) + 1` dari tabel transaksi untuk tahun berjalan (contoh `@_InvoiceNo = DocTypeID + '-' + … + RIGHT('00000'+N,4)`). Ini rawan duplikat saat konkuren; detail format per dokumen dibahas di dokumen modul Finance/MC. Recode: buat service `DocumentNumberGenerator` dengan tabel sequence + lock (`UPDLOCK, HOLDLOCK`) atau `SEQUENCE` SQL Server.

### 3.9 Partner (Business Partner / Konsumen) — `GN_M_Partner` (2.609 baris)

Dipakai General (`gn-partner*`) dan MoneyChanger (`MoneyChanger/PartnerController`, `mc-partner*`). Partner mencakup customer, supplier, member, perusahaan; untuk money changer ini adalah data **konsumen KYC** (NIK, tipe identitas, tempat/tanggal lahir) yang dipakai screening DTTOT dan laporan LTKM.

**`USP_GN_Partner_List`** — paging, `@PartnerID`, `@PartnerName`, `@BarcodeMember`, `@SingleIdentityNumber`, `@PartnerType` (`''`/`'A'` semua; `'C'` = `IsCustomer='Y' OR IsMember='Y'`; `'S'` = `IsSupplier='Y'`), `@Street` (LIKE pada alamat **default** `IsDefault='Y'`). Tidak filter RecordStatus. Output termasuk `ActiveDesc` (dari `ActiveStatus`) dan `StatusDesc` (dari `RecordStatus`).

**`USP_GN_Partner_Info(@IDX_M_Partner)`** — semua kolom + `IDTypeName` (alias `GN_M_IDType`), deskripsi COA AR/AP, nama pembuat/pengubah.

**`USP_GN_Partner_Save`** — urutan parameter (wajib dijaga selama masih positional):
`@IDX_M_Partner, @PartnerID, @BarcodeMember, @Prefix, @PartnerName, @PartnerAlias, @Gender, @SingleIdentityNumber, @TaxIdentityNumber, @DateOfBirth VARCHAR(10), @PlaceOfBirth, @Email, @Phone1, @Phone2, @FaxNo, @MobilePhone, @Remarks, @IsSupplier, @IsCustomer, @IsCompany, @IsMember, @IsDTTOT, @StartDate, @EndDate, @ARAccount, @APAccount, @ActiveStatus, @CreditLimit DECIMAL(22,2), @DiscountMember DECIMAL(5,2), @UserID, @RecordStatus, @IDX_M_IDType = NULL`

Aturan:
1. `@IDX_M_IDType` NULL/0 → diisi `IDX_M_IDType` dengan `Alias='KTP'` (default KTP).
2. Error `'Partner name is required!'` bila nama kosong.
3. Error `'Partner ID Already Exists!'` bila `@PartnerID` tidak kosong dan sudah dipakai partner lain (case-insensitive).
4. **Duplikat NIK:** bila `@SingleIdentityNumber` (trim) panjang ≥ 8 dan hanya angka, dan ada partner lain `RecordStatus='A'` dengan NIK sama → error `'NIK <nik> sudah terdaftar atas nama <PartnerName>!'`. NIK berhuruf (paspor) tidak dicek.
5. Error `'Partner status is required!'` bila `@ActiveStatus` kosong atau `'0'`.
6. **INSERT** — `PartnerID` **dibuat otomatis** (input `@PartnerID` diabaikan): format `BP-YY#####` (mis. `BP-2600123`). Nomor terakhir = `CONVERT(INT, RIGHT(PartnerID, 4))` dari partner dengan `SUBSTRING(PartnerID,4,2) = YY` urut `PartnerID DESC`, lalu `+1` dan di-pad 5 digit. **Bug:** dibaca 4 digit, ditulis 5 digit → setelah nomor 9999 dalam setahun, urutan reset ke 0001 dan bertabrakan (tidak ada unique index). Tidak ada lock → race condition saat dua kasir menyimpan bersamaan.
7. **UPDATE** — menimpa semua kolom termasuk `PartnerID` (dari input) dan `IsDTTOT` (karena itu controller membaca dulu flag lama via `tanda_dttot()` agar hasil screening tidak hilang).
8. Return `('success', IDX_M_Partner, 'Data Sudah Disimpan')`.

Validator PHP `General/PartnerController::save`: `Phone1`, `PartnerName`, `SingleIdentityNumber`, `Email` (`email:rfc,dns` → lookup DNS), `MobilePhone` required. `StartDate` juga dipakai untuk `EndDate` (bug copy-paste). `DiscountMember='0.00'` hard-coded.

**Input cepat konsumen** (`POST /gn-partner-quick-save`, dari form transaksi valas) — `PartnerController::quick_save`, logika yang **sudah di PHP** dan memakai binding:
1. Wajib: `PartnerName` ("Nama konsumen belum diisi!"), `SingleIdentityNumber` ("NIK belum diisi!"), `Street` ("Alamat belum diisi!"), `MobilePhone` ("No handphone belum diisi!").
2. Validasi nomor identitas: bila tipe identitas `KTP` → harus 16 digit angka (`'NIK harus 16 digit angka. Yang diisi N karakter. Bila memakai paspor atau KITAS, ganti dulu jenis identitasnya.'`); tipe lain → `^[A-Za-z0-9]{5,}$`; tanpa tipe → angka murni harus 16 digit, campuran huruf → alfanumerik min 5. Tipe tidak dikenal → `'Jenis identitas tidak dikenal.'`.
3. `DateOfBirth` opsional, format `Y-m-d` valid dan tidak di masa depan.
4. Bila NIK sudah ada (partner aktif) → **tidak membuat baru**, mengembalikan partner yang ada (`sudah_ada: true`).
5. `EXEC USP_GN_Partner_Save` dengan named params: `IsCustomer='Y'`, `IsDTTOT='N'`, `ActiveStatus='A'`, **`ARAccount=5`, `APAccount=12` (IDX COA hard-coded)**, `Remarks='Input cepat transaksi valas'`.
6. `EXEC USP_GN_PartnerQuickAddress_Create` (gagal alamat tidak membatalkan partner; user diberi peringatan).

**Alamat** — `GN_M_PartnerAddress` (2.275 baris):
- `USP_GN_PartnerAddress_List(@IDX_M_Partner)` — alamat aktif + `CityDescription = Province + ', ' + Info + ' ' + City + ', ' + District + ', ' + Subdistrict` dari `GN_M_PostalCode`, urut `IDX_M_AddressType`.
- `USP_GN_PartnerAddress_Info(@IDX_M_PartnerAddress)` — tidak dipakai (controller memakai `USP_CM_PartnerAddress_Info`).
- Create/Update/Delete memakai SP modul CM: `USP_CM_PartnerAddress_Create(@IDX_M_Partner, @IDX_M_AddressType, @IDX_M_PostalCode, @Street, @Zip, @Notes, @IsDefault, @UserID, @RecordStatus)` → error `'Street information is required!'`, `'Invalid postal code!'` (kode pos wajib), `'Address type is invalid !'`; bila `IsDefault='Y'` alamat lain partner itu di-set `'N'` (hanya satu default). `USP_CM_PartnerAddress_Delete` → `RecordStatus='I'`.
- `USP_GN_PartnerQuickAddress_Create(@IDX_M_Partner, @Street, @Zip='', @UserID)` → error `'Konsumen belum diisi!'`, `'Alamat belum diisi!'`; `IDX_M_PostalCode` = `TOP 1` kode pos aktif dengan `Zip` sama (NULL bila tidak cocok); `IsDefault='Y'` hanya bila partner belum punya alamat (termasuk alamat nonaktif); `IDX_M_AddressType = 1` (hard-coded, diasumsikan "Alamat KTP"); `Notes='Input cepat transaksi valas'`. Return ID = `IDX_M_PartnerAddress`.

**Rekening bank partner** — `GN_M_PartnerBank` (7 baris), controller `General/PartnerBankController`, `General/VendorBankController`, `MoneyChanger/PartnerBankController`:
- `USP_GN_PartnerBank_List(@IDX_M_Partner)` — **tidak memfilter RecordStatus** (rekening yang "dihapus" tetap tampil).
- `USP_GN_PartnerBank_Info(@IDX_M_PartnerBank)`.
- `USP_GN_PartnerBank_Save(@IDX_M_PartnerBank, @IDX_M_Partner, @IDX_M_Bank, @IsDefault, @BankAccountNo VARCHAR(20), @BankAccountName, @BankAccountBranch, @Remarks, @UserID, @RecordStatus)` → error `'Bank Account No is required!'`. Tidak ada aturan satu default dan tidak ada cek duplikat nomor rekening. Return ID = `IDX_M_Partner` (bukan ID rekening).
- `USP_GN_PartnerBank_Delete(@IDX_M_PartnerBank, @IDX_M_Partner, @UserID)` → `RecordStatus='I'`, pesan `'Data Sudah Dihapus'`.

Kolom `BankName/BranchName/BranchCode/AccountNumber/AccountName` langsung di `GN_M_Partner` adalah desain lama (rekening tunggal); `GN_M_PartnerAccountHistory` kosong.

**Merge partner (data fix 15 Agustus 2026)** — Tabel `GN_M_Partner_MergeBackup_20260815` (4 baris: `IDX_M_Partner` yang dibuang, `IDX_Dipertahankan` = partner yang dipertahankan, PartnerID, Nama, NIK, HP, `DBackup`) dan `GN_M_PartnerAddress_MergeBackup_20260815` (4 baris, kolom `Tindakan` = aksi yang dilakukan pada alamat). Tidak ada SP maupun kode PHP yang membaca/menulis tabel ini → hasil **skrip manual satu kali** untuk menggabungkan konsumen dobel (NIK sama) sebelum aturan duplikat NIK diberlakukan. Bila recode butuh fitur merge, tabel ini adalah satu-satunya jejak; pindahkan relasi transaksi (`IDX_M_Partner` di semua tabel transaksi) ke ID yang dipertahankan dalam satu transaksi DB, lalu nonaktifkan duplikat [TIDAK PASTI: daftar tabel yang di-remap tidak tercatat].

### 3.10 DTTOT (Daftar Terduga Teroris dan Organisasi Teroris) — `GN_M_DTTOT` (531 baris)

Kewajiban APU-PPT untuk money changer. Controller `MoneyChanger/DTTOTController`, routes `mc-dttot*` (tanpa cek permission).

**Upload (replace total):**
1. `GET /mc-dttot/upload` → form.
2. `POST /mc-dttot/preview` → `Excel::import(new DTTOTImport)` tanpa heading row. Kolom tetap: 0 Nama, 1 Deskripsi, 2 Terduga (Orang/Korporasi), 3 Kode Densus, 4 Tempat Lahir, 5 Tanggal Lahir, 6 WN/Asal Negara, 7 Alamat. Baris kosong atau berisi "nama" dilewati. Error per baris: `'Kolom Terduga (Orang/Korporasi) kosong'`, `'Kode Densus kosong'`. Tanggal lahir: serial Excel (> 25569) → `d/m/Y`, selain itu teks apa adanya (bisa "01/07/1974 atau 01/01/1973"). Baris valid disimpan di **session**.
3. `POST /mc-dttot/save` → `USP_GN_DTTOT_Clear` (`DELETE FROM GN_M_DTTOT`, tanpa syarat) lalu loop `USP_GN_DTTOT_Save(@FullName, @Description, @SuspectType, @DensusCode, @PlaceOfBirth, @DateOfBirth, @Nationality, @Address, @FileName, @UserID)` per baris (insert `RecordStatus='A'`). **Tidak dalam satu transaksi**: bila gagal di tengah, daftar DTTOT tinggal sebagian (risiko kepatuhan). Hasil (`success`/`failed`/pesan `'Baris N (Nama) gagal disimpan.'`) disimpan di session.
- `USP_GN_DTTOT_List` (paging, `@FullName`, `@DensusCode`) untuk tampilan.

**Screening (`USP_GN_DTTOT_Screening`, tanpa parameter):**
1. Untuk tiap DTTOT aktif, `FullName` di-UPPER lalu dipecah per kata pemisah `' ALIAS '` menjadi segmen alias (cursor). Contoh: `"ABU BAKAR ALIAS ABU BAKAR BA'ASYIR"` → `ABU BAKAR`, `ABU BAKAR BA'ASYIR`.
2. Dicocokkan dengan `GN_M_Partner` aktif (`UPPER(RTRIM(PartnerName))`):
   - `EXACT` bila nama = alias;
   - `PARTIAL` bila (panjang nama partner ≥ 5 dan alias mengandung nama partner) atau (panjang alias ≥ 5 dan nama partner mengandung alias).
3. Satu baris per pasangan (partner, DTTOT), EXACT diprioritaskan; urut EXACT dulu, lalu nama, lalu kode Densus. Output: `IDX_M_Partner, PartnerID, PartnerName, SingleIdentityNumber, IsDTTOT (Y/N), IDX_M_DTTOT, DTTOTName, DensusCode, SuspectType, AliasName, MatchType`.
4. Controller juga menampilkan partner yang sudah `IsDTTOT='Y'` tetapi tidak muncul lagi di hasil (kandidat dicabut setelah renewal).
5. `POST /mc-dttot/screening-save`: `mark[]` → `USP_GN_Partner_SetDTTOT(@IDX_M_Partner, 'Y', @UserID)`; `matched[]` yang tidak dicentang → `'N'`; `unflag[]` → `'N'`. SP hanya meng-update `IsDTTOT` (`'Y'` atau selain itu `'N'`) dan audit.
- Pencocokan hanya berdasarkan nama (tidak memakai tanggal lahir/NIK); hasil PARTIAL wajib diverifikasi manual (teks di UI). Flag `IsDTTOT` dibaca oleh `USP_MC_LTKM_Preview/Save/List` (laporan transaksi mencurigakan). **[TIDAK PASTI]** apakah transaksi jual/beli diblokir untuk partner `IsDTTOT='Y'`; tidak ditemukan di SP GN, cek dokumen modul MC.
- Performa: cursor + `LIKE '%x%'` dua arah = O(partner × alias); untuk recode lakukan normalisasi nama (upper, hapus tanda baca) dan pencocokan di PHP atau full-text.

### 3.11 Attachment (lampiran transaksi) — `GN_T_Attachment` (0 baris)

Controller `General/AttachmentController`, routes `gn-attachment/{list,upload,view/{id},download/{id},delete}`. Sudah dirancang aman:
- Jenis sumber yang diizinkan (`SOURCES`): `FP` (Financial Payment; read `FM-FP-R`, write `FM-FP-U`) dan `JE` (Journal Entry; tanpa cek form → semua user login).
- Upload: `SourceID` integer ≥ 1, `Category` ∈ {`Bukti Transfer`, `Invoice`, `Lainnya`}, `Description` ≤ 500, `files[]` wajib, `mimes:pdf,jpg,jpeg,png`, maks 10.240 KB per file. Pesan: `'Kategori lampiran belum dipilih!'`, `'File belum dipilih!'`, `'File harus berformat PDF, JPG atau PNG.'`, `'Ukuran file maksimal 10 MB.'`.
- Nama simpan acak: `YmdHis_<12 hex>.<ext>` di `storage/app/attachment/<SourceType>/<SourceID>/` (di luar web root). Nama asli hanya di DB.
- `USP_GN_Attachment_Save(@SourceType, @SourceID, @Category, @FileName, @StoredName, @FileSize, @Description, @UserID)` → error `'Transaksi tidak ditemukan.'` bila bukan (`FP` & `CM_T_FinancialPaymentHeader` aktif) atau (`JE` & `GL_T_JournalHeader` aktif); sukses `'Lampiran <FileName> berhasil diupload.'`, ID = `SCOPE_IDENTITY()`. Controller menghapus file fisik bila SP error. File dipindah **sebelum** SP memvalidasi; tiap file diproses sendiri (tidak atomik untuk multi-file).
- `USP_GN_Attachment_List(@SourceType, @SourceID)` (aktif, + nama pembuat), `USP_GN_Attachment_Info(@IDX_T_Attachment)` (aktif).
- View/download hanya lewat ID: `find(id)` → cek akses `read` → path dibangun dari `SourceType/SourceID` DB + `basename(StoredName)` → `response()->file` (inline) / `download`.
- `USP_GN_Attachment_Delete(@IDX_T_Attachment, @UserID)` → soft delete `RecordStatus='D'`; error `'Lampiran tidak ditemukan atau sudah dihapus.'`, sukses `'Lampiran dihapus.'`. File fisik **tidak** dihapus.

### 3.12 Kode pos & tabel X_

- `GN_M_PostalCode` (82.712 baris) — master kode pos Indonesia: `Province`, `Info` (Kota/Kabupaten), `City`, `District` (kecamatan), `Subdistrict` (kelurahan/desa), `Zip`. PK tidak IDENTITY (diisi dari impor). Pencarian: `POST /search-postal-code` (`General/PostalCodeController`) → `SELECT TOP 200 … WHERE Subdistrict LIKE '%q%' OR City LIKE '%q%'` (SQL injection; respons untuk Select2 dengan `text = Province, Info City, District, Subdistrict, Zip`).
- `X_PostalCode` (65.535 baris — tepat 2^16−1, tanda impor Excel yang terpotong) dan `X_PostalCodeAll` (17.177 baris): tabel staging impor (tipe `float`/`nvarchar`, tanpa PK), **tidak dipakai** SP/kode. Kandidat dihapus setelah dipastikan `GN_M_PostalCode` lengkap.

### 3.13 Lookup kecil (via `DropdownController`, SQL langsung)

`GN_M_Gender` (2), `GN_M_IDType` (5: KTP, SIM, Paspor, KITAS, … — `id_type_default()` = KTP), `GN_M_AddressType` (3), `GN_M_Bank`, `GN_M_Country`, `GN_M_Currency`, `GN_M_Department`, `GN_M_DocumentType` (per kategori), `GN_M_PaymentTerms`/`ShippingTerms`/`PaymentType` (0 baris, dropdown kosong), `GN_M_SalesPerson` (0), `SM_M_Application`, `SM_M_Module`. Tidak ada SP CRUD untuk tabel-tabel lookup ini; isinya dikelola langsung di DB.

---

## 4. Tabel GN_*, SM_*, X_*

Legenda: **∅** = kosong; **TT** = tidak dipakai SP maupun PHP; jumlah SP = jumlah SP yang mereferensikan tabel (dari `deps.txt`).

### 4.1 GN_*

| Tabel | Baris | Tujuan | Kolom kunci / relasi implisit | Pemakaian |
|---|---|---|---|---|
| GN_M_AddressType | 3 | Jenis alamat (KTP, domisili, kantor) | `IDX_M_AddressType` | 3 SP, dropdown |
| GN_M_Bank | 2 | Master bank | `BankCode` (unik via SP) | 5 SP |
| GN_M_BankCardPattern | 0 ∅ | Pola nomor kartu | → BankCardType | 1 SP backup, praktis TT |
| GN_M_BankCardType | 0 ∅ | Jenis kartu bank/EDC | → Bank, BankMerchant | 1 SP backup |
| GN_M_BankMerchant | 0 ∅ | Merchant EDC | | TT |
| GN_M_Branch | 2 | Cabang | `BranchID`; → Company, `IDX_M_LocationInventory` → IN_M_LocationInventory, `COASales`/`COAAR` → GL_M_COA | 76 SP (inti) |
| GN_M_BusinessType | 0 ∅ | Jenis usaha | | TT |
| GN_M_Company | 1 | Perusahaan | `CompanyID`; → Currency, `RetainedEarningAccount`/`CurrentEarningAccount` → COA | 36 SP |
| GN_M_Country | 26 | Negara | `CountryID` | 4 SP |
| GN_M_Currency | 19 | Mata uang/valas | `CurrencyID`; → Country; `Rounding`, `Accuracy` | 20 SP |
| GN_M_CurrencyRate | 0 ∅ | Kurs harian (desain lama) | → Currency | TT (kurs ada di modul MC) |
| GN_M_Department | 4 | Departemen | `DepartmentID` | 4 SP |
| GN_M_DocumentType | 13 | Jenis dokumen + prefix nomor + COA AR/AP default | `DocumentTypeID` (≤5) | 31 SP |
| GN_M_DTTOT | 531 | Daftar DTTOT resmi | `DensusCode`, `FullName` (dengan " ALIAS ") | 3 SP |
| GN_M_Gender | 2 | Jenis kelamin | | dropdown PHP |
| GN_M_Global | 0 ∅ | Parameter global generik | `CodeGroup/CodeGlobal` | TT |
| GN_M_IDType | 5 | Jenis identitas | `Alias` ('KTP', …) | FK dari Partner, 2 SP |
| GN_M_Membership / GN_M_MemberType | 0 ∅ | Keanggotaan | → Partner | TT |
| GN_M_Menu | 0 ∅ | Menu dinamis (desain lama) | | TT |
| GN_M_Partner | 2.609 | Konsumen/supplier/member | `PartnerID` (BP-YY#####), `SingleIdentityNumber` (NIK), `IsDTTOT`, `ARAccount`/`APAccount` → COA, → IDType | 67 SP (inti) |
| GN_M_Partner_MergeBackup_20260815 | 4 | Backup merge partner dobel | `IDX_M_Partner` → `IDX_Dipertahankan` | TT (arsip) |
| GN_M_PartnerAccountHistory | 0 ∅ | Histori rekening | → Partner | TT |
| GN_M_PartnerAddress | 2.275 | Alamat partner | → Partner, AddressType, PostalCode; `IsDefault` | 16 SP |
| GN_M_PartnerAddress_MergeBackup_20260815 | 4 | Backup alamat saat merge | `Tindakan` | TT (arsip) |
| GN_M_PartnerBank | 7 | Rekening bank partner | → Partner, Bank | 4 SP |
| GN_M_PartnerContact / PartnerImage / PartnerTitle / PartnerType | 0 ∅ | Kontak, foto, gelar, tipe | → Partner | TT (foto KTP memakai mekanisme lain `mc-partner-ktp`) |
| GN_M_PaymentTerms / PaymentType / ShippingTerms / PurchaseType | 0 ∅ | Termin, tipe bayar | | dropdown kosong / TT |
| GN_M_PostalCode | 82.712 | Kode pos | `Zip`, wilayah | 7 SP + PHP |
| GN_M_Project | 1 | Project | `ProjectID`; → Company, Branch | 28 SP |
| GN_M_Religion | 0 ∅ | Agama | | TT |
| GN_M_SalesPerson / SalesTeam | 0 ∅ | Sales | → User | 3 SP laporan |
| GN_M_TransactionType | 0 ∅ | Jenis transaksi | | TT |
| GN_M_Voucher / VoucherLine | 0 ∅ | Voucher diskon | | TT |
| GN_T_Attachment | 0 ∅ (fitur baru) | Lampiran transaksi | `SourceType`+`SourceID` (polimorfik: FP → CM_T_FinancialPaymentHeader, JE → GL_T_JournalHeader) | 4 SP |

### 4.2 SM_*

| Tabel | Baris | Tujuan | Kolom kunci / relasi | Pemakaian |
|---|---|---|---|---|
| SM_M_Application | 2 | Aplikasi/portal | `ApplicationID` | 4 SP |
| SM_M_Module | 1 | Modul | → Application | 1 SP |
| SM_M_Form | 141 | Daftar form/hak akses | `FormID` (unik via SP), → Application, Module; `ShowInSidebar`, `IconClass*` | 12 SP + check_permission |
| SM_M_Group | 6 | Role/group | `GroupID` | 10 SP |
| SM_M_GroupForm | 235 | Group ↔ Form | → Group, Form (hard delete) | 8 SP |
| SM_M_User | 17 | User aplikasi | `LoginID`, `Password2` (MD5 upper hex), `Email`, `IsLocked`/`FailedLoginAttemps`/`LastLogin` (tidak dipakai) | 41 SP (audit join `UCreate`→`LoginID`) |
| SM_M_UserGroup | 19 | User ↔ Group | soft delete `RecordStatus` (tidak dihormati check_permission) | 5 SP |
| SM_M_UserBranch | 19 | User ↔ Branch (scoping) | soft delete | 5 SP + dropdown |
| SM_M_UserProject | 0 ∅ | User ↔ Project | | 3 SP |
| SM_M_UserDepartment | 0 ∅ | User ↔ Department | | 1 SP (list saja; tidak ada SP tambah) |
| SM_M_UserCompany | 0 ∅ | User ↔ Company | | TT |
| SM_M_Position / RoleAction / RolePosition, SM_T_RolePosition | 0 ∅ | RBAC berbasis posisi (rencana) | → GN_M_Menu | TT |
| SM_T_CustomerResetPassword | 0 ∅ | Token lupa password | `ResetPasswordKey` (MD5) | 3 SP tidak terpakai |
| SM_T_Session / SM_T_SessionHistory | 0 ∅ | Sesi DB (desain lama) | | TT (sesi Laravel file) |

### 4.3 X_*

| Tabel | Baris | Catatan |
|---|---|---|
| X_PostalCode | 65.535 | Staging impor kode pos (terpotong batas Excel lama). TT. |
| X_PostalCodeAll | 17.177 | Staging impor kode pos. TT. |

Relasi audit implisit di hampir semua tabel: `UCreate`/`UModified` (string LoginID) → `SM_M_User.LoginID` (join untuk "CreateByName"/"ModifiedByName"). Tipe `IDX_*` tidak konsisten (`int` di Company/Country/Currency, `bigint` di tempat lain; beberapa parameter SP memakai `SMALLINT`, mis. `USP_SM_Group_Update.@IDX_M_Group`, `USP_SM_Form_Update.@IDX_M_Form`, `USP_SM_User_Create.@IDX_M_Gender`).

---

## 5. SP tidak terpakai & SP yang dipanggil kode tetapi tidak ada

### 5.1 SP GN/SM di DB yang tidak dipanggil kode (15)

| SP | Status / catatan |
|---|---|
| `USP_GN_DocumentType_Update` | Seharusnya dipakai controller (yang memanggil `_Save` yang hilang). |
| `USP_GN_PartnerAddress_Info` | Digantikan `USP_CM_PartnerAddress_Info`. |
| `USP_GN_Project_Create`, `USP_GN_Project_Info`, `USP_GN_Project_List`, `USP_GN_Project_Update` | Controller memanggil `USP_CM_Project_*` (tidak ada). |
| `USP_SM_CheckUserForm` | Duplikat `check_permission` versi SP. |
| `USP_SM_Form_CheckList_ByUserID` | Isinya identik dengan `_ByGroupID` (parameter `@GroupID`), tidak dipakai. |
| `USP_SM_Form_Create`, `USP_SM_Form_Update` | Versi lama; digantikan `USP_SM_Form_Save`. |
| `USP_SM_FormByGroup_List` | Lama. |
| `USP_SM_GroupByUser_List` | Lama. |
| `USP_SM_User_CheckResetPassword`, `USP_SM_User_SaveResetPassword`, `USP_SM_User_SendResetPassword` | Fitur lupa password nonaktif. |

Catatan: dua SP lain juga **praktis tidak terpakai** walau muncul di pemetaan kode, karena hanya ada di baris komentar: `USP_SM_ApplicationByUser_List` (komentar di `MyController::__construct`) dan `USP_SM_Form_CheckList_ByGroupID` (komentar di `GroupUserController` baris 205). Jadi total SP GN/SM yang benar-benar tidak dieksekusi = 17.

### 5.2 SP dalam cakupan yang dipanggil kode tetapi tidak ada di DB

| SP | Pemanggil | Dampak |
|---|---|---|
| `USP_GN_DocumentType_Save` | `General/DocumentTypeController::save` | Simpan DocumentType error. |
| `USP_CM_Project_List`, `USP_CM_Project_Selected_List`, `USP_CM_Project_Info`, `USP_CM_Project_Save` | `General/ProjectController` | Menu Project & picker project user rusak. |
| `USP_SM_User_ChangePassword` | `UserManagement/UserController::save_change_password` | Ganti password error. |
| `USP_IN_LocationInventory_List` | `UserManagement/FormController` | Hanya di komentar (tidak berdampak). |

### 5.3 Daftar umum (di luar modul GN/SM) — kemungkinan kode legacy/dead

| Kelompok SP (tidak ada di DB) | Controller pemanggil | Catatan |
|---|---|---|
| `USP_CF_Loan_*` (Save, Info, List, Approve, Approve_Journal_Manual, Disbursment, Disbursment_Journal_Manual, Duplicate, Journal_List, OtherExpense, Payment_List, PenaltyPayment_Save, Reverse, Schedule_List, Upload_List, Upload_Save, Void), `USP_CF_LoanDetail_List`, `USP_CF_LoanTermination_Save`, `USP_CF_FinancialReceive_Save`, `usp_GenerateAmortizationFlatRate`, `usp_RptAmortization` | `Loan/LoanController` (route `cf-loan*` di `routes/web/loan.php`) | Seluruh modul Loan tidak punya SP → mati. Helper `PMT`/`rate`/`get_flat_installment` ikut mati. |
| `USP_SL_Agent_Info` | `Loan/LoanController` | Hanya di komentar. |
| `USP_QP_UploadSummary_Member`, `USP_QP_UploadSummary_Sales` | `Finance/SalesInvoiceController` | Upload summary member/sales (warisan sistem lain); terkait import `XMemberSummaryImport`/`XSalesSummaryImport`. |
| `usp_T_ReceiptMembershipDetail_Delete/_Info/_InfoOther/_Save` | `Finance/FinancialPaymentControllerDetail`, `Finance/PurchaseInvoiceJournalController` | Sisa sistem membership. |
| `USP_PR_PurchaseOrder_Info`, `USP_PR_PurchaseOrderDetail_List` | `Finance/PurchaseInvoiceController` | Modul Procurement versi lama. |
| `USP_CM_Tax_List` | `Finance/SalesInvoiceController` | Hanya di komentar. |
| `USP_GL_COA_Save` | `Accounting/JournalItemController` | Dibahas dokumen Accounting. |
| `USP_MC_NotaScanDetail_Delete`, `USP_MC_OpenCloseDaily_Calculate`, `USP_MC_OpenCloseDailyDetail_Delete`, `USP_MC_OpenCloseDailyDetailDetail_List`, `USP_MC_OpenCloseDailyItem_List`, `USP_MC_PurchaseOrder_Duplicate`, `USP_MC_PurchaseOrderDetailDetail_List`, `USP_MC_PurchaseOrderItem_List`, `USP_MC_PurchaseOrderPayment_Save`, `USP_MC_PurchaseOrderSearchByValue_List`, `USP_MC_SalesOrder_Duplicate`, `USP_MC_SalesOrderDetailDetail_List`, `USP_MC_SalesOrderItem_List`, `USP_MC_SalesOrderPayment_Save`, `USP_MC_SalesOrderSearchByValue_List` | Controller `MoneyChanger/*` terkait (NotaScan, OpenClose(Detail), PurchaseOrder(Detail/Payment), SalesOrder(Detail/Payment)) | Dibahas di dokumen MC; kemungkinan aksi/tab lama yang tidak lagi ditampilkan. |
| `USP_MC_R_Dashboard_SalesPartner` | `HomeController` | Hanya di komentar. |

---

## 6. Catatan recode

### 6.1 Risiko utama (urut prioritas)

1. **SQL injection pra-login** di `LoginController::validate_user` — perbaiki segera, bahkan sebelum recode (ganti ke `DB::select('EXEC USP_SM_CheckLoginValidation ?, ?', [$u, $p])`).
2. **SQL injection umum** lewat `exec_sp`/`exec_sql` dan dynamic SQL di SP `*_List`/`*_Add*`; `ORDER BY` dari klien.
3. **Pencabutan akses tidak efektif**: `check_permission` tidak memfilter `RecordStatus` (UserGroup, Group, Form, User). User nonaktif masih bisa login dan memakai hak aksesnya.
4. **Update Group menghapus semua form access** (`USP_SM_Group_Update` + controller mengirim `FormCheck=''`).
5. **Endpoint simpan tanpa cek permission** (hampir semua `save`, `reset_password`, DTTOT, master GN).
6. **Password MD5 tanpa salt**, reset password = LoginID, `User_Info` mengirim hash ke view, tidak ada lockout/regenerate session.
7. **Penomoran** `PartnerID` (overflow 9999 & race) dan nomor dokumen berbasis `MAX()+1`.
8. **DTTOT replace tidak atomik** (Clear lalu insert satu per satu).
9. **Bug fungsi yang rusak sekarang**: Bank save, DocumentType save, Project (semua), Change Password, Company `CompanyID CHAR(1)` & `Logo=Country`, ID 0 pada insert Company/Branch, join salah di `USP_GN_Branch_Info`.
10. **Blok CATCH SP** yang justru melempar error baru dan bisa COMMIT parsial.

### 6.2 Saran arsitektur Laravel

- **Data access**: Query Builder (`DB::table()`) dengan binding untuk master GN/SM (logikanya sederhana: CRUD + cek unik). Untuk SP yang tetap dipertahankan sementara, buat satu helper `SpRunner::call('USP_X', ['Param' => $v, ...])` yang membangun `EXEC USP_X @Param = ?, ...` dengan binding **named** (bukan positional). Pola ini sudah dipakai `PartnerController::quick_save`.
- **Repository + Service per agregat**: `UserRepository`, `GroupRepository`, `FormRepository`, `PartnerRepository`, `BranchRepository`…; `PartnerService` (generate PartnerID dalam transaksi dengan `UPDLOCK`, cek NIK, alamat default), `DttotService` (import dalam `DB::transaction`, screening), `DocumentNumberService` (tabel sequence per DocumentType/Branch/periode).
- **Auth**: guard `session` Laravel dengan `UserProvider` kustom di `SM_M_User`; `Hash::check` dengan fallback MD5 lama + rehash; `session()->regenerate()` saat login; throttle login (`ThrottleRequests`); isi `LastLogin`, `FailedLoginAttemps`, `IsLocked`; tolak `RecordStatus <> 'A'`.
- **Otorisasi**: middleware `permission:FORM-ID` (atau `Gate::define` dinamis dari `SM_M_Form`) yang dipasang di **route group**, termasuk endpoint POST. Query permission sekali per request dan di-cache per user (invalidasi saat GroupForm/UserGroup berubah), dengan filter `RecordStatus='A'` di User, UserGroup, Group, GroupForm, Form. Ganti `$route_exception` dengan pemisahan route group `guest` vs `auth`.
- **Validasi**: Form Request per entitas (pindahkan cek "required"/format dari SP: NIK 16 digit untuk KTP, email, tanggal lahir, kode unik dengan `Rule::unique()->ignore($id)`), pesan Bahasa Indonesia mengikuti pesan lama.
- **Respons**: kembalikan `response()->json(['flag','message','id','url'])` konsisten, escape pesan di view; hindari `echo`.
- **DataTables**: gunakan `yajra/laravel-datatables` atau builder sendiri dengan whitelist kolom sort, `like` binding, `skip/take`, dua count (total & filtered).
- **Constraint DB** (setelah data dibersihkan): unique index `SM_M_User.LoginID`, `SM_M_Form.FormID`, `SM_M_Group.GroupID`, `SM_M_GroupForm(IDX_M_Group, IDX_M_Form)`, `SM_M_UserGroup/UserBranch/UserProject (IDX_M_User, IDX_M_*)`, `GN_M_Partner.PartnerID`, `GN_M_Branch.BranchID`, `GN_M_Company.CompanyID`, `GN_M_Currency.CurrencyID`, `GN_M_Bank.BankCode`, `GN_M_Country.CountryID`, filtered unique NIK (`WHERE RecordStatus='A' AND SingleIdentityNumber <> ''`) [cek duplikat lama dulu]. Perubahan DDL harus dikoordinasikan karena AVKDB adalah DB produksi.
- **Bersih-bersih**: hapus/arsipkan modul Loan, SP tak terpakai (§5.1), tabel ∅/TT (setelah konfirmasi), `X_PostalCode*`, helper CodeIgniter (`calculate_rate`), `validate_return`, `getColumnName`.

### 6.3 Test case penting

**Infrastruktur**
- Input dengan tanda kutip (`Ma'ruf`, `O'Neil`) tersimpan utuh di Partner/Alamat/DTTOT.
- Nilai numerik-seperti-string (`LoginID='0012345'`, NIK diawali 0, NPWP) tersimpan tanpa kehilangan nol depan.
- DataTables: sort hanya pada kolom whitelist; parameter `columns[0][data]='IDX_M_User; DROP TABLE x'` ditolak; paging halaman 1/2/terakhir; `length=-1`.
- Pesan error validasi muncul (bukan HTTP 500) saat terjadi error DB.

**Auth & otorisasi**
- Login sukses → session berisi `user_id` (LoginID dari DB), `user_index`, `user_name`; session ID berganti.
- Login gagal: user tidak ada, password salah, user `RecordStatus='I'`, user terkunci; payload injeksi di UserID tidak mengeksekusi SQL.
- Hash MD5 lama tetap bisa login lalu di-rehash.
- User tanpa form `SM-USER-R` tidak bisa GET list **dan** tidak bisa POST `/sm-user/save`.
- Hapus (nonaktifkan) group dari user → akses form group itu langsung hilang.
- Edit nama group tidak menghapus daftar form-nya.
- AddGroup/AddBranch/AddForm: duplikat ditolak dengan pesan, id nonaktif tidak ditambahkan, satu duplikat tidak menggagalkan seluruh batch (atau sesuai keputusan bisnis — dokumentasikan).
- Reset password: hanya admin dengan permission; password baru tidak sama dengan LoginID (atau paksa ganti saat login berikutnya).
- Ganti password: password lama salah ditolak; minimal 5 karakter; konfirmasi cocok.

**Master GN**
- Company/Branch/Department/Country/Currency/Bank/Form/Group: kode duplikat ditolak (case-insensitive sesuai SP), insert mengembalikan ID baru (bukan 0), CompanyID lebih dari 1 karakter tersimpan.
- Country: nama duplikat ditolak.
- Currency: perubahan negara saat update (putuskan: boleh atau tidak; SP lama tidak).
- Project: tidak bisa diubah bila sudah dipakai `PR_T_PurchaseOrder`; ID/Nama kosong ditolak.
- Partner create: PartnerID `BP-YY00001` di awal tahun, berurutan, tidak tabrakan pada simpan paralel, lanjut benar setelah 9999.
- Partner: NIK numerik ≥ 8 digit yang sudah dipakai partner aktif lain ditolak dengan pesan `NIK … sudah terdaftar atas nama …`; paspor alfanumerik tidak dicek; NIK partner nonaktif tidak memblokir.
- Partner update tidak menghapus flag `IsDTTOT`.
- Quick save: KTP bukan 16 digit ditolak; NIK yang sudah ada mengembalikan partner lama; alamat pertama menjadi default; kode pos dicocokkan dari Zip.
- Alamat: set default baru mengosongkan default lama; kode pos wajib di form lengkap.
- Rekening bank: nomor rekening wajib; rekening yang dihapus tidak tampil (perbaikan atas perilaku lama).
- Attachment: ekstensi/ukuran ditolak; SourceID tidak ada → file tidak tertinggal di disk; user tanpa `FM-FP-R` tidak bisa view/download FP; ID lampiran terhapus → 404.
- DTTOT: upload file dengan baris error hanya menyimpan baris valid; kegagalan di tengah me-rollback seluruh daftar (daftar lama tetap utuh); screening EXACT vs PARTIAL (nama < 5 karakter tidak PARTIAL); alias dipecah dengan benar; simpan screening men-set Y/N sesuai centang dan mencabut flag partner yang tidak lagi cocok.
