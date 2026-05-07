FROM golang:1.26-alpine
WORKDIR /app

# Install development tools and dependencies
RUN apk add --no-cache curl git bash build-base perl && \
    go install github.com/air-verse/air@v1.65.1 && \
    go install mvdan.cc/gofumpt@v0.10.0 && \
    go install github.com/pressly/goose/v3/cmd/goose@v3.27.1 && \
    go install github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1 && \
    curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.12.2 && \
    git clone --depth 1 --branch v5.9 https://github.com/darold/pgFormatter.git /tmp/pgformatter && \
    cd /tmp/pgformatter && perl Makefile.PL && make && make install && \
    cd / && rm -rf /tmp/pgformatter

# Copy dependency files for caching
COPY go.mod go.sum ./
RUN go mod download

EXPOSE 8080

CMD ["air", "-c", ".air.toml"]
