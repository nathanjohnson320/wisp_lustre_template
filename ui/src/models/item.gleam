import gleam/option.{type Option}

pub type ItemStatus {
  Completed
  Uncompleted
}

pub type Item {
  Item(id: Option(String), title: String, status: ItemStatus)
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
