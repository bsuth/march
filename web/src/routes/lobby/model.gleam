import core/lobby.{type Lobby}
import engine/board.{type Board}
import gleam/option.{type Option}
import main/app.{type App}

pub type Model {
  Model(
    app: App,
    board: Board,
    edit_name: Option(String),
    loading_lobby: Bool,
    lobby: Option(Lobby),
    lobby_id: String,
  )
}
