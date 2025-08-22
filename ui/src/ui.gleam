import config
import gleam/uri.{type Uri}
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import pages/home

// MAIN ------------------------------------------------------------------------

pub fn main(pathname: String) {
  let assert Ok(uri) = uri.parse(pathname)
  let app = lustre.application(init, update, view)
  let assert Ok(_) =
    lustre.start(app, "#app", Flags("http://localhost:8080", uri))
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(current_route: Route, config: config.Config, home: home.Model)
}

type Route {
  Home
  NotFound
}

type Flags {
  Flags(api_url: String, current_path: Uri)
}

fn init(flags: Flags) -> #(Model, Effect(Msg)) {
  let config = config.Config(api_url: flags.api_url)
  let current_route = parse_route(flags.current_path)

  #(
    Model(current_route: current_route, config: config, home: home.init(config)),
    effect.batch([
      modem.init(on_route_change),
      route_effect(config, current_route),
    ]),
  )
}

fn parse_route(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    [] -> Home
    _ -> NotFound
  }
}

fn on_route_change(uri: Uri) -> Msg {
  uri
  |> parse_route()
  |> OnRouteChange()
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  OnRouteChange(Route)
  HomeMsg(home.Msg)
}

fn route_effect(config: config.Config, route: Route) -> Effect(Msg) {
  case route {
    Home -> effect.map(home.on_load(config), HomeMsg)
    _ -> effect.none()
  }
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    OnRouteChange(route) -> {
      #(Model(..model, current_route: route), route_effect(model.config, route))
    }
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
    NotFound -> html.div([], [html.text("Not found")])
  }

  layout([page])
}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html.main([], elements)
}
