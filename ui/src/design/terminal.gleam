import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html

const terminal_green = "#00ff00"

const terminal_dark = "#003300"

const terminal_bg = "#000000"

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
