import core/lobby.{type Lobby as LobbyState}
import core/match.{type Match as MatchState}
import core/user.{type User}
import engine/variant.{type Variant}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/option.{type Option}

pub type Lobby {
  LobbyEnter(User, Subject(Websocket))
  LobbyExit(String)
  LobbyGet(Subject(LobbyState))
  LobbyStart(String)
  LobbyTerminate(String)
  LobbyUpdateBlack(request_user_id: String, black_user_id: Option(String))
  LobbyUpdateBoard(request_user_id: String, width: Int, height: Int)
  LobbyUpdateName(request_user_id: String, name: String)
  LobbyUpdateVariant(request_user_id: String, variant: Variant)
  LobbyUpdateVisibility(request_user_id: String, visible: Bool)
  LobbyUpdateWhite(request_user_id: String, white_user_id: Option(String))
  LobbyShutdown
}

pub type Match {
  MatchEnter(User, Subject(Websocket))
  MatchExit(String)
  MatchGet(Subject(MatchState))
}

pub type Matchmaker {
  MatchmakerEnter(Subject(Websocket))
  MatchmakerExit(Subject(Websocket))
}

pub type Websocket {
  WebsocketMatched
  WebsocketJson(Json)
}
