import gleam/uri.{type Uri}
import http_api/http_init
import routes/home/message as home
import routes/learn/message as learn
import routes/lobby/message as lobby
import rsvp

pub type Message {
  ApiInitGetResponse(Result(http_init.GetResponse, rsvp.Error(String)))
  Home(home.Message)
  Learn(learn.Message)
  Lobby(lobby.Message)
  RouterChangedUri(Uri)
  WebsocketClose
  WebsocketError
  WebsocketOpen
  WebsocketMessage(String)
}
