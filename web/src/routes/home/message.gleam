import api
import rsvp

pub type Message {
  ApiPostLobbyResponse(Result(api.PostLobbyResponse, rsvp.Error(String)))
  SubmitPostLobbyRequest
  UpdatePostLobbyRequest(api.PostLobbyRequest)
}
