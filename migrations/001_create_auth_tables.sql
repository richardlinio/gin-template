-- +goose Up
CREATE TYPE user_role AS ENUM('USER', 'ADMIN');

CREATE TABLE
    users (
        id BIGSERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        password_hash VARCHAR(60) NOT NULL,
        role user_role NOT NULL DEFAULT 'USER',
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ NULL
    );

CREATE UNIQUE INDEX idx_users_username ON users (username) WHERE deleted_at IS NULL;

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE
    refresh_tokens (
        id BIGSERIAL PRIMARY KEY,
        token_jti VARCHAR(64) NOT NULL,
        user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        revoked_at TIMESTAMPTZ NULL,
        expires_at TIMESTAMPTZ NOT NULL
    );

CREATE UNIQUE INDEX idx_refresh_tokens_jti ON refresh_tokens (token_jti);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);

CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens (expires_at);

-- +goose Down
DROP TABLE IF EXISTS refresh_tokens;

DROP TRIGGER IF EXISTS trg_users_set_updated_at ON users;

DROP FUNCTION IF EXISTS set_updated_at();

DROP TABLE IF EXISTS users;

DROP TYPE IF EXISTS user_role;
