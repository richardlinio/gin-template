package store

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/richardlinio/gin-template/internal/db"
)

// Store provides all functions to run database queries and transactions
type Store struct {
	*db.Queries
	pool *pgxpool.Pool
}

// New creates a new Store instance
func New(pool *pgxpool.Pool) *Store {
	return &Store{
		Queries: db.New(pool),
		pool:    pool,
	}
}

// execTx executes fn within a database transaction. The named return is
// required so the deferred rollback can surface a cleanup failure that
// happens after the body has otherwise succeeded.
func (s *Store) execTx(ctx context.Context, fn func(*db.Queries) error) (err error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}

	defer func() {
		rbErr := tx.Rollback(ctx)
		if rbErr == nil || errors.Is(rbErr, pgx.ErrTxClosed) {
			return
		}
		if err != nil {
			err = errors.Join(err, fmt.Errorf("rollback: %w", rbErr))
		} else {
			err = fmt.Errorf("rollback: %w", rbErr)
		}
	}()

	if fErr := fn(db.New(tx)); fErr != nil {
		_ = tx.Rollback(ctx)
		return fErr
	}
	return tx.Commit(ctx)
}
