import config.{type Config}
import design/terminal.{button, shell}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}

pub type Model {
  Model(config: Config)
}

pub opaque type Msg {
  NoOp
}

pub fn init(config: Config) -> Model {
  Model(config: config)
}

pub fn on_load(_config: Config) -> Effect(Msg) {
  effect.none()
}

pub fn update(msg: Msg, model: Model) -> #(Model, Effect(Msg)) {
  case msg {
    NoOp -> {
      #(model, effect.none())
    }
  }
}

pub fn view(_model: Model) -> Element(Msg) {
  shell([], [button([], "Terminal Button")])
}
