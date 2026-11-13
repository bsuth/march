import actors/lobby
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/otp/supervision
import ipc
import lib/anid
import names.{type Names}
import yuzu

type State {
  State(
    lobbies: Dict(String, Subject(ipc.Lobby)),
    names: Names,
    selector: process.Selector(ipc.LobbyManager),
  )
}

pub fn supervised(names: Names) {
  supervision.supervisor(fn() {
    actor.new_with_initialiser(100, fn(default_subject) {
      let selector =
        process.new_selector()
        |> process.select(default_subject)

      State(lobbies: dict.new(), names:, selector:)
      |> actor.initialised()
      |> actor.selecting(selector)
      |> Ok()
    })
    |> actor.named(names.lobby_manager)
    |> actor.on_message(on_message)
    |> actor.start()
  })
}

// -----------------------------------------------------------------------------
// Messages
// -----------------------------------------------------------------------------

fn on_message(state: State, message: ipc.LobbyManager) {
  case message {
    ipc.LobbyManagerDelete(lobby_id) -> on_delete(state, lobby_id)
    ipc.LobbyManagerForward(lobby_id, lobby_message) ->
      on_forward(state, lobby_id, lobby_message)
    ipc.LobbyManagerNew(sender, owner_user_id) ->
      on_new(state, sender, owner_user_id)
  }
}

fn on_delete(state: State, lobby_id: String) {
  State(..state, lobbies: dict.delete(state.lobbies, lobby_id))
  |> actor.continue()
}

fn on_forward(state: State, lobby_id: String, lobby_message: ipc.Lobby) {
  use match_subject <- yuzu.ok(
    dict.get(state.lobbies, lobby_id),
    actor.continue(state),
  )

  process.send(match_subject, lobby_message)
  actor.continue(state)
}

fn on_new(state: State, sender: Subject(String), owner_user_id: String) {
  let assert Ok(lobby_id) = new_lobby_id(state, 16)

  use actor.Started(lobby_actor_pid, lobby_actor_state) <- yuzu.ok(
    lobby.start(lobby_id, state.names, owner_user_id),
    actor.continue(state),
  )

  process.send(sender, lobby_id)

  let lobbies = dict.insert(state.lobbies, lobby_id, lobby_actor_state.subject)
  let selector =
    process.select_specific_monitor(
      state.selector,
      process.monitor(lobby_actor_pid),
      fn(_) { ipc.LobbyManagerDelete(lobby_id) },
    )

  State(..state, lobbies:, selector:)
  |> actor.continue()
  |> actor.with_selector(selector)
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn new_lobby_id(state: State, attempts: Int) {
  use <- yuzu.true(attempts > 0, Error("failed to generate new lobby id"))

  let lobby_id = anid.random(8)

  case dict.has_key(state.lobbies, lobby_id) {
    True -> new_lobby_id(state, attempts - 1)
    False -> Ok(lobby_id)
  }
}
