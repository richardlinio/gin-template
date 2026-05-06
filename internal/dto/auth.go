package dto

type UserInfo struct {
	ID       int64  `json:"id"`
	Username string `json:"username"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required,min=3,max=50,alphanum_underscore"`
	Password string `json:"password" binding:"required,min=8,max=128,password_charset"`
}

type RegisterResponse struct {
	Message string `json:"message"`
	UserID  int64  `json:"userId"`
}

// ToRegisterResponse converts registration result to DTO
func ToRegisterResponse(message string, userID int64) RegisterResponse {
	return RegisterResponse{
		Message: message,
		UserID:  userID,
	}
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	AccessToken string   `json:"accessToken"`
	User        UserInfo `json:"user"`
}

// ToLoginResponse converts login result to DTO
func ToLoginResponse(accessToken string, userID int64, username string) LoginResponse {
	return LoginResponse{
		AccessToken: accessToken,
		User: UserInfo{
			ID:       userID,
			Username: username,
		},
	}
}

type LogoutResponse struct {
	Message string `json:"message"`
}

// ToLogoutResponse creates a logout response
func ToLogoutResponse(message string) LogoutResponse {
	return LogoutResponse{
		Message: message,
	}
}

type RefreshResponse struct {
	AccessToken string   `json:"accessToken"`
	User        UserInfo `json:"user"`
}

// ToRefreshResponse converts refresh result to DTO
func ToRefreshResponse(accessToken string, userID int64, username string) RefreshResponse {
	return RefreshResponse{
		AccessToken: accessToken,
		User: UserInfo{
			ID:       userID,
			Username: username,
		},
	}
}
