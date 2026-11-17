import rsvp

pub type Message {
  ApiLobbyPostResponse(Result(String, rsvp.Error(String)))
  HeroEngineResolveTimeout
  HeroEngineSetTimeout(Int)
  SubmitLobbyPostRequest
}
