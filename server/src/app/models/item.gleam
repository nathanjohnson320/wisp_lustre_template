import gleam/dynamic
import gleam/json
import gleam/string_builder.{type StringBuilder}

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: String, title: String, status: ItemStatus)
}

pub fn from_db() -> fn(dynamic.Dynamic) ->
  Result(#(String, String, String), List(dynamic.DecodeError)) {
  dynamic.tuple3(dynamic.string, dynamic.string, dynamic.string)
}

pub fn toggle_todo(item: Item) -> Item {
  let new_status = case item.status {
    Completed -> Uncompleted
    Uncompleted -> Completed
  }
  Item(..item, status: new_status)
}

pub fn item_status_to_string(status: ItemStatus) -> String {
  case status {
    Completed -> "complete"
    Uncompleted -> "uncomplete"
  }
}

pub fn string_to_item_status(status: String) -> Result(ItemStatus, String) {
  case status {
    "complete" -> Ok(Completed)
    "uncomplete" -> Ok(Uncompleted)
    _ -> Error("Invalid status")
  }
}

pub fn todos_to_json(items: List(#(String, String, String))) -> StringBuilder {
  json.array(items, item_encoder)
  |> json.to_string_builder()
}

pub fn todo_to_json(item: #(String, String, String)) -> StringBuilder {
  item
  |> item_encoder()
  |> json.to_string_builder()
}

fn item_encoder(item: #(String, String, String)) -> json.Json {
  json.object([
    #("id", json.string(item.0)),
    #("title", json.string(item.1)),
    #("status", json.string(item.2)),
  ])
}

pub fn item_decoder() {
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
    Ok("uncompleted") -> Ok(Uncompleted)
    _ ->
      Error([dynamic.DecodeError(expected: "item status", found: "", path: [])])
  }
}
