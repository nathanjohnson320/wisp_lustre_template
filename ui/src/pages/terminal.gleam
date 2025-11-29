import config.{type Config}
import lustre/attribute.{aria_label, class, id, role, title}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html.{button, div, span, text}
import lustre/event

pub type Model {
  Model(config: Config, menu_open: Bool)
}

pub opaque type Msg {
  NoOp
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
  }
}

pub fn view(model: Model) -> Element(Msg) {
  main_window(model)
}

fn main_window(model: Model) -> Element(Msg) {
  div(
    [
      class(
        "font-[VT323] animate-[phosphor_1.2s_ease-in-out_infinite] w-[70vw] h-[62vh] min-w-[420px] min-h-[260px] bg-[rgba(0,0,0,0.9)] border-[1px_solid_rgba(0,255,0,0.9)] shadow-[0_0_18px_rgba(0,255,0,0.12)] absolute left-[calc(50%_-_35vw)] top-[calc(12vh)] z-40 overflow-hidden flex flex-col",
      ),
      role("dialog"),
      aria_label("Terminal window"),
    ],
    [
      title_bar(model),
      // Top
      div(
        [
          class(
            "absolute z-50 bg-transparent -top-1 left-0 right-0 h-2 cursor-n-resize",
          ),
        ],
        [],
      ),
      // Bottom
      div(
        [
          class(
            "absolute z-50 bg-transparent bottom-[-4px] left-0 right-0 h-2 cursor-s-resize",
          ),
        ],
        [],
      ),
      // Right
      div(
        [
          class(
            "absolute z-50 bg-transparent right-[-4px] top-0 bottom-0 w-[8px] cursor-e-resize",
          ),
        ],
        [],
      ),
      // Left
      div(
        [
          class(
            "absolute z-50 bg-transparent left-[-4px] top-0 bottom-0 w-2 cursor-w-resize",
          ),
        ],
        [],
      ),
      // Top Right
      div(
        [
          class(
            "absolute z-50 bg-transparent -top-1.5 -right-1.5 w-3.5 h-3.5 cursor-ne-resize",
          ),
        ],
        [],
      ),
      // Top Left
      div(
        [
          class(
            "absolute z-50 bg-transparent -top-1.5 -left-1.5 w-3.5 h-3.5 cursor-nw-resize",
          ),
        ],
        [],
      ),
      // Bottom Right
      div(
        [
          class(
            "absolute z-50 bg-transparent bottom-[calc(-6px)] right-[calc(-6px)] w-[14px] h-[14px] cursor-se-resize",
          ),
        ],
        [],
      ),
      // Bottom Left
      div(
        [
          class(
            "absolute z-50 bg-transparent bottom-[-6px] left-[-6px] w-[14px] h-[14px] cursor-sw-resize",
          ),
        ],
        [],
      ),
    ],
  )
}

fn title_bar(_model: Model) -> Element(Msg) {
  div(
    [
      class(
        "select-none flex items-center justify-between px-2.5 py-1.5 border-b border-green-500/6 bg-black/60 cursor-grab z-40 active:cursor-grabbing",
      ),
    ],
    [
      div([class("flex items-center gap-2")], [
        span([class("text-[#99ff99] font-bold")], [text("/usr/bin/terminal")]),
        span([class("text-[rgba(0,255,0,0.6)] text-[13px]")], [text("●")]),
      ]),
      div([class("win-controls flex gap-1 items-center")], [
        // Minimize / Maximize / Close buttons
        button(
          [
            class(
              "bg-transparent border-none text-green-500 p-1 text-xl cursor-pointer hover:text-green-200",
            ),
            title("Minimize"),
          ],
          [text("🗕")],
        ),
        button(
          [
            class(
              "bg-transparent border-none text-green-500 p-1 text-xl cursor-pointer hover:text-green-200",
            ),
            title("Maximize"),
          ],
          [text("🗖")],
        ),
        button(
          [
            class(
              "bg-transparent border-none text-green-500 p-1 text-xl cursor-pointer hover:text-green-200",
            ),
            title("Close"),
          ],
          [text("🗙")],
        ),
      ]),
    ],
  )
}
