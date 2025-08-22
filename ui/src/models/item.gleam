import api
import config.{type Config}
import gleam/dynamic/decode
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

pub fn decoder() -> decode.Decoder(Item) {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  use status <- decode.field("status", status_decoder())
  decode.success(Item(id:, title:, status:))
}

pub fn status_decoder() -> decode.Decoder(ItemStatus) {
  use decoded_string <- decode.then(decode.string)
  case decoded_string {
    "complete" -> decode.success(Completed)
    "uncomplete" -> decode.success(Uncompleted)
    _ -> decode.failure(Uncompleted, "Invalid status")
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
  |> lustre_http.get(lustre_http.expect_json(decode.list(decoder()), msg))
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

pub fn update_item(
  config: Config,
  item: Item,
  msg: fn(Result(Item, HttpError)) -> t,
) -> Effect(t) {
  let url = api.url(config, "items" <> "/" <> item.id)
  let req =
    url
    |> request.to()
    |> result.unwrap(request.new())

  req
  |> request.set_method(http.Patch)
  |> request.set_header("Content-Type", "application/json")
  |> request.set_body(json.to_string(item_encoder(item)))
  |> lustre_http.send(lustre_http.expect_json(decoder(), msg))
}
