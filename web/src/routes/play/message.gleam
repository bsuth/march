import rsvp

pub type Message {
  ApiLobbyPostResponse(Result(String, rsvp.Error(String)))
  EnterClassicMatchmaking
  EnterDoublesMatchmaking
  EnterStandardMatchmaking
  CreateCustomLobby
  SubmitLobbyPostRequest
}
