import actors/lobby_registry
import actors/match
import core/lobby.{type Lobby, Lobby}
import core/user.{type User}
import engine/board.{type Board}
import engine/face.{type Face}
import engine/settings.{
  type Settings as EngineSettings, Settings as EngineSettings,
}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/list
import gleam/option
import gleam/otp/actor
import ipc
import names.{type Names}
import ws_api/ws_lobby
import yuzu

// TODO: auto terminate lobby after X seconds when the owner leaves

pub type StartArgs {
  StartArgs(
    engine_settings: EngineSettings,
    name: String,
    owner: User,
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
        engine_settings: args.engine_settings,
        match_id: option.None,
        name: args.name,
        owner: args.owner,
        players: case args.engine_settings.doubles {
          True -> [option.None, option.None, option.None, option.None]
          False -> [option.None, option.None]
        },
        users: [],
        visible: args.visible,
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
    ipc.LobbyUpdateBoard(request_user_id, board) ->
      update_board_handler(state, request_user_id, board)
    ipc.LobbyUpdateDoubles(request_user_id, doubles) ->
      update_doubles_handler(state, request_user_id, doubles)
    ipc.LobbyUpdateHandSize(request_user_id, hand_size) ->
      update_hand_size_handler(state, request_user_id, hand_size)
    ipc.LobbyUpdateName(request_user_id, name) ->
      update_name_handler(state, request_user_id, name)
    ipc.LobbyUpdatePlayer(request_user_id, user_id, player_index) ->
      update_player_handler(state, request_user_id, user_id, player_index)
    ipc.LobbyUpdateTraits(request_user_id, traits) ->
      update_traits_handler(state, request_user_id, traits)
    ipc.LobbyUpdateVisibility(request_user_id, visible) ->
      update_visibility_handler(state, request_user_id, visible)
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

  use players <- yuzu.ok(
    list.try_map(state.lobby.players, fn(player) {
      case player {
        option.None -> Error(Nil)
        option.Some(player) -> Ok(player)
      }
    }),
    actor.continue(state),
  )

  use actor.Started(match_actor_pid, match_actor_state) <- yuzu.ok(
    match.start(
      state.names,
      match.StartArgs(
        engine_settings: state.lobby.engine_settings,
        players:,
        visible: state.lobby.visible,
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

fn update_board_handler(
  state: LobbyActor,
  request_user_id: String,
  board: Board,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateBoardPayload(state.lobby.id, board)
  |> ws_lobby.update_board_json()
  |> broadcast_json(state.meta, _)

  let engine_settings = EngineSettings(..state.lobby.engine_settings, board:)
  let lobby = Lobby(..state.lobby, engine_settings:)

  LobbyActor(..state, lobby:) |> actor.continue()
}

fn update_doubles_handler(
  state: LobbyActor,
  request_user_id: String,
  doubles: Bool,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateDoublesPayload(state.lobby.id, doubles)
  |> ws_lobby.update_doubles_json()
  |> broadcast_json(state.meta, _)

  let engine_settings = EngineSettings(..state.lobby.engine_settings, doubles:)
  let lobby = Lobby(..state.lobby, engine_settings:)

  LobbyActor(..state, lobby:) |> actor.continue()
}

fn update_hand_size_handler(
  state: LobbyActor,
  request_user_id: String,
  hand_size: Int,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateHandSizePayload(state.lobby.id, hand_size)
  |> ws_lobby.update_hand_size_json()
  |> broadcast_json(state.meta, _)

  let engine_settings =
    EngineSettings(..state.lobby.engine_settings, hand_size:)
  let lobby = Lobby(..state.lobby, engine_settings:)

  LobbyActor(..state, lobby:) |> actor.continue()
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

  let lobby = Lobby(..state.lobby, name:)
  LobbyActor(..state, lobby:) |> actor.continue()
}

fn update_player_handler(
  state: LobbyActor,
  request_user_id: String,
  user_id: String,
  player_index: Int,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  use lobby <- yuzu.ok(
    lobby.assign_player(state.lobby, user_id, player_index),
    actor.continue(state),
  )

  ws_lobby.UpdatePlayerPayload(state.lobby.id, user_id, player_index)
  |> ws_lobby.update_player_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby:) |> actor.continue()
}

fn update_traits_handler(
  state: LobbyActor,
  request_user_id: String,
  traits: Dict(Face, List(Trait)),
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner.id,
    actor.continue(state),
  )

  ws_lobby.UpdateTraitsPayload(state.lobby.id, traits)
  |> ws_lobby.update_traits_json()
  |> broadcast_json(state.meta, _)

  let engine_settings = EngineSettings(..state.lobby.engine_settings, traits:)
  let lobby = Lobby(..state.lobby, engine_settings:)

  LobbyActor(..state, lobby:) |> actor.continue()
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

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn broadcast_json(meta: Dict(String, LobbyActorUserMeta), payload: Json) {
  dict.each(meta, fn(_, user_meta) {
    process.send(user_meta.subject, ipc.WebsocketJson(payload))
  })
}
