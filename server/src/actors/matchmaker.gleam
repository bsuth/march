import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor
import ws_custom.{type WebsocketCustom}

type State =
  List(Subject(WebsocketCustom))

pub fn start() {
  []
  |> actor.new()
  |> actor.on_message(handle_message)
  |> actor.start()
}

// -----------------------------------------------------------------------------
// Messages
// -----------------------------------------------------------------------------

pub type Message {
  Enter(Subject(WebsocketCustom))
  Exit(Subject(WebsocketCustom))
}

fn handle_message(state: State, message: Message) {
  case message {
    Enter(player) -> handle_enter(state, player)
    Exit(player) -> handle_exit(state, player)
  }
}

fn handle_enter(state: State, player: Subject(WebsocketCustom)) {
  case list.find(state, check_match(_, player)) {
    Ok(opponent) -> {
      process.send(player, ws_custom.Matched)
      process.send(opponent, ws_custom.Matched)

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

fn handle_exit(state: State, player: Subject(WebsocketCustom)) {
  state
  |> list.filter(fn(element) { element != player })
  |> actor.continue()
}

// -----------------------------------------------------------------------------
// Matchmaking
// -----------------------------------------------------------------------------

fn check_match(a: Subject(WebsocketCustom), b: Subject(WebsocketCustom)) {
  // TODO: implement real matchmaker function
  a != b
}
