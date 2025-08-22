import gleam/dynamic/decode
import gleam/json
import gleam/string_tree.{type StringTree}

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: String, title: String, status: ItemStatus)
}

pub fn from_db() -> decode.Decoder(#(String, String, ItemStatus)) {
  use id <- decode.field(0, decode.string)
  use title <- decode.field(1, decode.string)
  use status <- decode.field(2, status_decoder())
  decode.success(#(id, title, status))
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

pub fn todos_to_json(items: List(#(String, String, ItemStatus))) -> StringTree {
  json.array(items, item_encoder)
  |> json.to_string_tree()
}

pub fn todo_to_json(item: #(String, String, ItemStatus)) -> StringTree {
  item
  |> item_encoder()
  |> json.to_string_tree()
}

fn item_encoder(item: #(String, String, ItemStatus)) -> json.Json {
  json.object([
    #("id", json.string(item.0)),
    #("title", json.string(item.1)),
    #("status", json.string(item_status_to_string(item.2))),
  ])
}

pub fn item_decoder() -> decode.Decoder(Item) {
  use id <- decode.field("id", decode.string)
  use title <- decode.field("title", decode.string)
  use status <- decode.field("status", status_decoder())
  decode.success(Item(id:, title:, status:))
}

pub fn status_decoder() -> decode.Decoder(ItemStatus) {
  use decoded_string <- decode.then(decode.string)
  case decoded_string {
    "completed" -> decode.success(Completed)
    "uncompleted" -> decode.success(Uncompleted)
    _ -> decode.failure(Uncompleted, "Invalid status")
  }
}
