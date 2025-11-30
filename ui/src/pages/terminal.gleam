import config.{type Config}
import design/terminal.{shell}
import dom
import gleam/dynamic/decode
import gleam/int
import lustre/attribute.{aria_label, class, id, role, title}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html.{button, div, li, nav, span, text, ul}
import lustre/event

pub type WindowState {
  Init
  Minimized
  Maximized
}

pub type Model {
  Model(
    config: Config,
    window_id: String,
    window_state: WindowState,
    dragging: Bool,
    drag_offset_x: Int,
    drag_offset_y: Int,
    drag_diff_x: Int,
    drag_diff_y: Int,
  )
}

pub opaque type Msg {
  NoOp
  DragStart(Int, Int)
  Dragging(Int, Int)
  DragEnd
}

pub fn init(config: Config) -> Model {
  Model(
    config: config,
    window_id: "terminal-window",
    window_state: Init,
    dragging: False,
    drag_offset_x: 0,
    drag_offset_y: 0,
    drag_diff_x: 40,
    drag_diff_y: 60,
  )
}

pub fn on_load(_config: Config) -> Effect(Msg) {
  effect.batch([
    dom.document_mouse_move(Dragging),
    dom.document_mouse_up(DragEnd),
  ])
}

pub fn update(msg: Msg, model: Model) -> #(Model, Effect(Msg)) {
  case msg {
    NoOp -> {
      #(model, effect.none())
    }
    DragStart(x, y) -> {
      case model.window_state {
        // don't drag when maximized
        Maximized -> #(model, effect.none())
        _ -> {
          let #(rx, ry) = dom.get_bounding_client_rect(model.window_id)
          let drag_offset_x = x - rx
          let drag_offset_y = y - ry

          #(
            Model(
              ..model,
              dragging: True,
              drag_offset_x: drag_offset_x,
              drag_offset_y: drag_offset_y,
            ),
            effect.none(),
          )
        }
      }
    }
    Dragging(x, y) -> {
      case model.dragging {
        False -> #(model, effect.none())
        True -> {
          #(
            Model(
              ..model,
              drag_diff_x: int.max(6, x - model.drag_offset_x),
              drag_diff_y: int.max(6, y - model.drag_offset_y),
            ),
            effect.none(),
          )
        }
      }
    }
    DragEnd -> {
      #(Model(..model, dragging: False), effect.none())
    }
  }
}

pub fn view(model: Model) -> Element(Msg) {
  main_window(model)
}

fn main_window(model: Model) -> Element(Msg) {
  shell([], [
    navbar(model),
    div(
      [
        id(model.window_id),
        class(
          "w-[70vw] h-[62vh] min-w-[420px] min-h-[260px] bg-[rgba(0,0,0,0.9)] border border-[rgba(0,255,0,0.9)] shadow-[0_0_18px_rgba(0,255,0,0.12)] absolute z-40 overflow-hidden flex flex-col ",
        ),
        attribute.styles([
          #("left", int.to_string(model.drag_diff_x) <> "px"),
          #("top", int.to_string(model.drag_diff_y) <> "px"),
        ]),
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
        window_body(model),
      ],
    ),
  ])
}

fn navbar(_model: Model) -> Element(Msg) {
  nav([class("flex gap-[18px] p-3 border-b border-green-200/6")], [
    ul([class("flex gap-4 list-none m-0 p-0")], [
      li([class("relative menu-item")], [
        text("File"),
        ul(
          [
            class(
              "absolute top-full left-0 bg-[rgba(0,0,0,0.95)] border border-[#00ff00] min-w-[120px] z-50 hidden menu-dropdown",
            ),
          ],
          [
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("New"),
            ]),
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Open"),
            ]),
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Save"),
            ]),
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Exit"),
            ]),
          ],
        ),
      ]),
      li([class("relative menu-item")], [
        text("Edit"),
        ul(
          [
            class(
              "absolute top-full left-0 bg-[rgba(0,0,0,0.95)] border border-[#00ff00] min-w-[120px] z-50 hidden menu-dropdown",
            ),
          ],
          [
            li([class("p-2 cursor-pointer")], [text("Undo")]),
            li([class("p-2 cursor-pointer")], [text("Redo")]),
            li([class("p-2 cursor-pointer")], [text("Cut")]),
            li([class("p-2 cursor-pointer")], [text("Copy")]),
          ],
        ),
      ]),
      li([class("relative menu-item")], [
        text("View"),
        ul(
          [
            class(
              "absolute top-full left-0 bg-[rgba(0,0,0,0.95)] border border-[#00ff00] min-w-[120px] z-50 hidden menu-dropdown",
            ),
          ],
          [
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Zoom In"),
            ]),
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Zoom Out"),
            ]),
            li([class("p-2 cursor-pointer")], [text("Fullscreen")]),
          ],
        ),
      ]),
      li([class("relative menu-item")], [
        text("Terminal"),
        ul(
          [
            class(
              "absolute top-full left-0 bg-[rgba(0,0,0,0.95)] border border-[#00ff00] min-w-[140px] z-50 hidden menu-dropdown",
            ),
          ],
          [
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("New Terminal"),
            ]),
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Close Terminal"),
            ]),
          ],
        ),
      ]),
      li([class("relative menu-item")], [
        text("Help"),
        ul(
          [
            class(
              "absolute top-full left-0 bg-[rgba(0,0,0,0.95)] border border-[#00ff00] min-w-[120px] z-50 hidden menu-dropdown",
            ),
          ],
          [
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("Documentation"),
            ]),
            li([class("p-2 cursor-pointer"), event.on_click(NoOp)], [
              text("About"),
            ]),
          ],
        ),
      ]),
    ]),
  ])
}

fn title_bar(_model: Model) -> Element(Msg) {
  div(
    [
      on_drag_start(DragStart),
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

fn window_body(_model: Model) -> Element(Msg) {
  div(
    [class("flex-1 p-4 overflow-auto text-green-400 bg-black/30 font-[VT323]")],
    [
      text("Welcome to the terminal!\n\n"),
      text(
        "This is a simulated terminal window built with Gleam and Wisp Lustre.\n\n",
      ),
      text("Feel free to customize and expand its functionality as needed."),
    ],
  )
}

fn on_drag_start(msg) -> attribute.Attribute(msg) {
  event.on("mousedown", {
    use x <- decode.field("clientX", decode.int)
    use y <- decode.field("clientY", decode.int)
    msg(x, y) |> decode.success
  })
}
