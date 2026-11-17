import core/engine/board.{type Board}
import core/engine/mode.{type Mode}
import core/lobby.{type Lobby}
import gleam/option.{type Option}
import rsvp

pub type Message {
  ApiLobbyGetResponse(Result(Lobby, rsvp.Error(String)))
  UserChangedBoard(Board)
  UserChangedDoubles(Bool)
  UserChangedHandSize(Int)
  UserChangedMode(Mode)
  UserChangedPlayerUserId(Int, Option(String))
  UserStartedGame
  UserTerminatedLobby
}
