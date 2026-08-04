import http_api/http_lobby
import rsvp

pub type Message {
  ApiLobbyPostResponse(Result(http_lobby.PostResponse, rsvp.Error(String)))
  SubmitLobbyPostRequest
  UpdateLobbyPostRequest(http_lobby.PostRequest)
}
