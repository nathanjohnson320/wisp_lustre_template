import gleam/dynamic
import gleam/option.{type Option}
import wisp

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: String, title: String, status: ItemStatus)
}

pub fn from_db() -> fn(dynamic.Dynamic) ->
  Result(#(Int, String, String), List(dynamic.DecodeError)) {
  dynamic.tuple3(dynamic.int, dynamic.string, dynamic.string)
}

pub fn create_item(
  id: Option(String),
  title: String,
  status: ItemStatus,
) -> Item {
  let id = option.unwrap(id, wisp.random_string(64))
  Item(id, title, status: status)
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
