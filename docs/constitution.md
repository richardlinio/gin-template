# Gin Backend Template Constitution

> **本檔角色**：rules-only。違反任一條款 = block PR / merge。
>
> **三檔分工**：
> - 架構鐵律（MUST / NEVER，違反 = 架構崩潰） → 本檔
> - 開發 workflow 與 agent 偏好（怎麼動手） → [`CLAUDE.md`](../CLAUDE.md)
> - 專案介紹與啟動指引（給人類讀者） → [`README.md`](../README.md)
>
> **修改原則**：本檔每條規則對應實證程式碼，違反會破壞既有架構。新增/移除條款必須走治理流程（見章末）。

---

## 核心原則

### I. 嚴格分層 (Non-Negotiable)

依賴方向：`Handler → Service → Repository`。**低層級絕對不可匯入高層級**，亦不可跨層呼叫。

- Handler **MUST** 只依賴 Service；**NEVER** 直接匯入或呼叫 Repository。
- Service **MUST** 透過本地 interface 取用 Repository（在 service 套件內定義 `userRepository` 等 interface），**NEVER** 直接依賴 `*repository.XxxRepository` 具體型別作為欄位型態。
- Service **NEVER** 匯入 `gin` 套件、**NEVER** 操作 `*gin.Context`。
- Repository **NEVER** 回傳 HTTP-aware 錯誤（例如 `*apperror.AppError`），**MUST** 回傳套件內定義的 sentinel error（見 §VII）。
- 所有依賴組裝 **MUST** 集中於 `internal/app/app.go` 的 `New()` 中；**NEVER** 在套件層 `init()`、全域變數、或 handler/service 內部初始化依賴。

```go
// ✅ service/auth.go — 用本地 interface 解耦
type userRepository interface {
    GetByUsername(ctx context.Context, username string) (*model.User, error)
}
type AuthService struct {
    userRepository userRepository
}
func NewAuthService(userRepo *repository.UserRepository, ...) *AuthService { ... }

// ❌ handler/auth.go — 直接 import repository
import "github.com/.../internal/repository"  // FORBIDDEN in handler
```

**執行機制**：CI lint 階段檢查 import 路徑；違規 = block merge。

---

### II. 統一錯誤處理 (Non-Negotiable)

所有業務錯誤路徑由 middleware 統一回應與記錄。任何手動 `c.JSON` 錯誤、手動 log 錯誤、回傳裸 `error` 皆為違規。

- Service **MUST** 回傳 `*apperror.AppError`；**NEVER** 回傳裸 `error`。
- Handler **MUST** 用 `c.Error(err)` + `return` 把錯誤丟給 middleware；**NEVER** 對錯誤路徑呼叫 `c.JSON(4xx/5xx, ...)`。
- Handler **NEVER** 對錯誤手動寫 `logger.Error()` / `logger.Warn()`；middleware 統一處理。
- 新增 error code **MUST** 同步更新四個檔案：`codes.go` / `messages.go` / `status.go` / `error.go`（constructor）。詳細步驟見章末附錄 A。
- error code 在 `codes.go` / `messages.go` / `status.go` 三檔中 **MUST** 按 HTTP status code 升序排列（400 → 401 → 403 → 404 → 409 → 429 → 500 → 503）。
- `error_handler` middleware **MUST** 註冊在 chain 末端（在 `auth` 等所有可能 `c.Error()` 的 middleware 之後）；註冊順序錯誤會讓統一錯誤處理失效。

```go
// ✅ Service 回傳 AppError
if exists {
    return apperror.UsernameExists()
}
if err != nil {
    return apperror.DatabaseError(err)
}

// ✅ Handler 用 c.Error 丟給 middleware
if err := h.service.Register(ctx, req); err != nil {
    _ = c.Error(err)
    return
}

// ❌ Handler 手動回應錯誤
c.JSON(http.StatusBadRequest, gin.H{"error": "..."})  // FORBIDDEN
```

**執行機制**：code review 檢查；middleware 對非 `AppError` 一律以 500 unexpected 回應，自動暴露違規。

---

### III. Config 不可變性：Pass-by-Value

所有 config 結構與 loader **MUST** 以值型別傳遞，**NEVER** 以 pointer。表達 config 啟動後不可變。

- Loader **MUST** 回 value：`func loadXxxConfig() (XxxConfig, error)`。
- Config 結構 **MUST** 存 value：`type Config struct { Xxx XxxConfig }`，子欄位非 pointer。
- 接收 config 的 constructor **MUST** 收 value：`func NewHandler(cfg config.JWTConfig)`。

```go
// ✅
func NewAuthHandler(cfg config.JWTConfig, ...) *AuthHandler { ... }

// ❌
func NewAuthHandler(cfg *config.JWTConfig, ...) *AuthHandler { ... }
```

---

### IV. 命名一致性：禁止縮寫

識別字 **MUST** 使用完整名稱；**NEVER** 使用領域常見縮寫。

| ✅ 正確 | ❌ 禁止 |
|---|---|
| `authService` | `authSvc` |
| `userRepository` | `userRepo` |
| `refreshTokenRepository` | `refreshTokenRepo` |

例外：Go 標準慣用縮寫（`ctx`、`cfg`、`err`、`req`、`resp`、`db`、`tx`）允許使用。

---

### V. Migration 紀律 (Non-Negotiable)

Schema 變更 **MUST** 經 migration 檔案記錄；**NEVER** 手改線上 / 開發 DB schema。

- 檔名格式 **MUST** 為 `NNN_description.sql`（例：`001_create_users_table.sql`），位於 `migrations/`。
- 每個 migration **MUST** 同時提供 `-- +goose Up` 與 `-- +goose Down` 區塊。
- Down migration **MUST** 真實可逆（能還原 Up 的所有變更），**NEVER** 留空或寫 `-- noop`。

---

### VI. CI Gate (Non-Negotiable)

主分支合併前 **MUST** 通過下列檢查；任一失敗 = block merge。

- `make lint` 必過（含 `golangci-lint` + `go build`）。
- `go test -v -race ./...` 必過（race detector 必開）。
- `make fmt` 必先執行（`gofumpt`）；若 CI 偵測到未格式化檔案 = 違規。

---

### VII. Repository 錯誤包裝

Repository **MUST** 將底層 driver 的原始錯誤轉為套件內 sentinel error；**NEVER** 把 `pgx.ErrNoRows`、`*pgconn.PgError` 直接外洩到 service。

- 找不到資料 **MUST** 轉為語義化 sentinel：`errors.Is(err, pgx.ErrNoRows)` → `repository.ErrUserNotFound`。
- Unique violation 等 PgError **MUST** 對照 `pgerrcode` 轉為語義化 sentinel：`repository.ErrUsernameDuplicate`。
- Service 層 **MUST** 使用 `errors.Is(err, repository.ErrXxx)` 判斷，再轉成 `*apperror.AppError`。

```go
// ✅ repository/user.go
if errors.Is(err, pgx.ErrNoRows) {
    return nil, ErrUserNotFound
}
if pgErr := new(pgconn.PgError); errors.As(err, &pgErr) && pgErr.Code == pgerrcode.UniqueViolation {
    return ErrUsernameDuplicate
}

// ✅ service/auth.go
if errors.Is(err, repository.ErrUsernameDuplicate) {
    return apperror.UsernameExists()
}

// ❌ repository 直接外洩 pgx.ErrNoRows
return nil, err  // FORBIDDEN if err is a raw driver error
```

---

## 治理

### 修正案程序

新增、修改、移除任何條款 **MUST** 透過 PR：

1. PR 描述 **MUST** 載明：(a) 變更條款編號 (b) 變更前後差異 (c) 為什麼這條從 `CLAUDE.md` 升格至此，或為什麼降格（反之亦然） (d) 既有違規程式碼的遷移計畫。
2. PR 變更需至少一位 reviewer 共識。
3. 若該條款導致現有程式碼大量違規，**MUST** 同時提交修正或標註 `// CONSTITUTION EXCEPTION: <reason>` 暫緩。

### 版本政策（semver）

- **MAJOR**：條款被移除，或以不相容方式重新定義（既有合規程式碼變違規）。
- **MINOR**：新增條款，或既有條款新增義務。
- **PATCH**：澄清、措辭修正、範例補充，不改變語義。

### 例外標註

少數特例 **MUST** 在程式碼中加註：

```go
// CONSTITUTION EXCEPTION (§I): 本檔暫保留直接呼叫 repository，待 SPE-XXX 完成 service 層拆分後移除。
```

無註解的違規視同 block merge。

---

## 附錄 A：新增 Error Type 的 5 步驟

呼應 §II。新增一個 error type 必須完成下列五步：

**Step 1 — 加 code 常數** [`internal/apperror/codes.go`](../internal/apperror/codes.go)（**置於對應 HTTP status section 內**）：

```go
const CodeResourceNotFound = "ERR_RESOURCE_NOT_FOUND"
```

**Step 2 — 加中文訊息** [`internal/apperror/messages.go`](../internal/apperror/messages.go)：

```go
var errorMessages = map[string]string{
    CodeResourceNotFound: "資源不存在",
}
```

**Step 3 — 對應 HTTP status** [`internal/apperror/status.go`](../internal/apperror/status.go)：

```go
var httpStatusMap = map[string]int{
    CodeResourceNotFound: http.StatusNotFound,
}
```

**Step 4 — 加 constructor** [`internal/apperror/error.go`](../internal/apperror/error.go)：

```go
func ResourceNotFound() *AppError {
    return New(CodeResourceNotFound)
}
```

**Step 5 — Service 端使用**：

```go
if !exists {
    return apperror.ResourceNotFound()
}
```

遺漏任一步驟即違反 §II。

---

**版本**：1.0.0 | **批准日期**：2026-05-07 | **最後修正**：2026-05-07
