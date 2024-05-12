import app/models/item.{type Item, create_item}
import app/web.{type Context, Context}
import gleam/dynamic
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None, Some}
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

  let current_items = []

  let result = {
    use item_title <- result.try(list.key_find(form.values, "todo_title"))
    let new_item = create_item(None, item_title, False)
    list.append(current_items, [new_item])
    |> Ok
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

pub fn delete_item(_req: Request, ctx: Context, item_id: String) {
  let current_items: List(Item) = []

  let _json_items = {
    list.filter(current_items, fn(item) { item.id != item_id })
  }
  wisp.redirect("/")
}

pub fn patch_toggle_todo(_req: Request, ctx: Context, item_id: String) {
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

type ItemsJson {
  ItemsJson(id: String, title: String, completed: Bool)
}

pub fn items_middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  let parsed_items = {
    case wisp.get_cookie(req, "items", wisp.PlainText) {
      Ok(json_string) -> {
        let decoder =
          dynamic.decode3(
            ItemsJson,
            dynamic.field("id", dynamic.string),
            dynamic.field("title", dynamic.string),
            dynamic.field("completed", dynamic.bool),
          )
          |> dynamic.list

        let result = json.decode(json_string, decoder)
        case result {
          Ok(items) -> items
          Error(_) -> []
        }
      }
      Error(_) -> []
    }
  }

  let items = create_items_from_json(parsed_items)

  handle_request(ctx)
}

fn create_items_from_json(items: List(ItemsJson)) -> List(Item) {
  items
  |> list.map(fn(item) {
    let ItemsJson(id, title, completed) = item
    create_item(Some(id), title, completed)
  })
}
