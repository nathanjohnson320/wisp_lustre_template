import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html.{html, head, title, meta, link, body}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html([], [
    head([], [
      title([], "Todo App in Gleam"),
      meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      link([attribute.rel("stylesheet"), attribute.href("/static/app.css")]),
    ]),
    body([], elements),
  ])
}
