package apperror

// #nosec G101 -- user-facing error messages, not credentials
var errorMessages = map[string]string{
	// Validation errors (400) - both use same message for security
	CodeValidationFailed: "Invalid username or password format",
	CodePasswordTooLong:  "Invalid username or password format",

	// Auth errors (401) - use generic message to avoid leaking information
	CodeAuthFailed:   "Invalid username or password", // Same message for all auth failures (user not found, wrong password, rate limited)
	CodeUnauthorized: "Unauthorized or invalid token",

	// Conflict errors (409)
	CodeUsernameExists: "Username already exists",

	// Rate limiting errors (429)
	CodeRateLimitExceeded: "Too many requests, please try again later",

	// Server errors (500)
	CodeInternalServerError: "Internal server error",
	CodeDatabaseError:       "Database operation failed",
	CodeAuthStateError:      "Authentication state error, please login again",

	// Service unavailable errors (503)
	CodeServiceUnavailable: "Service temporarily unavailable",
}

func GetMessage(code string) string {
	if msg, ok := errorMessages[code]; ok {
		return msg
	}
	return "Unknown error"
}
