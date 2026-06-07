import gleam/uri.{type Uri}

pub type Message {
  RouterChangedUri(Uri)
  RouterLoadedLobby(String)
  UserCreatedLobby
  WebsocketMessage(String)
}
