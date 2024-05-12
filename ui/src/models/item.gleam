import api
import config.{type Config}
import gleam/dynamic
import gleam/json
import lustre/effect.{type Effect}
import lustre_http.{type HttpError}

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: Int, title: String, status: ItemStatus)
}

pub fn default() -> Item {
  Item(id: 0, title: "", status: Uncompleted)
}

pub fn decoder() {
  dynamic.decode3(
    Item,
    dynamic.field("id", dynamic.int),
    dynamic.field("title", dynamic.string),
    dynamic.field("status", status_decoder),
  )
}

pub fn status_decoder(
  d: dynamic.Dynamic,
) -> Result(ItemStatus, List(dynamic.DecodeError)) {
  case dynamic.string(d) {
    Ok("completed") -> Ok(Completed)
    Ok("uncompleted") -> Ok(Uncompleted)
    _ ->
      Error([dynamic.DecodeError(expected: "item status", found: "", path: [])])
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
    #("id", json.int(item.id)),
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
