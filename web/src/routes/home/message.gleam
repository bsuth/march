import core/http_api/http_lobby
import core/lobby.{type Lobby}
import rsvp

pub type Message {
  ApiLobbyListGetResponse(Result(List(Lobby), rsvp.Error(String)))
  ApiLobbyPostResponse(Result(Lobby, rsvp.Error(String)))
  SubmitLobbyPostRequest
  UpdateLobbyPostRequest(http_lobby.PostRequest)
  UserClickedLobby(Lobby)
  UserRefreshedLobbyList
}
