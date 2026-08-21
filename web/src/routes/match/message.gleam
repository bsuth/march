import core/match.{type Match}
import rsvp

pub type Message {
  ApiMatchGetResponse(Result(Match, rsvp.Error(String)))
  UserEndedTurn
}
