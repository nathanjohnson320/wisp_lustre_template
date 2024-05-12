import app/models/item.{type Item, create_item}
import app/web.{type Context, Context}
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None}
import gleam/result
import gleam/string_builder.{type StringBuilder}
import sqlight
import wisp.{type Request, type Response}

pub fn list_items(_req: Request, ctx: Context) {
  let sql =
    "
    SELECT id, title, status
    FROM items
  "
  let current_items = sqlight.query(sql, ctx.repo, [], item.from_db())

  case current_items {
    Ok(items) -> {
      items
      |> todos_to_json
      |> wisp.json_response(200)
    }
    Error(e) -> {
      io.debug(e)
      wisp.internal_server_error()
    }
  }
}

pub fn post_create_item(req: Request, ctx: Context) {
  use form <- wisp.require_form(req)

  let result = {
    use item_title <- result.replace_error(list.key_find(
      form.values,
      "todo_title",
    ))
    let new_item = create_item(None, item_title, item.Uncompleted)

    let sql =
      "
      INSERT INTO items (title, status)
      VALUES (?, ?)
    "
    sqlight.query(
      sql,
      ctx.repo,
      [
        sqlight.text(new_item.title),
        sqlight.text(item.item_status_to_string(new_item.status)),
      ],
      item.from_db(),
    )
  }

  case result {
    Ok(_todos) -> {
      wisp.redirect("/")
    }
    Error(_) -> {
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

fn todos_to_json(items: List(#(Int, String, String))) -> StringBuilder {
  json.array(items, item_encoder)
  |> json.to_string_builder()
}

fn item_encoder(item: #(Int, String, String)) -> json.Json {
  json.object([
    #("id", json.int(item.0)),
    #("title", json.string(item.1)),
    #("status", json.string(item.2)),
  ])
}

pub fn items_middleware(
  _req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  handle_request(ctx)
}
