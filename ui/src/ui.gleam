import gleam/uri.{type Uri}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import pages/home

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(current_route: Route, home: home.Model)
}

type Route {
  Home
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model(current_route: Home, home: home.init()), modem.init(on_route_change))
}

fn on_route_change(uri: Uri) -> Msg {
  case uri.path_segments(uri.path) {
    _ -> OnRouteChange(Home)
  }
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  OnRouteChange(Route)
  HomeMsg(home.Msg)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    OnRouteChange(route) -> #(
      Model(..model, current_route: route),
      effect.none(),
    )
    HomeMsg(home_msg) -> {
      let #(home_model, home_effect) = home.update(home_msg, model.home)
      #(Model(..model, home: home_model), effect.map(home_effect, HomeMsg))
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let page = case model.current_route {
    Home ->
      model.home
      |> home.view()
      |> element.map(HomeMsg)
  }

  layout([page])
}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html.html([], [
    html.head([], [
      html.title([], "Todo App in Gleam"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.link([attribute.rel("stylesheet"), attribute.href("/static/app.css")]),
    ]),
    html.body([], elements),
  ])
}
