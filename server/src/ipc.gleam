import core/engine/board.{type Board}
import core/engine/face.{type Face}
import core/engine/trait.{type Trait}
import core/engine/turn
import core/lobby.{type Lobby as LobbyState}
import core/match.{type Match as MatchState}
import core/user.{type User}
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/option.{type Option}

pub type Lobby {
  LobbyEnter(User, Subject(Websocket))
  LobbyExit(String)
  LobbyGet(Subject(LobbyState))
  LobbyShutdown
  LobbyStart(String)
  LobbyTerminate(String)
  LobbyUpdateBoard(request_user_id: String, board: Board)
  LobbyUpdateDoubles(request_user_id: String, doubles: Bool)
  LobbyUpdateHandSize(request_user_id: String, hand_size: Int)
  LobbyUpdateName(request_user_id: String, name: String)
  LobbyUpdatePlayer(
    request_user_id: String,
    player_index: Int,
    user_id: Option(String),
  )
  LobbyUpdateTraits(request_user_id: String, traits: Dict(Face, List(Trait)))
  LobbyUpdateVisibility(request_user_id: String, visible: Bool)
}

pub type Match {
  MatchEnter(User, Subject(Websocket))
  MatchExit(String)
  MatchGet(Subject(MatchState))
  MatchRequestTurn(String, turn.Request)
}

pub type Matchmaker {
  MatchmakerEnter(Subject(Websocket))
  MatchmakerExit(Subject(Websocket))
}

pub type Websocket {
  WebsocketMatched
  WebsocketJson(Json)
}
