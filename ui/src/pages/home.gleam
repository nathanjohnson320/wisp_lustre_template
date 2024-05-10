import gleam/list
import gleam/option.{None, Some}
import lustre/attribute.{autofocus, class, name, placeholder}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{button, div, form, h1, input, span, svg}
import lustre/element/svg
import models/item.{type Item, Completed, Uncompleted}

pub type Model {
  Model(items: List(Item))
}

pub opaque type Msg

pub fn init() -> Model {
  Model(items: [])
}

pub fn update(msg: Msg, model: Model) -> #(Model, Effect(Msg)) {
  case msg {
    _ -> #(model, effect.none())
  }
}

pub fn view(model: Model) -> Element(t) {
  div([class("app")], [
    h1([class("app-title")], [text("Todo App")]),
    todos(model.items),
  ])
}

fn todos(items: List(Item)) -> Element(t) {
  div([class("todos")], [
    todos_input(),
    div([class("todos__inner")], [
      div(
        [class("todos__list")],
        items
          |> list.map(item),
      ),
      todos_empty(),
    ]),
  ])
}

fn todos_input() -> Element(t) {
  form(
    [
      class("add-todo-input"),
      attribute.method("POST"),
      attribute.action("/items/create"),
    ],
    [
      input([
        name("todo_title"),
        class("add-todo-input__input"),
        placeholder("What needs to be done?"),
        autofocus(True),
      ]),
    ],
  )
}

fn item(item: Item) -> Element(t) {
  let completed_class: String = {
    case item.status {
      Completed -> "todo--completed"
      Uncompleted -> ""
    }
  }
  let item_id = case item.id {
    Some(id) -> id
    None -> ""
  }

  div([class("todo " <> completed_class)], [
    div([class("todo__inner")], [
      form(
        [
          attribute.method("POST"),
          attribute.action("/items/" <> item_id <> "/completion?_method=PATCH"),
        ],
        [button([class("todo__button")], [svg_icon_checked()])],
      ),
      span([class("todo__title")], [text(item.title)]),
    ]),
    form(
      [
        attribute.method("POST"),
        attribute.action("/items/" <> item_id <> "?_method=DELETE"),
      ],
      [button([class("todo__delete")], [svg_icon_delete()])],
    ),
  ])
}

fn todos_empty() -> Element(t) {
  div([class("todos__empty")], [])
}

fn svg_icon_delete() -> Element(t) {
  svg(
    [class("todo__delete-icon"), attribute.attribute("viewBox", "0 0 24 24")],
    [
      svg.path([
        attribute.attribute("fill", "currentColor"),
        attribute.attribute(
          "d",
          "M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M9,8H11V17H9V8M13,8H15V17H13V8Z",
        ),
      ]),
    ],
  )
}

fn svg_icon_checked() -> Element(t) {
  svg(
    [class("todo__checked-icon"), attribute.attribute("viewBox", "0 0 24 24")],
    [
      svg.path([
        attribute.attribute("fill", "currentColor"),
        attribute.attribute(
          "d",
          "M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z",
        ),
      ]),
    ],
  )
}
