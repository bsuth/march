import core/yuzu
import gleam/erlang/process
import gleam/list
import gleam/otp/actor
import gleam/otp/supervision
import ipc
import names.{type Names}

type State =
  List(process.Subject(ipc.Websocket))

pub fn supervised(names: Names) {
  supervision.supervisor(fn() {
    []
    |> actor.new()
    |> actor.named(names.matchmaker)
    |> actor.on_message(handler)
    |> actor.start()
  })
}

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------

fn handler(state: State, message: ipc.Matchmaker) {
  case message {
    ipc.MatchmakerEnter(player) -> enter_handler(state, player)
    ipc.MatchmakerExit(player) -> exit_handler(state, player)
  }
}

fn enter_handler(state: State, player: process.Subject(ipc.Websocket)) {
  use <- yuzu.false(list.contains(state, player), actor.continue(state))

  case list.find(state, check_match(_, player)) {
    Ok(opponent) -> {
      process.send(player, ipc.WebsocketMatched)
      process.send(opponent, ipc.WebsocketMatched)

      state
      |> list.filter(fn(element) { element != opponent })
      |> actor.continue()
    }

    Error(Nil) -> {
      [player]
      |> list.append(state, _)
      |> actor.continue()
    }
  }
}

fn exit_handler(state: State, player: process.Subject(ipc.Websocket)) {
  state
  |> list.filter(fn(element) { element != player })
  |> actor.continue()
}

// -----------------------------------------------------------------------------
// Matchmaking
// -----------------------------------------------------------------------------

fn check_match(
  a: process.Subject(ipc.Websocket),
  b: process.Subject(ipc.Websocket),
) {
  // TODO: implement real matchmaker function
  a != b
}
