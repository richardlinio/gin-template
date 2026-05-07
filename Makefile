# Makefile for Gin Template Backend
#
# Convention: every target's recipe runs inside the `backend` docker compose
# service via $(DOCKER_EXEC), unless explicitly noted (docker / swagger / hooks).
# Run `make help` to see all available targets grouped by category.

# ─── Variables ──────────────────────────────────────────────────────────────

DOCKER_EXEC = docker compose exec backend

# Goose migration config — env vars (DB_USER / DB_PASSWORD / DB_NAME) come from
# docker-compose.yml at runtime, hence the escaped `$$`.
GOOSE_DRIVER        = postgres
GOOSE_MIGRATION_DIR = ./migrations
GOOSE_DB_DSN        = host=db port=5432 user=$$DB_USER password=$$DB_PASSWORD dbname=$$DB_NAME sslmode=disable
GOOSE_CMD           = goose -dir $(GOOSE_MIGRATION_DIR) $(GOOSE_DRIVER) "$(GOOSE_DB_DSN)"

# ─── Help ───────────────────────────────────────────────────────────────────

.DEFAULT_GOAL := help

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} \
		/^# ─── / {sub(/^# ─── /, ""); sub(/ ─+.*/, ""); \
			if ($$0 == "Variables" || $$0 == "Help") next; \
			printf "\n\033[1m%s\033[0m\n", $$0; next} \
		/^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ─── Docker ─────────────────────────────────────────────────────────────────

.PHONY: up
up: ## Start all services in the background
	docker compose up -d

.PHONY: down
down: ## Stop services and remove volumes
	docker compose down -v

.PHONY: restart
restart: down up ## Stop everything and start fresh (down + up)

.PHONY: docker-build
docker-build: ## Rebuild docker images from scratch (no cache)
	docker compose build --no-cache

# ─── Code Quality ───────────────────────────────────────────────────────────

# `lint` already runs `go build ./...` as a compile check, so there is no
# separate `go-build` target — if you want a build-only smoke test, run `make lint`.
.PHONY: fmt
fmt: ## Format Go code (gofumpt) and SQL files (pg_format)
	$(DOCKER_EXEC) gofumpt -l -w .
	$(DOCKER_EXEC) sh -c 'find migrations internal/db/queries -name "*.sql" -print0 | xargs -0 -r pg_format --config /app/.pg_format --inplace --multiline --placeholder "-- \+goose StatementBegin[\s\S]*?-- \+goose StatementEnd\n+"'

.PHONY: lint
lint: ## Compile-check the build, then run golangci-lint
	$(DOCKER_EXEC) go build -o /dev/null ./...
	$(DOCKER_EXEC) golangci-lint run

.PHONY: test
test: ## Run all Go tests
	$(DOCKER_EXEC) go test ./...

.PHONY: tidy
tidy: ## Tidy go.mod / go.sum
	$(DOCKER_EXEC) go mod tidy

# ─── Database ───────────────────────────────────────────────────────────────

.PHONY: sqlc
sqlc: ## Regenerate type-safe DB code from queries
	$(DOCKER_EXEC) sqlc generate

.PHONY: migrate-status
migrate-status: ## Show pending/applied migrations
	$(DOCKER_EXEC) sh -c '$(GOOSE_CMD) status'

.PHONY: migrate-up
migrate-up: ## Apply all pending migrations
	$(DOCKER_EXEC) sh -c '$(GOOSE_CMD) up'

.PHONY: migrate-down
migrate-down: ## Roll back the most recent migration
	$(DOCKER_EXEC) sh -c '$(GOOSE_CMD) down'

.PHONY: migrate-reset
migrate-reset: ## Drop everything and re-run all migrations
	$(DOCKER_EXEC) sh -c '$(GOOSE_CMD) reset'
	$(DOCKER_EXEC) sh -c '$(GOOSE_CMD) up'

# ─── Tests & Docs ───────────────────────────────────────────────────────────

.PHONY: test-bdd-isa
test-bdd-isa: ## Run the BDD/ISA feature suite
	$(DOCKER_EXEC) go test -v ./tests/bdd -run TestFeatures

.PHONY: swagger
swagger: ## Bundle the OpenAPI spec into docs/api-docs/bundled-swagger.yaml
	npx @apidevtools/swagger-cli bundle docs/api-docs/swagger.yaml -o docs/api-docs/bundled-swagger.yaml -t yaml
	@echo "✓ Bundled swagger file generated at docs/api-docs/bundled-swagger.yaml"

# ─── Git Hooks ──────────────────────────────────────────────────────────────

.PHONY: hooks-install
hooks-install: ## Enable repo git hooks (sets core.hooksPath=.githooks)
	git config core.hooksPath .githooks
	@echo "✓ git hooks enabled (core.hooksPath=.githooks)"

.PHONY: hooks-uninstall
hooks-uninstall: ## Disable repo git hooks (unsets core.hooksPath)
	git config --unset core.hooksPath
	@echo "✓ git hooks disabled (core.hooksPath unset)"
