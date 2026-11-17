import gleam/erlang/process
import gleam/list
import gleam/otp/actor
import gleam/otp/supervision
import ipc
import names.{type Names}
import yuzu

type State =
  List(process.Subject(ipc.Websocket))

pub fn supervised(names: Names) {
  supervision.supervisor(fn() {
    []
    |> actor.new()
    |> actor.named(names.matchmaker)
    |> actor.on_message(on_message)
    |> actor.start()
  })
}

// -----------------------------------------------------------------------------
// Messages
// -----------------------------------------------------------------------------

fn on_message(state: State, message: ipc.Matchmaker) {
  case message {
    ipc.MatchmakerEnter(player) -> on_enter(state, player)
    ipc.MatchmakerExit(player) -> on_exit(state, player)
  }
}

fn on_enter(state: State, player: process.Subject(ipc.Websocket)) {
  use <- yuzu.false(list.contains(state, player), actor.continue(state))

  case list.find(state, check_match(_, player)) {
    Ok(opponent) -> {
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

fn on_exit(state: State, player: process.Subject(ipc.Websocket)) {
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
