import config.{type Config}
import design/terminal.{menu, menu_item, shell, tab, tab_group, top_bar}
import lustre/attribute.{class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub type Model {
  Model(config: Config, menu_open: Bool)
}

pub opaque type Msg {
  NoOp
  ToggleMenu
}

pub fn init(config: Config) -> Model {
  Model(config: config, menu_open: False)
}

pub fn on_load(_config: Config) -> Effect(Msg) {
  effect.none()
}

pub fn update(msg: Msg, model: Model) -> #(Model, Effect(Msg)) {
  case msg {
    NoOp -> {
      #(model, effect.none())
    }
    ToggleMenu -> {
      #(Model(config: model.config, menu_open: !model.menu_open), effect.none())
    }
  }
}

pub fn view(model: Model) -> Element(Msg) {
  shell([class("p-4")], [
    top_bar("Terminal UI", NoOp, NoOp, NoOp),
    html.div([], [
      menu(
        [event.on_click(ToggleMenu)],
        "Menu",
        [menu_item([], "Menu Item 1"), menu_item([], "Menu Item 2")],
        model.menu_open,
      ),
    ]),
    tab_group([], [tab([], "Tab 1", True), tab([], "Tab 2", False)]),
  ])
}
