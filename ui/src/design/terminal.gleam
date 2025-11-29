import lustre/attribute.{type Attribute, class, classes}
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
  html.div([class("crt font-terminal w-full h-dvh"), ..attributes], children)
}

/// A button styled to look like a terminal button.
pub fn button(attributes: List(Attribute(msg)), label: String) -> Element(msg) {
  html.button(
    [
      classes([
        #("bg-black", True),
        #("text-" <> terminal_green, True),
        #("border", True),
        #("border-" <> terminal_green, True),
        #("px-3", True),
        #("py-2", True),
        #("hover:bg-" <> terminal_green, True),
        #("hover:text-black", True),
        #("transition", True),
      ]),
      ..attributes
    ],
    [html.text(label)],
  )
}
