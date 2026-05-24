import gleam/result
import gleam/uri
import lustre/attribute.{type Attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import modem
import routes.{type Route}
import routes/cheatsheet
import routes/home
import routes/learn
import routes/not_found
import routes/versus
import x.{type Model, type Msg}

pub fn init() -> #(Route, Effect(Msg)) {
  #(
    modem.initial_uri()
      |> result.map(fn(uri) { uri.path_segments(uri.path) })
      |> fn(path) {
        case path {
          Ok([]) -> routes.Home
          Ok(["learn"]) -> routes.Learn
          Ok(["cheatsheet"]) -> routes.CheatSheet
          Ok(["versus"]) -> routes.Versus
          _ -> routes.NotFound
        }
      },
    modem.init(on_url_change),
  )
}

pub fn view(model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  case model.route {
    routes.Home -> home.view(model, attrs)
    routes.Learn -> learn.element(attrs)
    routes.CheatSheet -> cheatsheet.view(model, attrs)
    routes.Versus -> versus.view(model, attrs)
    _ -> not_found.view(model, attrs)
  }
}

fn on_url_change(uri: uri.Uri) -> Msg {
  case uri.path_segments(uri.path) {
    [] -> x.OnRouteChange(routes.Home)
    ["learn"] -> x.OnRouteChange(routes.Learn)
    ["cheatsheet"] -> x.OnRouteChange(routes.CheatSheet)
    ["versus"] -> x.OnRouteChange(routes.Versus)
    _ -> x.OnRouteChange(routes.NotFound)
  }
}
