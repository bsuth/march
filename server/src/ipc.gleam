import engine/variant.{type Variant}
import entities/lobby_entity.{type LobbyEntity}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}

pub type Websocket {
  WebsocketMatched
  WebsocketJson(Json)
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
