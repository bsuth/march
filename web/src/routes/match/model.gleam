import core/match.{type Match}
import gleam/option.{type Option}
import main/app.{type App}

pub type Model {
  Model(app: App, loading_match: Bool, match: Option(Match), match_id: String)
}
