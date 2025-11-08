UPDATE items
SET title = $1,
    status = $2
WHERE id = $3
RETURNING *;