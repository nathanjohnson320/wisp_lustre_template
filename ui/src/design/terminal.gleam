import lustre/attribute.{type Attribute, class, classes}
import lustre/element.{type Element}
import lustre/element/html.{text}

/// A shell component that styles its children to look like a terminal.
pub fn shell(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div([class("crt font-[VT323] w-full h-dvh"), ..attributes], children)
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
        text(label),
        html.ul(
          [
            class(
              "absolute top-full left-0 bg-(--terminal-bg) border border-(--terminal-green) min-w-24 z-10",
            ),
            classes([#("block", open), #("hidden", !open)]),
          ],
          items,
        ),
      ]),
    ],
  )
}

pub fn menu_item(
  attributes: List(Attribute(msg)),
  label: String,
) -> Element(msg) {
  html.li([class("padding-2 hover:bg-(--terminal-dark)"), ..attributes], [
    html.text(label),
  ])
}
