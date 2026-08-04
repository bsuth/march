import engine/variant.{type Variant}
import entities/lobby_entity.{type LobbyEntity}
import gleam/erlang/process.{type Subject}

pub type Websocket {
  WebsocketMatched
  WebsocketLobbyUpdate(LobbyEntity)
  WebsocketLobbyUpdateBoard(lobby_id: String, width: Int, height: Int)
  WebsocketLobbyUpdateName(lobby_id: String, lobby_name: String)
  WebsocketLobbyUpdateVariant(lobby_id: String, variant: Variant)
  WebsocketLobbyUpdateVisibility(lobby_id: String, visible: Bool)
}

pub type Matchmaker {
  MatchmakerEnter(Subject(Websocket))
  MatchmakerExit(Subject(Websocket))
}

pub type Lobby {
  LobbyGet(Subject(LobbyEntity))
  LobbyEnter(String, Subject(Websocket))
  LobbyExit(String)
  LobbyUpdate(LobbyEntity)
  LobbyUpdateBoard(width: Int, height: Int)
  LobbyUpdateName(String)
  LobbyUpdateVariant(Variant)
  LobbyUpdateVisibility(Bool)
}
