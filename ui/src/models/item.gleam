import api
import config.{type Config}
import gleam/dynamic
import gleam/http
import gleam/http/request
import gleam/json
import gleam/result
import lustre/effect.{type Effect}
import lustre_http.{type HttpError}

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: String, title: String, status: ItemStatus)
}

pub fn default() -> Item {
  Item(id: "", title: "", status: Uncompleted)
}

pub fn decoder() {
  dynamic.decode3(
    Item,
    dynamic.field("id", dynamic.string),
    dynamic.field("title", dynamic.string),
    dynamic.field("status", status_decoder),
  )
}

pub fn status_decoder(
  d: dynamic.Dynamic,
) -> Result(ItemStatus, List(dynamic.DecodeError)) {
  case dynamic.string(d) {
    Ok("completed") -> Ok(Completed)
    Ok("uncomplete") -> Ok(Uncompleted)
    _ -> {
      Error([dynamic.DecodeError(expected: "item status", found: "", path: [])])
    }
  }
}

pub fn toggle_todo(item: Item) -> Item {
  let new_status = case item.status {
    Completed -> Uncompleted
    Uncompleted -> Completed
  }
  Item(..item, status: new_status)
}

pub fn item_status_to_bool(status: ItemStatus) -> Bool {
  case status {
    Completed -> True
    Uncompleted -> False
  }
}

fn item_encoder(item: Item) -> json.Json {
  let status = case item.status {
    Completed -> "completed"
    Uncompleted -> "uncompleted"
  }
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("status", json.string(status)),
  ])
}

pub fn list_items(
  config: Config,
  msg: fn(Result(List(Item), HttpError)) -> t,
) -> Effect(t) {
  config
  |> api.url("items")
  |> lustre_http.get(lustre_http.expect_json(dynamic.list(decoder()), msg))
}

pub fn create_item(
  config: Config,
  item: Item,
  msg: fn(Result(Item, HttpError)) -> t,
) -> Effect(t) {
  let body = item_encoder(item)

  config
  |> api.url("items")
  |> lustre_http.post(body, lustre_http.expect_json(decoder(), msg))
}

pub fn delete_item(
  config: Config,
  item_id: String,
  msg: fn(Result(Item, HttpError)) -> t,
) -> Effect(t) {
  let url = api.url(config, "items" <> "/" <> item_id)
  let req =
    url
    |> request.to()
    |> result.unwrap(request.new())

  req
  |> request.set_method(http.Delete)
  |> lustre_http.send(lustre_http.expect_json(decoder(), msg))
}
