import gleam/dynamic/decode
import gleam/json

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

pub fn item_status_to_bool(status: ItemStatus) -> Bool {
  case status {
    Completed -> True
    Uncompleted -> False
  }
}

pub fn string_to_item_status(status: String) -> Result(ItemStatus, String) {
  case status {
    "complete" -> Ok(Completed)
    "uncomplete" -> Ok(Uncompleted)
    _ -> Error("Invalid status")
  }
}

pub fn todos_to_json(items: List(Item)) -> String {
  json.array(items, item_encoder)
  |> json.to_string()
}

pub fn todo_to_json(item: Item) -> String {
  item
  |> item_encoder()
  |> json.to_string()
}

pub fn item_encoder(item: Item) -> json.Json {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("status", json.string(item_status_to_string(item.status))),
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
    "complete" -> decode.success(Completed)
    "uncomplete" -> decode.success(Uncompleted)
    "uncompleted" -> decode.success(Uncompleted)
    _ -> decode.failure(Uncompleted, "Invalid status")
  }
}
