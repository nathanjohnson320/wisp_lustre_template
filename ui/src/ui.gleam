import config
import gleam/uri.{type Uri}
import lustre
import lustre/attribute.{class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import pages/home
import pages/terminal
import pages/terminal_design

// MAIN ------------------------------------------------------------------------

pub fn main(pathname: String) {
  let assert Ok(uri) = uri.parse(pathname)
  let app = lustre.application(init, update, view)
  let assert Ok(_) =
    lustre.start(app, "#app", Flags("http://localhost:9999", uri))
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    current_route: Route,
    config: config.Config,
    home: home.Model,
    terminal: terminal.Model,
    terminal_design: terminal_design.Model,
  )
}

type Route {
  Home
  Terminal
  TerminalDesign
  NotFound
}

type Flags {
  Flags(api_url: String, current_path: Uri)
}

fn init(flags: Flags) -> #(Model, Effect(Msg)) {
  let config = config.Config(api_url: flags.api_url)
  let current_route = parse_route(flags.current_path)

  #(
    Model(
      current_route: current_route,
      config: config,
      home: home.init(config),
      terminal: terminal.init(config),
      terminal_design: terminal_design.init(config),
    ),
    effect.batch([
      modem.init(on_route_change),
      route_effect(config, current_route),
    ]),
  )
}

fn parse_route(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    [] -> Home
    ["terminal"] -> Terminal
    ["design", ..design] -> {
      case design {
        ["terminal"] -> TerminalDesign
        _ -> NotFound
      }
    }
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
  TerminalMsg(terminal.Msg)
  TerminalDesignMsg(terminal_design.Msg)
}

fn route_effect(config: config.Config, route: Route) -> Effect(Msg) {
  case route {
    Home -> effect.map(home.on_load(config), HomeMsg)
    Terminal -> effect.map(terminal.on_load(config), TerminalMsg)
    TerminalDesign ->
      effect.map(terminal_design.on_load(config), TerminalDesignMsg)
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
    TerminalMsg(terminal_msg) -> {
      let #(terminal_model, terminal_effect) =
        terminal.update(terminal_msg, model.terminal)
      #(
        Model(..model, terminal: terminal_model),
        effect.map(terminal_effect, TerminalMsg),
      )
    }
    TerminalDesignMsg(terminal_design_msg) -> {
      let #(terminal_design_model, terminal_design_effect) =
        terminal_design.update(terminal_design_msg, model.terminal_design)
      #(
        Model(..model, terminal_design: terminal_design_model),
        effect.map(terminal_design_effect, TerminalDesignMsg),
      )
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
    Terminal ->
      model.terminal
      |> terminal.view()
      |> element.map(TerminalMsg)
    TerminalDesign ->
      model.terminal_design
      |> terminal_design.view()
      |> element.map(TerminalDesignMsg)
    NotFound -> html.div([], [html.text("Not found")])
  }

  layout([page])
}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html.main([class("w-full h-dvh")], elements)
}
