package model

import "time"

const (
	RoleUser  = "USER"
	RoleAdmin = "ADMIN"
)

// User represents the domain model for a user
type User struct {
	ID           int64
	Username     string
	PasswordHash string
	Role         string
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
