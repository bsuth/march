import actors/lobby_registry
import engine/variant.{type Variant}
import entities/lobby_entity.{type LobbyEntity, LobbyEntity}
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor
import ipc
import names.{type Names}
import ws_api/ws_lobby
import yuzu

// TODO: terminate lobby after X seconds when the owner leaves

pub type State {
  State(
    id: String,
    selector: process.Selector(ipc.Lobby),
    settings: Settings,
    users: List(LobbyUser),
  )
}

// TODO: move settings to separate LobbySettings entity
pub type Settings {
  Settings(
    owner_user_id: String,
    black_user_id: Option(String),
    white_user_id: Option(String),
    name: String,
    // TODO: rename to `visible`
    is_public: Bool,
    variant: Variant,
    board_width: Int,
    board_height: Int,
  )
}

pub type LobbyUser {
  LobbyUser(
    id: String,
    subject: Subject(ipc.Websocket),
    monitor: process.Monitor,
  )
}

pub fn start(names: Names, settings: Settings) {
  actor.new_with_initialiser(100, fn(_) {
    use #(id, subject) <- yuzu.ok(
      lobby_registry.register_self(names),
      Error(""),
    )

    let selector = process.new_selector() |> process.select(subject)
    let state = State(id:, selector:, settings:, users: [])

    state
    |> actor.initialised()
    |> actor.selecting(selector)
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
    ipc.LobbyGet(requester) -> get_handler(state, requester)
    ipc.LobbyEnter(id, subject) -> enter_handler(state, id, subject)
    ipc.LobbyExit(id) -> exit_handler(state, id)
    ipc.LobbyUpdate(entity) -> update_handler(state, entity)
    ipc.LobbyUpdateBoard(width, height) ->
      update_board_handler(state, width, height)
    ipc.LobbyUpdateName(name) -> update_name_handler(state, name)
    ipc.LobbyUpdateVariant(variant) -> update_variant_handler(state, variant)
    ipc.LobbyUpdateVisibility(visible) ->
      update_visibility_handler(state, visible)
  }
}

fn get_handler(state: State, requester: Subject(LobbyEntity)) {
  process.send(requester, entity(state))
  actor.continue(state)
}

fn enter_handler(
  state: State,
  user_id: String,
  user_subject: Subject(ipc.Websocket),
) {
  use <- yuzu.false(
    list.any(state.users, fn(user) { user.subject == user_subject }),
    actor.continue(state),
  )

  use user_pid <- yuzu.ok(
    process.subject_owner(user_subject),
    actor.continue(state),
  )

  let lobby_user =
    LobbyUser(
      id: user_id,
      subject: user_subject,
      monitor: process.monitor(user_pid),
    )

  let users = list.prepend(state.users, lobby_user)

  let selector =
    process.select_specific_monitor(state.selector, lobby_user.monitor, fn(_) {
      ipc.LobbyExit(user_id)
    })

  list.each(users, fn(user) { send_update(state, user.subject) })

  State(..state, selector:, users:)
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn exit_handler(state: State, id: String) {
  use lobby_user <- yuzu.ok(
    list.find(state.users, fn(user) { user.id == id }),
    actor.continue(state),
  )

  process.demonitor_process(lobby_user.monitor)

  let users = list.filter(state.users, fn(user) { user.id != id })

  let selector =
    process.deselect_specific_monitor(state.selector, lobby_user.monitor)

  list.each(users, fn(user) { send_update(state, user.subject) })

  State(
    ..state,
    selector:,
    users: list.filter(state.users, fn(user) { user.id != id }),
  )
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn update_handler(state: State, entity: LobbyEntity) {
  list.each(state.users, fn(user) {
    process.send(
      user.subject,
      entity
        |> ws_lobby.update_json()
        |> ipc.WebsocketJson(),
    )
  })

  State(
    ..state,
    settings: Settings(
      owner_user_id: entity.owner_user_id,
      black_user_id: entity.black_user_id,
      white_user_id: entity.white_user_id,
      name: entity.name,
      is_public: entity.is_public,
      variant: entity.variant,
      board_width: entity.board_width,
      board_height: entity.board_height,
    ),
  )
  |> actor.continue()
}

fn update_board_handler(state: State, width: Int, height: Int) {
  list.each(state.users, fn(user) {
    process.send(
      user.subject,
      ws_lobby.UpdateBoardPayload(state.id, width, height)
        |> ws_lobby.update_board_json()
        |> ipc.WebsocketJson(),
    )
  })

  State(
    ..state,
    settings: Settings(
      ..state.settings,
      board_width: width,
      board_height: height,
    ),
  )
  |> actor.continue()
}

fn update_name_handler(state: State, name: String) {
  list.each(state.users, fn(user) {
    process.send(
      user.subject,
      ws_lobby.UpdateNamePayload(state.id, name)
        |> ws_lobby.update_name_json()
        |> ipc.WebsocketJson(),
    )
  })

  State(..state, settings: Settings(..state.settings, name:))
  |> actor.continue()
}

fn update_variant_handler(state: State, variant: Variant) {
  list.each(state.users, fn(user) {
    process.send(
      user.subject,
      ws_lobby.UpdateVariantPayload(state.id, variant)
        |> ws_lobby.update_variant_json()
        |> ipc.WebsocketJson(),
    )
  })

  State(..state, settings: Settings(..state.settings, variant:))
  |> actor.continue()
}

fn update_visibility_handler(state: State, visible: Bool) {
  list.each(state.users, fn(user) {
    process.send(
      user.subject,
      ws_lobby.UpdateVisibilityPayload(state.id, visible)
        |> ws_lobby.update_visibility_json()
        |> ipc.WebsocketJson(),
    )
  })

  State(..state, settings: Settings(..state.settings, is_public: visible))
  |> actor.continue()
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn entity(state: State) {
  LobbyEntity(
    id: state.id,
    name: state.settings.name,
    is_public: state.settings.is_public,
    variant: state.settings.variant,
    board_width: state.settings.board_width,
    board_height: state.settings.board_height,
    owner_user_id: state.settings.owner_user_id,
    black_user_id: state.settings.black_user_id,
    white_user_id: state.settings.white_user_id,
    // TODO: spectators
    spectator_user_ids: [],
  )
}

pub fn send_update(state: State, subject: Subject(ipc.Websocket)) {
  process.send(
    subject,
    entity(state)
      |> ws_lobby.update_json()
      |> ipc.WebsocketJson(),
  )
}
