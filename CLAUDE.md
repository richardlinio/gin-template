# CLAUDE.md

> **本檔角色**：給 Claude Code / AI agent 的開發 workflow 與偏好。
>
> **三檔分工**：
> - 架構鐵律（MUST / NEVER） → [`docs/constitution.md`](./docs/constitution.md)
> - 專案介紹、啟動指引、目錄結構、API 端點、commands → [`README.md`](./README.md)
> - Workflow 步驟與 agent 偏好 → 本檔

**動手前 MUST 先讀** [`docs/constitution.md`](./docs/constitution.md) 七條核心原則。本檔為其補充，不重複條文。

---

## Workflow：新增功能

依層次由內而外建立檔案（呼應 constitution §I 分層）：

1. 在 `internal/dto/` 定義 request / response struct
2. 視需求在 `internal/model/` 加 domain model
3. 在 `internal/repository/` 建 repository（含 sentinel error，遵守 §VII）
4. 在 `internal/service/` 寫業務邏輯（service 內定義本地 interface 取用 repository，遵守 §I）
5. 在 `internal/handler/` 寫 HTTP 層（錯誤一律 `c.Error(err)` + `return`，遵守 §II）
6. 在 `internal/router/router.go` 註冊路由
7. 在 `internal/app/app.go` 的 `New()` 完成依賴組裝（NEVER 在各層 `init()` 或全域變數做 DI）

---

## Workflow：新增 Error Type

完整 5 步驟見 [`docs/constitution.md`](./docs/constitution.md) 附錄 A。捷徑：開 [`internal/apperror/codes.go`](./internal/apperror/codes.go) 找一個現有條目當範本，依樣修改 4 個檔案（codes / messages / status / error）。

新 code **MUST** 插入對應 HTTP status section（400/401/.../503 升序）。

---

## Workflow：Database 變更

1. 建立 migration：`migrations/NNN_description.sql`，**MUST** 同時寫 `-- +goose Up` 與 `-- +goose Down`（遵守 §V）
2. 跑 migration：`make migrate-up`
3. 確認狀態：`make migrate-status`
4. 若使用 sqlc：在 `internal/db/queries/*.sql` 寫查詢，再 `make sqlc` 產出型別安全程式碼

---

## Workflow：新增 Middleware

1. 在 `internal/middleware/` 建 function，回傳 `gin.HandlerFunc`
2. 若需設定，在 `internal/config/` 加 config struct（遵守 §III pass-by-value）
3. 在 `router.Setup()` 中按執行順序註冊（cors → recovery → logger → ratelimit → auth → error_handler 依序而下）
4. 若新增環境變數，同步更新 `.env.example`

---

## Commit 前自我檢查

提交前 **MUST** 執行（任一失敗禁止 commit，遵守 §VI）：

```bash
make fmt    # gofumpt 格式化
make lint   # golangci-lint + go build
make test   # 含 race detector
```

---

## 命名（呼應 §IV）

寫新識別字時 **MUST** 用完整單字：`authService` ✓ / `authSvc` ✗。允許 `ctx` / `cfg` / `err` / `req` / `resp` / `db` / `tx` 等 Go 標準縮寫。

---

## Tests

- 測試檔 **MUST** 用 `_test.go` 後綴
- 跑全測試：`make test`（CI 等同 `go test -v -race ./...`）
- BDD 測試骨架在 `tests/bdd/features/`（DSL + ISA 兩層）與 `tests/bdd/steps/`
