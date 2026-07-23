import api
import gleam/uri.{type Uri}
import lib/websocket.{type Websocket}
import routes/home/message as home
import routes/learn/message as learn
import routes/lobby/message as lobby
import rsvp

pub type Message {
  ApiReturnedInit(Result(api.GetInitResponse, rsvp.Error(String)))
  Home(home.Message)
  Learn(learn.Message)
  Lobby(lobby.Message)
  RouterChangedUri(Uri)
  WebsocketClose
  WebsocketError
  WebsocketOpen(Websocket)
  WebsocketMessage(String)
}
