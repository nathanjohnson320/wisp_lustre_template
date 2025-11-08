INSERT INTO items (id, title, status)
VALUES ($1, $2, $3)
RETURNING *;