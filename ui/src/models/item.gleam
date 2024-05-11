import api
import config.{type Config}
import gleam/dynamic
import gleam/option.{type Option, None}
import lustre/effect.{type Effect}
import lustre_http.{type HttpError}

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: Option(String), title: String, status: ItemStatus)
}

pub fn default() -> Item {
  Item(id: None, title: "", status: Uncompleted)
}

pub fn decoder() {
  dynamic.decode3(
    Item,
    dynamic.field("id", dynamic.optional(dynamic.string)),
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

pub fn create_item(id: Option(String), title: String, completed: Bool) -> Item {
  case completed {
    True -> Item(id, title, status: Completed)
    False -> Item(id, title, status: Uncompleted)
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

pub fn list_items(
  config: Config,
  msg: fn(Result(List(Item), HttpError)) -> t,
) -> Effect(t) {
  config
  |> api.url("items")
  |> lustre_http.get(lustre_http.expect_json(dynamic.list(decoder()), msg))
}
