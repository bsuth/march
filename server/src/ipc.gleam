import core/engine/board.{type Board}
import core/engine/face.{type Face}
import core/engine/settings.{type Settings}
import core/engine/trait.{type Trait}
import core/engine/turn
import core/lobby.{type Lobby as CoreLobby}
import core/match.{type Match as CoreMatch}
import core/user.{type User}
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/option.{type Option}

pub type Lobby {
  LobbyEnter(User, Subject(Websocket))
  LobbyExit(String)
  LobbyGet(Subject(CoreLobby))
  LobbyShutdown
  LobbyStart(String)
  LobbyTerminate(String)
  LobbyUpdateBoard(String, Board)
  LobbyUpdateDoubles(String, Bool)
  LobbyUpdateHandSize(String, Int)
  LobbyUpdatePlayerUserId(String, Int, Option(String))
  LobbyUpdateTraits(String, Dict(Face, List(Trait)))
}

pub type LobbyManager {
  LobbyManagerDelete(String)
  LobbyManagerForward(String, Lobby)
  LobbyManagerNew(Subject(String), String)
}

pub type Match {
  MatchEnter(User, Subject(Websocket))
  MatchExit(String)
  MatchGet(Subject(CoreMatch))
  MatchRequestTurn(String, turn.Request)
}

pub type MatchManager {
  MatchManagerDelete(String)
  MatchManagerForward(String, Match)
  MatchManagerNew(Subject(String), Settings, List(String))
}

pub type Matchmaker {
  MatchmakerEnter(Subject(Websocket))
  MatchmakerExit(Subject(Websocket))
}

pub type Websocket {
  WebsocketMatched
  WebsocketJson(Json)
}
