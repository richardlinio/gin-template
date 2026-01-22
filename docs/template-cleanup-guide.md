# Template Cleanup Guide

本文檔說明如何將此專案轉換為通用的 Golang Gin Template Repository。

## 🎯 目標

將 WaterBall SA Backend 轉換為一個 production-ready 的 Gin framework template，移除所有業務邏輯，保留核心架構和最佳實踐。

## 📋 清理步驟

### 1. 移除業務邏輯相關的 Migrations

**保留的 Migrations** (認證核心):

- `001_create_users_table.sql`
- `002_create_access_tokens_table.sql`
- `023_create_refresh_tokens_table.sql`

**需要刪除的 Migrations** (業務邏輯):

```bash
rm migrations/003_create_courses_module_tables.sql
rm migrations/004_create_user_unit_progress_table.sql
rm migrations/005_create_user_unit_submissions_table.sql
rm migrations/006_rename_courses_to_journeys_and_units_to_missions.sql
rm migrations/007_add_teacher_name_to_journeys.sql
rm migrations/008_add_mission_enums_and_restructure_missions_table.sql
rm migrations/009_merge_submissions_into_progress_with_status.sql
rm migrations/010_create_rewards_table.sql
rm migrations/011_create_mission_contents_table.sql
rm migrations/012_seed_test_journeys_and_missions.sql
rm migrations/013_add_slug_to_journeys.sql
rm migrations/014_rename_mission_status_to_progress_status.sql
rm migrations/015_update_video_duration_to_26_seconds.sql
rm migrations/016_fix_experience_values_and_access_levels.sql
rm migrations/017_create_orders_table.sql
rm migrations/018_create_order_items_table.sql
rm migrations/019_create_user_journeys_table.sql
rm migrations/020_add_order_expired_status.sql
rm migrations/021_rename_mission_contents_to_resources.sql
rm migrations/022_update_video_urls.sql
```

**重新編號保留的 Migrations**:

```bash
mv migrations/001_create_users_table.sql migrations/001_create_users_table.sql
mv migrations/002_create_access_tokens_table.sql migrations/002_create_access_tokens_table.sql
mv migrations/023_create_refresh_tokens_table.sql migrations/003_create_refresh_tokens_table.sql
```

### 2. 更新 Database Schema 文檔

更新 `docs/db-schema.dbml`，只保留認證相關的表格:

- `users` table
- `access_tokens` table (JWT blacklist)
- `refresh_tokens` table

移除所有課程、任務、訂單相關的 schema 定義。

### 3. 清理代碼結構

#### 3.1 Models (`internal/model/`)

**保留**:

- `user.go` - User model

**刪除**:

- 所有業務邏輯相關的 models (courses, missions, orders, etc.)

#### 3.2 DTOs (`internal/dto/`)

**保留**:

- `auth.go` - Authentication request/response DTOs
- 其他通用的 DTOs

**刪除**:

- 課程、任務、訂單相關的 DTOs

#### 3.3 Handlers (`internal/handler/`)

**保留**:

- `health.go` - Health check handler
- `auth.go` - Authentication handler

**刪除**:

- 所有業務邏輯相關的 handlers

#### 3.4 Services (`internal/service/`)

**保留**:

- `auth.go` - Authentication service

**刪除**:

- 所有業務邏輯相關的 services

#### 3.5 Repositories (`internal/repository/`)

**保留**:

- `user.go` - User repository
- `access_token.go` - Access token repository
- `refresh_token.go` - Refresh token repository

**刪除**:

- 所有業務邏輯相關的 repositories

### 4. 更新配置文件

#### 4.1 `.env.example`

更新為更通用的配置:

```env
# Database Configuration
DB_NAME=gin_template_db  # 改為通用名稱
```

#### 4.2 `go.mod`

更新 module path:

```go
module github.com/yourusername/gin-template  // 改為你的 template repo 路徑
```

#### 4.3 Docker Compose (如果有)

更新容器名稱、數據庫名稱等，改為通用名稱。

### 5. 更新路由設定

更新 `internal/router/router.go`，移除所有業務邏輯相關的路由，只保留:

- Health check routes
- Authentication routes (register, login, logout, refresh)

### 6. 清理文檔目錄

#### 保留:

- `db-schema.dbml` (更新後)
- `api-docs/` 目錄 (更新為只包含認證 API)

#### 刪除或歸檔:

- `auth-module-implementation.md` (移至 archive/ 或刪除)
- `code-review-*.md` (移至 archive/ 或刪除)
- `error-handling-implementation.md` (可保留作為架構說明)
- `rewrite-golang.md` (移至 archive/ 或刪除)

#### 新增:

- `template-usage.md` - 如何使用此模板建立新專案
- `architecture.md` - 架構設計說明
- `template-cleanup-guide.md` (本文檔)

### 7. 更新 README.md

將 README.md 改為模板導向，包含:

1. **專案簡介**:
   - 說明這是一個 production-ready 的 Gin template
   - 列出包含的核心功能

2. **核心功能**:
   - Layer-based 架構 (handler → service → repository)
   - 完整的 JWT 認證系統 (Access + Refresh Token)
   - Token Blacklist 機制
   - 統一的錯誤處理系統
   - 環境變數配置管理
   - CORS 與 Rate Limiting 中間件
   - Database connection pooling (pgxpool)
   - Structured logging (slog)
   - Docker 開發環境 + Air hot reload
   - Database migration (Goose)
   - Linting (golangci-lint) + Testing

3. **快速開始**:
   - 克隆專案
   - 環境設定
   - 啟動開發環境
   - 運行測試

4. **專案結構說明**

5. **如何基於此模板建立新專案**

### 8. 更新 CLAUDE.md

保持目前的結構，但需要:

- 移除業務邏輯相關的說明
- 強調這是一個模板專案
- 更新範例代碼，使用更通用的名稱

### 9. 建立初始化腳本

建立 `scripts/init-project.sh`，幫助使用者:

```bash
#!/bin/bash
# 初始化新專案

echo "🚀 初始化 Gin Template 專案"

# 1. 提示輸入新的 module name
read -p "請輸入新的 module name (例如: github.com/username/project): " MODULE_NAME

# 2. 更新 go.mod
echo "📝 更新 go.mod..."
sed -i '' "s|module .*|module $MODULE_NAME|" go.mod

# 3. 提示輸入數據庫名稱
read -p "請輸入數據庫名稱 (預設: myapp_db): " DB_NAME
DB_NAME=${DB_NAME:-myapp_db}

# 4. 更新 .env.example
echo "📝 更新 .env.example..."
sed -i '' "s|DB_NAME=.*|DB_NAME=$DB_NAME|" .env.example

# 5. 複製 .env.example 到 .env
echo "📝 建立 .env 文件..."
cp .env.example .env

# 6. 提示更新其他配置
echo ""
echo "✅ 初始化完成！"
echo ""
echo "📋 接下來的步驟:"
echo "1. 更新 .env 文件中的配置 (JWT_SECRET, CORS_ALLOWED_ORIGINS 等)"
echo "2. 運行 'make migrate-up' 初始化數據庫"
echo "3. 運行 'make build' 建置專案"
echo "4. 運行 'make test' 執行測試"
echo ""
echo "💡 提示: 請查閱 docs/template-usage.md 了解更多使用說明"
```

### 10. 測試清理結果

清理完成後，進行以下測試:

```bash
# 1. 格式化代碼
make fmt

# 2. 運行 linter
make lint

# 3. 運行測試
make test

# 4. 建置專案
make build

# 5. 運行 migration
make migrate-up

# 6. 啟動服務並測試 API
# - GET /api/v1/health
# - POST /api/v1/auth/register
# - POST /api/v1/auth/login
# - POST /api/v1/auth/refresh
# - POST /api/v1/auth/logout
```

## ✅ 保留的核心功能清單

### 架構層面

- [x] Layer-based 架構設計 (handler → service → repository)
- [x] Dependency Injection 模式
- [x] 清晰的目錄結構

### 認證系統

- [x] JWT Access Token + Refresh Token 雙 token 機制
- [x] Token Blacklist (access_tokens table)
- [x] Refresh Token 管理 (refresh_tokens table)
- [x] Bcrypt 密碼加密
- [x] User Roles (STUDENT, TEACHER, ADMIN)

### 錯誤處理

- [x] 統一的錯誤處理機制 (apperror package)
- [x] Error Handler Middleware
- [x] 標準化的錯誤響應格式
- [x] 多語言錯誤訊息支援 (中文)

### 配置管理

- [x] 環境變數配置系統
- [x] 分模組配置結構 (server, database, logger, cors, jwt, rate limit)
- [x] 配置驗證機制

### 中間件

- [x] CORS Middleware
- [x] Rate Limiting Middleware
- [x] Error Handler Middleware
- [x] Authentication Middleware (JWT)

### 基礎設施

- [x] Database Connection Pooling (pgxpool)
- [x] Structured Logging (slog)
- [x] Graceful Shutdown
- [x] Health Check Endpoint

### 開發工具

- [x] Docker 開發環境
- [x] Air Hot Reload
- [x] Goose Migration
- [x] Makefile 常用指令
- [x] golangci-lint 設定
- [x] GitHub Actions CI/CD

### 測試框架

- [x] BDD 測試結構 (godog)
- [x] Test Utilities
- [x] 測試環境配置

## 🚫 需要移除的業務邏輯

### Models

- Courses/Journeys
- Missions/Units
- Mission Contents/Resources
- User Progress
- Submissions
- Rewards
- Orders
- Order Items
- User Journeys

### Features

- 課程管理
- 任務管理
- 進度追蹤
- 提交系統
- 獎勵系統
- 訂單系統
- 購買流程

## 📝 最終檢查清單

執行清理前，請確認:

- [ ] 已備份原始專案
- [ ] 已建立新的 git branch 進行清理工作
- [ ] 已閱讀完整的清理步驟

執行清理後，請確認:

- [ ] 所有測試通過
- [ ] Linter 無錯誤
- [ ] Migration 可以正常執行
- [ ] API 端點可以正常運作 (health, auth)
- [ ] README.md 已更新為模板說明
- [ ] CLAUDE.md 已移除業務邏輯說明
- [ ] 文檔已更新
- [ ] `.env.example` 已更新為通用配置
- [ ] `go.mod` module name 已更新
- [ ] 初始化腳本已建立並測試

## 🎉 完成

完成所有步驟後，你將擁有一個乾淨、通用的 Golang Gin Template，可以:

- 直接用於新專案開發
- 分享給團隊使用
- 作為 GitHub Template Repository 供其他開發者使用

建議在 GitHub 上:

1. 建立新的 repository (例如: `gin-template`)
2. 將清理後的代碼推送到新 repository
3. 設定為 Template Repository (Settings → Template repository)
4. 撰寫詳細的 README 和 documentation
5. 加入 License (MIT, Apache 2.0 等)
