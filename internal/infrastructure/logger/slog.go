package logger

import (
	"fmt"
	"log/slog"
	"os"
	"strings"

	"github.com/richardlinio/gin-template/internal/config"
)

const (
	formatJSON   = "json"
	formatText   = "text"
	levelDebug   = "debug"
	levelInfo    = "info"
	levelWarn    = "warn"
	levelWarning = "warning"
	levelError   = "error"
)

// NewLogger creates and configures a new slog.Logger instance
// based on the provided LoggerConfig
func NewLogger(cfg config.LoggerConfig) *slog.Logger {
	level := parseLogLevel(cfg.Level)

	// Determine output stream based on log level
	// WARN and ERROR go to stderr, INFO and DEBUG go to stdout
	var output *os.File
	if level >= slog.LevelWarn {
		output = os.Stderr
	} else {
		output = os.Stdout
	}

	// Create handler based on format
	var handler slog.Handler
	opts := &slog.HandlerOptions{
		Level: level,
	}

	switch cfg.Format {
	case formatJSON:
		handler = slog.NewJSONHandler(output, opts)
	case formatText:
		handler = slog.NewTextHandler(output, opts)
	default:
		fmt.Fprintf(os.Stderr, "Warning: invalid log format '%s', using default '%s'\n", cfg.Format, formatText)
		handler = slog.NewTextHandler(output, opts)
	}

	return slog.New(handler)
}

// parseLogLevel converts string to slog.Level
func parseLogLevel(level string) slog.Level {
	// Convert to lowercase for case-insensitive comparison
	level = strings.ToLower(level)

	switch level {
	case levelDebug:
		return slog.LevelDebug
	case levelInfo:
		return slog.LevelInfo
	case levelWarn, levelWarning:
		return slog.LevelWarn
	case levelError:
		return slog.LevelError
	default:
		fmt.Fprintf(os.Stderr, "Warning: invalid log level '%s', using default '%s'\n", level, levelInfo)
		return slog.LevelInfo
	}
}
