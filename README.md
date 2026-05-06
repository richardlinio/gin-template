# Go Gin Backend Template

A production-ready backend template built with Go Gin framework and PostgreSQL, featuring a complete JWT authentication system.

## Features

- ✅ **JWT Authentication** - Complete auth system (register, login, logout, refresh token)
- ✅ **Layer-Based Architecture** - Clean separation: handler → service → repository
- ✅ **Dockerized Development** - Full Docker environment with hot reload (Air)
- ✅ **Database Migrations** - Version control for database schema (Goose)
- ✅ **Unified Error Handling** - Centralized error handling with consistent JSON responses
- ✅ **API Documentation** - OpenAPI 3.0 (Swagger) documentation
- ✅ **CORS Configuration** - Configurable CORS settings
- ✅ **Structured Logging** - JSON logging with slog
- ✅ **Rate Limiting** - Built-in rate limiting middleware
- ✅ **Security Headers** - Security middleware for production

## Tech Stack

- **Language**: Go 1.25.5
- **Framework**: Gin
- **Database**: PostgreSQL 17
- **DB Driver**: pgx/v5
- **Migration Tool**: Goose
- **Authentication**: JWT (gin-jwt)
- **Development**: Docker Compose + Air (hot reload)
- **Linting**: golangci-lint + gofumpt

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Make (optional, for convenience commands)

### Setup

1. Clone this template repository

2. Copy environment variables
   ```bash
   cp .env.example .env
   ```

3. Start the services
   ```bash
   docker-compose up -d
   ```

4. Run database migrations
   ```bash
   make migrate-up
   ```

5. Verify the server is running
   ```bash
   curl http://localhost:8080/healthz
   # Expected: {"status":"ok"}
   ```

## Project Structure

```
.
├── cmd/server/              # Application entry point
├── internal/
│   ├── app/                 # Application lifecycle management
│   ├── config/              # Configuration loading
│   ├── handler/             # HTTP handlers (presentation layer)
│   ├── service/             # Business logic layer
│   ├── repository/          # Data access layer
│   ├── dto/                 # Data Transfer Objects
│   ├── model/               # Domain models
│   ├── middleware/          # HTTP middleware
│   ├── router/              # Route definitions
│   ├── apperror/            # Error handling system
│   ├── util/                # Utility functions
│   └── infrastructure/
│       ├── database/        # Database connection
│       ├── logger/          # Logging setup
│       └── server/          # HTTP server config
├── migrations/              # Database migration files
├── tests/                   # Test files
├── docs/                    # Documentation
│   ├── api-docs/            # API documentation
│   └── db-schema.dbml       # Database ERD
└── docker-compose.yml       # Docker services
```

## Development

### Common Commands

```bash
# Format code
make fmt

# Run linter
make lint

# Build the application
make build

# Run tests
make test

# Database migrations
make migrate-status    # Check migration status
make migrate-up        # Run pending migrations
make migrate-down      # Rollback last migration
make migrate-reset     # Reset database (drop all + re-run)
```

### API Endpoints

**Health Check**
- `GET /healthz` - Server health status

**Authentication**
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login (get tokens)
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout (invalidate token) [Protected]

See full API documentation in [docs/api-docs/swagger.yaml](docs/api-docs/swagger.yaml)

## Using This Template

### 1. Rename the Module

Update `go.mod` and all import paths:

```bash
# Find and replace "github.com/linporu/gin-template"
# with your own module name across all .go files and go.mod
```

### 2. Update Configuration

Modify `.env` file with your settings:
- Database credentials
- JWT secret key
- Server port
- CORS settings

### 3. Start Building

Add new features following the layer-based architecture:

1. Define DTOs in `internal/dto/`
2. Add models in `internal/model/` (if needed)
3. Create repository in `internal/repository/`
4. Implement service in `internal/service/`
5. Create handler in `internal/handler/`
6. Register routes in `internal/router/router.go`

See [CLAUDE.md](CLAUDE.md) for detailed development guidelines.

## Configuration

All configuration is loaded from environment variables. See [.env.example](.env.example) for available options:

- **Server**: Port, timeouts
- **Database**: Connection settings, pool size
- **Logger**: Level, format
- **CORS**: Allowed origins, credentials
- **JWT**: Secret key, token expiration
- **Rate Limit**: Requests per second

## Database Schema

The template includes a minimal authentication schema:

- `users` - User accounts with role-based access control (USER, ADMIN)
- `refresh_tokens` - JWT refresh token storage with rotation and revocation

View full ERD in [docs/db-schema.dbml](docs/db-schema.dbml)

## Error Handling

The application uses a unified error handling system with centralized middleware:

- **Consistent JSON responses** with error codes and messages
- **Automatic logging** based on error severity
- **Validation error details** for client-side form handling

See [CLAUDE.md](CLAUDE.md) for error handling guidelines.

## Testing

```bash
# Run all tests
make test

# Run with race detector (CI mode)
go test -v -race ./...
```

## Production Deployment

Before deploying:

1. Set strong JWT secret in production environment
2. Enable HTTPS
3. Configure proper CORS origins
4. Set appropriate rate limits
5. Review and adjust timeout settings
6. Set up log aggregation

## License

MIT License - feel free to use this template for any project.

## Support

For issues or questions, please check [CLAUDE.md](CLAUDE.md) for development guidelines.
