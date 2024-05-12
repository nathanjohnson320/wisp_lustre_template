import app/models/item.{type Item}
import app/web.{type Context, Context}
import gleam/io
import gleam/list
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
      |> wisp.json_response(200)
    }
    Ok(_) -> wisp.internal_server_error()
    Error(e) -> {
      io.debug(e)
      wisp.bad_request()
    }
  }
}

pub fn delete_item(_req: Request, _ctx: Context, item_id: String) {
  let current_items: List(Item) = []

  let _json_items = {
    list.filter(current_items, fn(item) { item.id != item_id })
  }
  wisp.redirect("/")
}

pub fn patch_toggle_todo(_req: Request, _ctx: Context, item_id: String) {
  let current_items: List(Item) = []

  let result = {
    use _ <- result.try(
      list.find(current_items, fn(item) { item.id == item_id }),
    )
    list.map(current_items, fn(item) {
      case item.id == item_id {
        True -> item.toggle_todo(item)
        False -> item
      }
    })
    |> Ok
  }

  case result {
    Ok(_json_items) -> wisp.redirect("/")

    Error(_) -> wisp.bad_request()
  }
}

pub fn items_middleware(
  _req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  handle_request(ctx)
}
