import lustre/attribute.{type Attribute, class, classes}
import lustre/element.{type Element}
import lustre/element/html.{text}
import lustre/event

/// A shell component that styles its children to look like a terminal.
pub fn shell(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [class("crt font-[VT323] w-full h-dvh text-2xl"), ..attributes],
    children,
  )
}

/// A button styled to look like a terminal button.
pub fn button(attributes: List(Attribute(msg)), label: String) -> Element(msg) {
  html.button(
    [
      class(
        "bg-black text-(--terminal-green) border border-(--terminal-green) px-3 py-2 hover:bg-(--terminal-green) hover:text-black transition",
      ),
      ..attributes
    ],
    [html.text(label)],
  )
}

pub fn menu(
  attributes: List(Attribute(msg)),
  label: String,
  items: List(Element(msg)),
  open: Bool,
) -> Element(msg) {
  html.ul(
    [
      class("flex space-x-6 border-b border-green-700 pb-2 mb-6 text-green-300"),
    ],
    [
      html.li([class("relative cursor-pointer"), ..attributes], [
        html.span([class("text-2xl")], [text(label)]),
        html.ul(
          [
            class(
              "absolute top-full left-0 bg-(--terminal-bg) border border-(--terminal-green) min-w-32 z-10",
            ),
            classes([#("block", open), #("hidden", !open)]),
          ],
          items,
        ),
      ]),
    ],
  )
}

/// A single item in a terminal-styled menu.
pub fn menu_item(
  attributes: List(Attribute(msg)),
  label: String,
) -> Element(msg) {
  html.li([class("padding-2 hover:bg-(--terminal-dark)"), ..attributes], [
    html.text(label),
  ])
}

/// Top bar
pub fn top_bar(
  title: String,
  on_open: msg,
  on_maximize: msg,
  on_close: msg,
) -> Element(msg) {
  html.div(
    [
      class(
        "flex items-ccenter justify-between bg-green-900/40 border border-green-400 px-4 py-2 mb-4",
      ),
    ],
    [
      html.span([class("text-green-300")], [text(title)]),
      html.div([class("space-x-3")], [
        html.span(
          [
            class("cursor-pointer hover:text-green-200"),
            event.on_click(on_open),
          ],
          [text("–")],
        ),
        html.span(
          [
            class("cursor-pointer hover:text-green-200"),
            event.on_click(on_maximize),
          ],
          [text("□")],
        ),
        html.span(
          [
            class("cursor-pointer hover:text-green-200"),
            event.on_click(on_close),
          ],
          [text("×")],
        ),
      ]),
    ],
  )
}
