import app/db/item as db
import app/sql
import app/web.{type Context}
import gleam/dynamic/decode
import gleam/list
import gleam/result
import models/item
import wisp.{type Request, type Response}

pub fn list_items(_req: Request, ctx: Context) {
  let current_items = sql.items_list(ctx.repo())

  case current_items {
    Ok(data) -> {
      data.rows
      |> list.map(db.from_row)
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

    sql.items_insert(
      ctx.repo(),
      wisp.random_string(64),
      item.title,
      item.item_status_to_string(item.status),
    )
    |> result.map_error(fn(e) {
      echo e
      []
    })
  }

  case result {
    Ok(data) -> {
      case data.rows {
        [row] -> {
          row
          |> db.from_row_insert()
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
  let result =
    sql.items_delete(ctx.repo(), item_id)
    |> result.map_error(fn(e) {
      echo e
      []
    })

  case result {
    Ok(data) -> {
      case data.rows {
        [row] -> {
          row
          |> db.from_row_delete()
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

    sql.items_update(
      ctx.repo(),
      item.title,
      item.item_status_to_string(item.status),
      item_id,
    )
    |> result.map_error(fn(e) {
      echo e
      []
    })
  }

  case result {
    Ok(data) -> {
      case data.rows {
        [row] -> {
          row
          |> db.from_row_update()
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
