import app/sql.{
  type ItemsDeleteRow, type ItemsInsertRow, type ItemsListRow,
  type ItemsUpdateRow,
}
import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: String, title: String, status: ItemStatus)
}

fn from_db_row_fields(id: String, title: String, status_string: String) -> Item {
  let status = result.unwrap(string_to_item_status(status_string), Uncompleted)
  Item(id: id, title: title, status: status)
}

pub fn from_db_row(row: ItemsListRow) -> Item {
  from_db_row_fields(row.id, row.title, row.status)
}

pub fn from_db_row_insert(row: ItemsInsertRow) -> Item {
  from_db_row_fields(row.id, row.title, row.status)
}

pub fn from_db_row_delete(row: ItemsDeleteRow) -> Item {
  from_db_row_fields(row.id, row.title, row.status)
}

pub fn from_db_row_update(row: ItemsUpdateRow) -> Item {
  from_db_row_fields(row.id, row.title, row.status)
}

pub fn from_db() -> decode.Decoder(#(String, String, String)) {
  use id <- decode.field(0, decode.string)
  use title <- decode.field(1, decode.string)
  use status <- decode.field(2, decode.string)
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

pub fn todos_to_json(items: List(Item)) -> String {
  json.array(items, item_encoder)
  |> json.to_string()
}

pub fn todo_to_json(item: Item) -> String {
  item
  |> item_encoder()
  |> json.to_string()
}

fn item_encoder(item: Item) -> json.Json {
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
    "uncompleted" -> decode.success(Uncompleted)
    _ -> decode.failure(Uncompleted, "Invalid status")
  }
}
