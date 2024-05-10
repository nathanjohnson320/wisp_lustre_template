import gleam/uri.{type Uri}
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import pages/home

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Flags("http://localhost:8000"))
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(current_route: Route, api_host: String, home: home.Model)
}

type Route {
  Home
}

type Flags {
  Flags(api_host: String)
}

fn init(flags: Flags) -> #(Model, Effect(Msg)) {
  let api_host = flags.api_host
  #(
    Model(current_route: Home, api_host: api_host, home: home.init(api_host)),
    modem.init(on_route_change),
  )
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
  html.main([], elements)
}
