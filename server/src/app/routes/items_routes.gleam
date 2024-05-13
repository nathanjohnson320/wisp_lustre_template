import app/models/item
import app/web.{type Context, Context}
import gleam/io
import gleam/result
import sqlight
import wisp.{type Request, type Response}

pub fn list_items(_req: Request, ctx: Context) {
  let sql =
    "
    SELECT *
    FROM items
  "
  let current_items = sqlight.query(sql, ctx.repo, [], item.from_db())

  case current_items {
    Ok(items) -> {
      items
      |> item.todos_to_json
      |> wisp.json_response(200)
    }
    Error(e) -> {
      io.debug(e)
      wisp.internal_server_error()
    }
  }
}

pub fn post_create_item(req: Request, ctx: Context) {
  use json <- wisp.require_json(req)

  let result = {
    use item <- result.try(item.item_decoder()(json))

    let sql =
      "
      INSERT INTO items (id, title, status)
      VALUES (?, ?, ?)
      RETURNING *
    "
    sqlight.query(
      sql,
      ctx.repo,
      [
        sqlight.text(wisp.random_string(64)),
        sqlight.text(item.title),
        sqlight.text(item.item_status_to_string(item.status)),
      ],
      item.from_db(),
    )
    |> result.map_error(fn(e) {
      io.debug(e)
      []
    })
  }

  case result {
    Ok([#(id, title, status)]) -> {
      #(id, title, status)
      |> item.todo_to_json
      |> wisp.json_response(201)
    }
    Ok(_) -> wisp.internal_server_error()
    Error(e) -> {
      io.debug(e)
      wisp.bad_request()
    }
  }
}

pub fn delete_item(_req: Request, ctx: Context, item_id: String) {
  let sql =
    "
      DELETE FROM items WHERE id = ?
      RETURNING *
    "
  let result =
    sqlight.query(sql, ctx.repo, [sqlight.text(item_id)], item.from_db())
    |> result.map_error(fn(e) {
      io.debug(e)
      []
    })

  case result {
    Ok([#(id, title, status)]) -> {
      #(id, title, status)
      |> item.todo_to_json
      |> wisp.json_response(200)
    }
    Ok(_) -> wisp.not_found()
    Error(e) -> {
      io.debug(e)
      wisp.bad_request()
    }
  }
}

pub fn patch_item(req: Request, ctx: Context, item_id: String) {
  use json <- wisp.require_json(req)

  let result = {
    use item <- result.try(item.item_decoder()(json))

    let sql =
      "
      UPDATE items
      SET title = ?, status = ?
      WHERE id = ?
      RETURNING *
    "
    sqlight.query(
      sql,
      ctx.repo,
      [
        sqlight.text(item.title),
        sqlight.text(item.item_status_to_string(item.status)),
        sqlight.text(item_id),
      ],
      item.from_db(),
    )
    |> result.map_error(fn(e) {
      io.debug(e)
      []
    })
  }

  case result {
    Ok([#(id, title, status)]) -> {
      #(id, title, status)
      |> item.todo_to_json
      |> wisp.json_response(200)
    }
    Ok(_) -> wisp.internal_server_error()
    Error(e) -> {
      io.debug(e)
      wisp.bad_request()
    }
  }
}

pub fn items_middleware(
  _req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  handle_request(ctx)
}
