import core/lobby.{type Lobby}
import engine/variant.{type Variant}
import gleam/option.{type Option}
import rsvp

pub type Message {
  ApiLobbyGetResponse(Result(Lobby, rsvp.Error(String)))
  UserChangedBlack(Option(String))
  UserChangedBoard(Int, Int)
  UserChangedEditName(String)
  UserChangedVariant(Variant)
  UserChangedVisibility(Bool)
  UserChangedWhite(Option(String))
  UserDiscardedEditName
  UserEnabledEditName
  UserSavedEditName
  UserStartedGame
  UserTerminatedLobby
}
