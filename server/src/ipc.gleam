import core/engine/board.{type Board}
import core/engine/mode.{type Mode}
import core/engine/settings.{type Settings as EngineSettings}
import core/engine/turn
import core/lobby.{type Lobby as CoreLobby}
import core/match.{type Match as CoreMatch}
import core/user.{type User}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/option.{type Option}

pub type Lobby {
  LobbyEnter(enter_user: User, enter_user_subject: Subject(Websocket))
  LobbyExit(exit_user_id: String)
  LobbyGet(reply_subject: Subject(CoreLobby))
  LobbyKill
  LobbyUpdateBoard(request_user_id: String, board: Board)
  LobbyUpdateDoubles(request_user_id: String, doubles: Bool)
  LobbyUpdateHandSize(request_user_id: String, hand_size: Int)
  LobbyUpdateMode(request_user_id: String, mode: Mode)
  LobbyUpdatePlayerUserId(
    request_user_id: String,
    player_index: Int,
    user_id: Option(String),
  )
  LobbyStart(request_user_id: String)
  LobbyTerminate(request_user_id: String)
}

pub type LobbyManager {
  LobbyManagerDelete(lobby_id: String)
  LobbyManagerForward(lobby_id: String, message: Lobby)
  LobbyManagerNew(
    reply_subject: Subject(String),
    owner_user_id: String,
    engine_settings: EngineSettings,
  )
}

pub type Match {
  MatchEnter(enter_user: User, enter_user_subject: Subject(Websocket))
  MatchExit(exit_user_id: String)
  MatchGet(reply_subject: Subject(CoreMatch))
  MatchRequestTurn(request_user_id: String, turn_request: turn.Request)
}

pub type MatchManager {
  MatchManagerDelete(match_id: String)
  MatchManagerForward(match_id: String, message: Match)
  MatchManagerNew(
    reply_subject: Subject(String),
    engine_settings: EngineSettings,
    player_user_ids: List(String),
  )
}

pub type Matchmaker {
  MatchmakerEnter(Subject(Websocket))
  MatchmakerExit(Subject(Websocket))
}

pub type Websocket {
  WebsocketJson(Json)
}
