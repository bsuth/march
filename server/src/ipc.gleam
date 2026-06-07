import gleam/erlang/process.{type Subject}

pub type Websocket {
  WebsocketBroadcast(String)
  WebsocketMatched
  WebsocketCreateLobby
}

pub type Matchmaker {
  MatchmakerEnter(Subject(Websocket))
  MatchmakerExit(Subject(Websocket))
}

pub type LobbyState {
  LobbyState(id: String)
}

pub type Lobby {
  LobbyGetId(Subject(String))
  LobbyGetState(Subject(LobbyState))
  LobbyEnter(Subject(Websocket))
  LobbyExit(Subject(Websocket))
  LobbyChat(Subject(Websocket), String)
}
