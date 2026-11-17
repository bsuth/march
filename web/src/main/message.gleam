import core/user.{type User}
import gleam/uri.{type Uri}
import routes/home/message as home
import routes/learn/message as learn
import routes/lobby/message as lobby
import routes/match/message as match
import routes/play/message as play
import routes/playground/message as playground
import rsvp

pub type Message {
  Home(home.Message)
  Learn(learn.Message)
  Lobby(lobby.Message)
  Match(match.Message)
  Play(play.Message)
  Playground(playground.Message)

  ApiInitGetResponse(Result(User, rsvp.Error(String)))
  RouterChangedUri(Uri)
  ToggleTheme
  WebsocketClose
  WebsocketError
  WebsocketOpen
  WebsocketMessage(String)
}
