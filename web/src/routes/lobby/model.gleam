import entities/lobby_entity.{type LobbyEntity}
import gleam/option.{type Option}
import main/app.{type App}

pub type Model {
  Model(
    app: App,
    lobby_id: String,
    lobby: Option(LobbyEntity),
    edit_name: Option(String),
  )
}
