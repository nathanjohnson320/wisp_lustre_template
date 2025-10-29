import app/models/item
import app/web.{type Context}
import gleam/dynamic/decode
import gleam/result
import pog
import wisp.{type Request, type Response}

pub fn list_items(_req: Request, ctx: Context) {
  let sql =
    "
    SELECT *
    FROM items
  "
  let current_items =
    sql
    |> pog.query()
    |> pog.returning(item.from_db())
    |> pog.execute(ctx.repo())

  case current_items {
    Ok(data) -> {
      data.rows
      |> item.todos_to_json
      |> wisp.json_response(200)
    }
    Error(e) -> {
      echo e
      wisp.internal_server_error()
    }
  }
}

pub fn post_create_item(req: Request, ctx: Context) {
  use json <- wisp.require_json(req)

  let result = {
    use item <- result.try(decode.run(json, item.item_decoder()))

    let sql =
      "
      INSERT INTO items (id, title, status)
      VALUES ($1, $2, $3)
      RETURNING *
    "

    sql
    |> pog.query()
    |> pog.parameter(pog.text(wisp.random_string(64)))
    |> pog.parameter(pog.text(item.title))
    |> pog.parameter(pog.text(item.item_status_to_string(item.status)))
    |> pog.returning(item.from_db())
    |> pog.execute(ctx.repo())
    |> result.map_error(fn(e) {
      echo e
      []
    })
  }

  case result {
    Ok(data) -> {
      case data.rows {
        [#(id, title, status)] -> {
          #(id, title, status)
          |> item.todo_to_json
          |> wisp.json_response(201)
        }
        _ -> wisp.internal_server_error()
      }
    }
    Error(e) -> {
      echo e
      wisp.internal_server_error()
    }
  }
}

pub fn delete_item(_req: Request, ctx: Context, item_id: String) {
  let sql =
    "
      DELETE FROM items WHERE id = $1
      RETURNING *
    "
  let result =
    sql
    |> pog.query()
    |> pog.parameter(pog.text(item_id))
    |> pog.returning(item.from_db())
    |> pog.execute(ctx.repo())
    |> result.map_error(fn(e) {
      echo e
      []
    })

  case result {
    Ok(data) -> {
      case data.rows {
        [#(id, title, status)] -> {
          #(id, title, status)
          |> item.todo_to_json
          |> wisp.json_response(200)
        }
        _ -> wisp.internal_server_error()
      }
    }
    Error(e) -> {
      echo e
      wisp.internal_server_error()
    }
  }
}

pub fn patch_item(req: Request, ctx: Context, item_id: String) {
  use json <- wisp.require_json(req)

  let result = {
    use item <- result.try(decode.run(json, item.item_decoder()))

    let sql =
      "
      UPDATE items
      SET title = $1, status = $2
      WHERE id = $3
      RETURNING *
    "
    sql
    |> pog.query()
    |> pog.parameter(pog.text(item.title))
    |> pog.parameter(pog.text(item.item_status_to_string(item.status)))
    |> pog.parameter(pog.text(item_id))
    |> pog.returning(item.from_db())
    |> pog.execute(ctx.repo())
    |> result.map_error(fn(e) {
      echo e
      []
    })
    |> result.map_error(fn(e) {
      echo e
      []
    })
  }

  case result {
    Ok(data) -> {
      case data.rows {
        [#(id, title, status)] -> {
          #(id, title, status)
          |> item.todo_to_json
          |> wisp.json_response(200)
        }
        _ -> wisp.internal_server_error()
      }
    }
    Error(e) -> {
      echo e
      wisp.internal_server_error()
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
