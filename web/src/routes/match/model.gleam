import core/match.{type Match}
import engine/color.{type Color}
import gleam/option.{type Option}
import main/app.{type App}

pub type Model {
  Model(
    app: App,
    color: Color,
    loading_match: Bool,
    match: Option(Match),
    match_id: String,
  )
}
