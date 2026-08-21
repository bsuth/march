import actors/lobby_registry
import actors/match
import core/lobby.{type Lobby, Lobby}
import core/user.{type User}
import engine/variant.{type Variant}
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor
import ipc
import names.{type Names}
import ws_api/ws_lobby
import yuzu

// TODO: auto terminate lobby after X seconds when the owner leaves

pub type StartArgs {
  StartArgs(
    board_height: Int,
    board_width: Int,
    name: String,
    owner: User,
    variant: Variant,
    visible: Bool,
  )
}

pub type LobbyActor {
  LobbyActor(
    lobby: Lobby,
    meta: Dict(String, LobbyActorUserMeta),
    names: Names,
    selector: process.Selector(ipc.Lobby),
  )
}

pub type LobbyActorUserMeta {
  LobbyActorUserMeta(subject: Subject(ipc.Websocket), monitor: process.Monitor)
}

pub fn start(names: Names, args: StartArgs) {
  actor.new_with_initialiser(100, fn(_) {
    let #(id, subjects) = lobby_registry.register_self(names)

    let lobby =
      Lobby(
        id:,
        black: option.None,
        board_height: args.board_height,
        board_width: args.board_width,
        match_id: option.None,
        name: args.name,
        owner: args.owner,
        users: [],
        variant: args.variant,
        visible: args.visible,
        white: option.None,
      )

    let selector = list.fold(subjects, process.new_selector(), process.select)
    let state = LobbyActor(lobby:, meta: dict.new(), names:, selector:)

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

fn handler(state: LobbyActor, message: ipc.Lobby) {
  case message {
    ipc.LobbyEnter(user, subject) -> enter_handler(state, user, subject)
    ipc.LobbyExit(id) -> exit_handler(state, id)
    ipc.LobbyGet(requester) -> get_handler(state, requester)
    ipc.LobbyStart(id) -> start_handler(state, id)
    ipc.LobbyTerminate(id) -> terminate_handler(state, id)
    ipc.LobbyUpdateBlack(request_user_id, black_user_id) ->
      update_black_handler(state, request_user_id, black_user_id)
    ipc.LobbyUpdateBoard(request_user_id, board_width, board_height) ->
      update_board_handler(state, request_user_id, board_width, board_height)
    ipc.LobbyUpdateName(request_user_id, name) ->
      update_name_handler(state, request_user_id, name)
    ipc.LobbyUpdateVariant(request_user_id, variant) ->
      update_variant_handler(state, request_user_id, variant)
    ipc.LobbyUpdateVisibility(request_user_id, visible) ->
      update_visibility_handler(state, request_user_id, visible)
    ipc.LobbyUpdateWhite(request_user_id, white_user_id) ->
      update_white_handler(state, request_user_id, white_user_id)
    ipc.LobbyShutdown -> actor.stop()
  }
}

fn enter_handler(
  state: LobbyActor,
  enter_user: User,
  enter_user_subject: Subject(ipc.Websocket),
) {
  use <- yuzu.false(
    list.any(state.lobby.users, fn(user) { user.id == enter_user.id }),
    actor.continue(state),
  )

  use user_pid <- yuzu.ok(
    process.subject_owner(enter_user_subject),
    actor.continue(state),
  )

  let monitor = process.monitor(user_pid)

  let meta =
    dict.insert(
      state.meta,
      enter_user.id,
      LobbyActorUserMeta(subject: enter_user_subject, monitor:),
    )

  ws_lobby.EnteredPayload(state.lobby.id, enter_user)
  |> ws_lobby.entered_json()
  |> broadcast_json(meta, _)

  let selector =
    process.select_specific_monitor(state.selector, monitor, fn(_) {
      ipc.LobbyExit(enter_user.id)
    })

  LobbyActor(
    ..state,
    lobby: Lobby(
      ..state.lobby,
      users: list.prepend(state.lobby.users, enter_user),
    ),
    meta:,
    selector:,
  )
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn exit_handler(state: LobbyActor, exit_user_id: String) {
  use exit_user_meta <- yuzu.ok(
    dict.get(state.meta, exit_user_id),
    actor.continue(state),
  )

  let meta = dict.delete(state.meta, exit_user_id)

  ws_lobby.ExitedPayload(state.lobby.id, exit_user_id)
  |> ws_lobby.exited_json()
  |> broadcast_json(meta, _)

  let selector =
    process.deselect_specific_monitor(state.selector, exit_user_meta.monitor)

  process.demonitor_process(exit_user_meta.monitor)

  LobbyActor(
    ..state,
    lobby: lobby.remove_user(state.lobby, exit_user_id),
    meta:,
    selector:,
  )
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn get_handler(state: LobbyActor, requester: Subject(Lobby)) {
  process.send(requester, state.lobby)
  actor.continue(state)
}

fn start_handler(state: LobbyActor, request_user_id: String) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  use black <- yuzu.some(state.lobby.black, actor.continue(state))
  use white <- yuzu.some(state.lobby.white, actor.continue(state))

  use actor.Started(match_actor_pid, match_actor_state) <- yuzu.ok(
    match.start(
      state.names,
      match.StartArgs(
        black:,
        board_height: state.lobby.board_height,
        board_width: state.lobby.board_width,
        // TODO: make this configurable
        hand_size: 4,
        variant: state.lobby.variant,
        visible: state.lobby.visible,
        white:,
      ),
    ),
    actor.continue(state),
  )

  ws_lobby.StartedPayload(state.lobby.id, match_actor_state.match.id)
  |> ws_lobby.started_json()
  |> broadcast_json(state.meta, _)

  let selector =
    process.select_specific_monitor(
      state.selector,
      process.monitor(match_actor_pid),
      fn(_) { ipc.LobbyShutdown },
    )

  LobbyActor(
    ..state,
    lobby: Lobby(
      ..state.lobby,
      match_id: option.Some(match_actor_state.match.id),
    ),
    selector:,
  )
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn terminate_handler(state: LobbyActor, request_user_id: String) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  state.lobby.id
  |> ws_lobby.terminated_json()
  |> broadcast_json(state.meta, _)

  actor.stop()
}

fn update_black_handler(
  state: LobbyActor,
  request_user_id: String,
  black_user_id: Option(String),
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  use lobby <- yuzu.ok(
    lobby.assign_black(state.lobby, black_user_id),
    actor.continue(state),
  )

  ws_lobby.UpdateBlackPayload(state.lobby.id, black_user_id)
  |> ws_lobby.update_black_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby:)
  |> actor.continue()
}

fn update_board_handler(
  state: LobbyActor,
  request_user_id: String,
  board_width: Int,
  board_height: Int,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateBoardPayload(state.lobby.id, board_width, board_height)
  |> ws_lobby.update_board_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby: Lobby(..state.lobby, board_width:, board_height:))
  |> actor.continue()
}

fn update_name_handler(
  state: LobbyActor,
  request_user_id: String,
  name: String,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateNamePayload(state.lobby.id, name)
  |> ws_lobby.update_name_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby: Lobby(..state.lobby, name:))
  |> actor.continue()
}

fn update_variant_handler(
  state: LobbyActor,
  request_user_id: String,
  variant: Variant,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateVariantPayload(state.lobby.id, variant)
  |> ws_lobby.update_variant_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby: Lobby(..state.lobby, variant:))
  |> actor.continue()
}

fn update_visibility_handler(
  state: LobbyActor,
  request_user_id: String,
  visible: Bool,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateVisibilityPayload(state.lobby.id, visible)
  |> ws_lobby.update_visibility_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby: Lobby(..state.lobby, visible:))
  |> actor.continue()
}

fn update_white_handler(
  state: LobbyActor,
  request_user_id: String,
  white_user_id: Option(String),
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  use lobby <- yuzu.ok(
    lobby.assign_white(state.lobby, white_user_id),
    actor.continue(state),
  )

  ws_lobby.UpdateWhitePayload(state.lobby.id, white_user_id)
  |> ws_lobby.update_white_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby:)
  |> actor.continue()
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn broadcast_json(meta: Dict(String, LobbyActorUserMeta), payload: Json) {
  dict.each(meta, fn(_, user_meta) {
    process.send(user_meta.subject, ipc.WebsocketJson(payload))
  })
}
