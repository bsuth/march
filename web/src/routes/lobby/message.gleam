import core/lobby.{type Lobby}
import engine/board.{type Board}
import engine/face.{type Face}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
import rsvp

pub type Message {
  ApiLobbyGetResponse(Result(Lobby, rsvp.Error(String)))
  UserChangedBoard(Board)
  UserChangedDoubles(Bool)
  UserChangedEditName(String)
  UserChangedHandSize(Int)
  UserChangedPlayer(String, Int)
  UserChangedTraits(Dict(Face, List(Trait)))
  UserChangedVisibility(Bool)
  UserDiscardedEditName
  UserEnabledEditName
  UserSavedEditName
  UserStartedGame
  UserTerminatedLobby
}
