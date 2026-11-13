import core/engine/board.{type Board}
import core/engine/face.{type Face}
import core/engine/trait.{type Trait}
import core/lobby.{type Lobby}
import gleam/dict.{type Dict}
import gleam/option.{type Option}
import rsvp

pub type Message {
  ApiLobbyGetResponse(Result(Lobby, rsvp.Error(String)))
  UserChangedBoard(Board)
  UserChangedDoubles(Bool)
  UserChangedHandSize(Int)
  UserChangedPlayerUserId(Int, Option(String))
  UserChangedTraits(Dict(Face, List(Trait)))
  UserStartedGame
  UserTerminatedLobby
}
