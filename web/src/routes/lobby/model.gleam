import core/lobby.{type Lobby}
import gleam/option.{type Option}
import main/app.{type App}

pub type Model {
  Model(
    app: App,
    edit_name: Option(String),
    lobby: Option(Lobby),
    lobby_id: String,
    lobby_loading: Bool,
  )
}
