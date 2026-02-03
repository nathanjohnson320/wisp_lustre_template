import config.{type Config}
import gleam/list
import http/item as http
import lustre/attribute.{autofocus, class, name, placeholder}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{button, div, form, h1, input, span, svg}
import lustre/element/svg
import lustre/event
import lustre_http.{type HttpError}
import models/item.{type Item, type ItemStatus, Completed, Item, Uncompleted}

pub type Model {
  Model(config: Config, current_item: Item, items: List(Item))
}

pub opaque type Msg {
  GotItems(Result(List(Item), HttpError))
  CreatedItem(Result(Item, HttpError))
  DeletedItem(Result(Item, HttpError))
  UpdatedItem(Result(Item, HttpError))
  SetTitle(String)
  CreateItem
  DeleteItem(String)
  CompleteItem(String)
}

pub fn init(config: Config) -> Model {
  Model(config: config, current_item: item.default(), items: [])
}

pub fn on_load(config: Config) -> Effect(Msg) {
  effect.batch([http.list_items(config, GotItems)])
}

pub fn update(msg: Msg, model: Model) -> #(Model, Effect(Msg)) {
  case msg {
    GotItems(Ok(items)) -> {
      #(Model(..model, items: items), effect.none())
    }
    GotItems(_) -> {
      #(model, effect.none())
    }
    CreatedItem(Ok(item)) -> {
      #(Model(..model, items: [item, ..model.items]), effect.none())
    }
    CreatedItem(_) -> {
      #(model, effect.none())
    }
    DeletedItem(Ok(item)) -> {
      #(
        Model(
          ..model,
          items: model.items
            |> list.filter(fn(i) { i.id != item.id }),
        ),
        effect.none(),
      )
    }
    DeletedItem(_) -> {
      #(model, effect.none())
    }
    UpdatedItem(Ok(item)) -> {
      #(
        Model(
          ..model,
          items: model.items
            |> list.map(fn(i) {
              case i.id == item.id {
                True -> item
                False -> i
              }
            }),
        ),
        effect.none(),
      )
    }
    UpdatedItem(_) -> {
      #(model, effect.none())
    }
    SetTitle(title) -> {
      #(
        Model(..model, current_item: Item(..model.current_item, title: title)),
        effect.none(),
      )
    }
    CreateItem -> {
      #(
        Model(..model, current_item: item.default()),
        http.create_item(model.config, model.current_item, CreatedItem),
      )
    }
    DeleteItem(id) -> {
      #(model, http.delete_item(model.config, id, DeletedItem))
    }
    CompleteItem(id) -> {
      let assert Ok(item) =
        model.items
        |> list.find(fn(i) { i.id == id })

      let new_status = {
        case item.status {
          Completed -> Uncompleted
          Uncompleted -> Completed
        }
      }

      #(
        model,
        http.update_item(
          model.config,
          Item(..item, status: new_status),
          UpdatedItem,
        ),
      )
    }
  }
}

pub fn view(model: Model) -> Element(Msg) {
  div([class("px-5 mx-auto mt-5 w-full max-w-[512px]")], [
    h1([class("text-center font-bold text-4xl")], [text("Todo App")]),
    todos(model),
  ])
}

fn todos(model: Model) -> Element(Msg) {
  div([class("mt-3.5")], [
    todos_input(model),
    div([], [
      div(
        [class("flex flex-col gap-y-2.5 mt-5")],
        model.items
          |> list.map(item),
      ),
      todos_empty(),
    ]),
  ])
}

fn todos_input(model: Model) -> Element(Msg) {
  form(
    [
      class("flex w-full"),
      attribute.method("POST"),
      attribute.action("/items/create"),
      event.on_submit(fn(_) { CreateItem }),
    ],
    [
      input([
        name("todo_title"),
        class(
          "w-full border-none text-gray-900 bg-gray-100/80 px-5 py-2.5 rounded focus:bg-white outline-none",
        ),
        placeholder("What needs to be done?"),
        autofocus(True),
        attribute.value(model.current_item.title),
        event.on_input(SetTitle),
      ]),
    ],
  )
}

fn item(item: Item) -> Element(Msg) {
  let base_classes =
    "flex pt-3.5 pb-3.5 px-5 justify-between items-center rounded-lg text-gray-900 bg-gray-200"

  let button_classes = {
    case item.status {
      Completed ->
        "border-2 border-blue-500 bg-blue-500 flex justify-center items-center rounded-full w-5 h-5 text-white cursor-pointer p-0 hover:border-blue-500"
      Uncompleted ->
        "border-2 border-gray-500 flex justify-center items-center rounded-full w-5 h-5 text-white cursor-pointer p-0 hover:border-blue-500"
    }
  }

  let title_classes = {
    case item.status {
      Completed -> "ml-2.5 text-gray-500 line-through"
      Uncompleted -> "ml-2.5"
    }
  }

  div([class(base_classes)], [
    div([class("flex items-center")], [
      button([class(button_classes), event.on_click(CompleteItem(item.id))], [
        svg_icon_checked(item.status),
      ]),
      span([class(title_classes)], [text(item.title)]),
    ]),
    button(
      [
        class(
          "text-gray-500 p-0 border-none cursor-pointer bg-transparent hover:text-gray-900",
        ),
        event.on_click(DeleteItem(item.id)),
      ],
      [
        svg_icon_delete(),
      ],
    ),
  ])
}

fn todos_empty() -> Element(t) {
  div([class("mt-10 text-center text-blue-50")], [])
}

fn svg_icon_delete() -> Element(t) {
  svg([class("w-5"), attribute.attribute("viewBox", "0 0 24 24")], [
    svg.path([
      attribute.attribute("fill", "currentColor"),
      attribute.attribute(
        "d",
        "M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M9,8H11V17H9V8M13,8H15V17H13V8Z",
      ),
    ]),
  ])
}

fn svg_icon_checked(status: ItemStatus) -> Element(t) {
  let icon_classes = {
    case status {
      Completed -> "w-[15px] block"
      Uncompleted -> "w-[15px] hidden"
    }
  }

  svg([class(icon_classes), attribute.attribute("viewBox", "0 0 24 24")], [
    svg.path([
      attribute.attribute("fill", "currentColor"),
      attribute.attribute(
        "d",
        "M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z",
      ),
    ]),
  ])
}
