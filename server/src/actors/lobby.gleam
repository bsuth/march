import actors/lobby_registry
import core/yuzu
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor
import ipc
import names.{type Names}

// TODO: when the owner leaves, lobby should self-terminate if disconnected
// for X seconds.

pub type State {
  State(id: String, settings: Settings, clients: List(Subject(ipc.Websocket)))
}

pub type Settings {
  // TODO: owner
  Settings(name: String, public: Bool)
}

pub fn start(names: Names, settings: Settings) {
  actor.new_with_initialiser(100, fn(_) {
    use #(id, subject) <- yuzu.ok(
      lobby_registry.register_self(names),
      Error(""),
    )

    let state = State(id:, settings:, clients: [])

    state
    |> actor.initialised()
    |> actor.selecting(process.new_selector() |> process.select(subject))
    |> actor.returning(state)
    |> Ok()
  })
  |> actor.on_message(handler)
  |> actor.start()
}

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------

fn handler(state: State, message: ipc.Lobby) {
  case message {
    ipc.LobbyGetId(client) -> get_id_handler(state, client)
    ipc.LobbyGetState(client) -> get_state_handler(state, client)
    ipc.LobbyEnter(client) -> enter_handler(state, client)
    ipc.LobbyExit(client) -> exit_handler(state, client)
    ipc.LobbyChat(client, text) -> chat_handler(state, client, text)
  }
}

fn get_id_handler(state: State, client: Subject(String)) {
  process.send(client, state.id)
  actor.continue(state)
}

fn get_state_handler(state: State, client: Subject(ipc.LobbyState)) {
  process.send(client, ipc.LobbyState(state.id))
  actor.continue(state)
}

fn enter_handler(state: State, client: Subject(ipc.Websocket)) {
  use <- yuzu.false(list.contains(state.clients, client), actor.continue(state))

  state.clients
  |> list.prepend(client)
  |> fn(clients) { State(..state, clients:) }
  |> actor.continue()
}

fn exit_handler(state: State, client: Subject(ipc.Websocket)) {
  // TODO: kill lobby if everyone leaves
  state.clients
  |> list.filter(fn(element) { element != client })
  |> fn(clients) { State(..state, clients:) }
  |> actor.continue()
}

fn chat_handler(state: State, _client: Subject(ipc.Websocket), _text: String) {
  actor.continue(state)
}
