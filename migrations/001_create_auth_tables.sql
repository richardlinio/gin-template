-- +goose Up
CREATE TYPE user_role AS ENUM('USER', 'ADMIN');

CREATE TABLE
    users (
        id BIGSERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        password_hash VARCHAR(72) NOT NULL,
        ROLE user_role NOT NULL DEFAULT 'USER',
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMP NULL
    );

CREATE UNIQUE INDEX idx_users_username ON users (username);

CREATE TABLE
    refresh_tokens (
        id BIGSERIAL PRIMARY KEY,
        token_jti VARCHAR(64) NOT NULL,
        user_id BIGINT NOT NULL REFERENCES users (id),
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        revoked_at TIMESTAMP NULL,
        expires_at TIMESTAMP NOT NULL
    );

CREATE UNIQUE INDEX idx_refresh_tokens_jti ON refresh_tokens (token_jti);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);

CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens (expires_at);

-- +goose Down
DROP TABLE IF EXISTS refresh_tokens;

DROP TABLE IF EXISTS users;

DROP TYPE IF EXISTS user_role;