import core/lobby.{type Lobby}
import engine/board.{type Board}
import engine/face.{type Face}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
import gleam/option.{type Option}
import rsvp

pub type Message {
  ApiLobbyGetResponse(Result(Lobby, rsvp.Error(String)))
  UserChangedBoard(Board)
  UserChangedDoubles(Bool)
  UserChangedEditName(String)
  UserChangedHandSize(Int)
  UserChangedPlayer(Int, Option(String))
  UserChangedTraits(Dict(Face, List(Trait)))
  UserChangedVisibility(Bool)
  UserDiscardedEditName
  UserEnabledEditName
  UserSavedEditName
  UserStartedGame
  UserTerminatedLobby
}
