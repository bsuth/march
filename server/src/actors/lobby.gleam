import core/engine/board.{type Board}
import core/engine/face.{type Face}
import core/engine/settings.{Settings as EngineSettings}
import core/engine/trait.{type Trait}
import core/lobby.{type Lobby, Lobby}
import core/user.{type User, User}
import core/ws_api/ws_lobby
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor
import ipc
import lib/guest
import names.{type Names}
import yuzu

// TODO: auto terminate lobby after X seconds when the owner leaves
// TODO: enforce maximum number of users in a lobby?

pub type LobbyActor {
  LobbyActor(
    lobby: Lobby,
    meta: Dict(String, LobbyActorUserMeta),
    names: Names,
    selector: process.Selector(ipc.Lobby),
    subject: process.Subject(ipc.Lobby),
  )
}

pub type LobbyActorUserMeta {
  LobbyActorUserMeta(subject: Subject(ipc.Websocket), monitor: process.Monitor)
}

pub fn start(id: String, names: Names, owner_user_id: String) {
  actor.new_with_initialiser(100, fn(default_subject) {
    let selector = process.new_selector() |> process.select(default_subject)

    let lobby =
      Lobby(
        id:,
        engine_settings: settings.standard(),
        owner_user_id:,
        player_user_ids: [option.None, option.None],
        users: [],
      )

    let state =
      LobbyActor(
        lobby:,
        meta: dict.new(),
        names:,
        selector:,
        subject: default_subject,
      )

    state
    |> actor.initialised()
    |> actor.selecting(selector)
    |> actor.returning(state)
    |> Ok()
  })
  |> actor.on_message(on_message)
  |> actor.start()
}

// -----------------------------------------------------------------------------
// Messages
// -----------------------------------------------------------------------------

fn on_message(state: LobbyActor, message: ipc.Lobby) {
  case message {
    ipc.LobbyEnter(user, subject) -> on_enter(state, user, subject)
    ipc.LobbyExit(user_id) -> on_exit(state, user_id)
    ipc.LobbyGet(requester) -> on_get(state, requester)
    ipc.LobbyStart(id) -> on_start(state, id)
    ipc.LobbyTerminate(id) -> on_terminate(state, id)
    ipc.LobbyUpdateBoard(request_user_id, board) ->
      on_update_board(state, request_user_id, board)
    ipc.LobbyUpdateDoubles(request_user_id, doubles) ->
      on_update_doubles(state, request_user_id, doubles)
    ipc.LobbyUpdateHandSize(request_user_id, hand_size) ->
      on_update_hand_size(state, request_user_id, hand_size)
    ipc.LobbyUpdatePlayerUserId(request_user_id, player_index, user_id) ->
      on_update_player_user_id(state, request_user_id, player_index, user_id)
    ipc.LobbyUpdateTraits(request_user_id, traits) ->
      on_update_traits(state, request_user_id, traits)
    ipc.LobbyShutdown -> actor.stop()
  }
}

fn on_enter(
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

  let lobby_user = case enter_user.guest {
    False -> enter_user
    True -> {
      let existing_names = list.map(state.lobby.users, fn(user) { user.name })
      case guest.new_name(existing_names) {
        Ok(name) -> User(..enter_user, name:)
        _ -> User(..enter_user, name: enter_user.id)
      }
    }
  }

  let monitor = process.monitor(user_pid)

  let meta =
    dict.insert(
      state.meta,
      lobby_user.id,
      LobbyActorUserMeta(subject: enter_user_subject, monitor:),
    )

  ws_lobby.EnteredPayload(state.lobby.id, lobby_user)
  |> ws_lobby.entered_json()
  |> broadcast_json(meta, _)

  let selector =
    process.select_specific_monitor(state.selector, monitor, fn(_) {
      ipc.LobbyExit(lobby_user.id)
    })

  let users = list.prepend(state.lobby.users, lobby_user)
  let lobby = Lobby(..state.lobby, users:)

  LobbyActor(..state, lobby:, meta:, selector:)
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn on_exit(state: LobbyActor, exit_user_id: String) {
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

fn on_get(state: LobbyActor, requester: Subject(Lobby)) {
  process.send(requester, state.lobby)
  actor.continue(state)
}

fn on_start(state: LobbyActor, request_user_id: String) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
    actor.continue(state),
  )

  use player_user_ids <- yuzu.ok(
    list.try_map(state.lobby.player_user_ids, fn(player_user_id) {
      case player_user_id {
        option.None -> Error(Nil)
        option.Some(player_user_id) -> Ok(player_user_id)
      }
    }),
    actor.continue(state),
  )

  // TODO: REMOVE `call_forever`
  // instead, we should timeout and return an error
  // In fact, this entire message should probably be a REST API endpoint
  let match_id =
    state.names.match_manager
    |> process.named_subject()
    |> process.call_forever(fn(reply_subject) {
      ipc.MatchManagerNew(
        reply_subject,
        state.lobby.engine_settings,
        player_user_ids,
      )
    })

  ws_lobby.StartedPayload(state.lobby.id, match_id)
  |> ws_lobby.started_json()
  |> broadcast_json(state.meta, _)

  actor.stop()
}

fn on_terminate(state: LobbyActor, request_user_id: String) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
    actor.continue(state),
  )

  state.lobby.id
  |> ws_lobby.terminated_json()
  |> broadcast_json(state.meta, _)

  actor.stop()
}

fn on_update_board(state: LobbyActor, request_user_id: String, board: Board) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
    actor.continue(state),
  )

  ws_lobby.UpdateBoardPayload(state.lobby.id, board)
  |> ws_lobby.update_board_json()
  |> broadcast_json(state.meta, _)

  let doubles = case board.height < 2 {
    True -> False
    False -> state.lobby.engine_settings.doubles
  }
  let engine_settings =
    EngineSettings(..state.lobby.engine_settings, board:, doubles:)
  let lobby = Lobby(..state.lobby, engine_settings:)

  LobbyActor(..state, lobby:) |> actor.continue()
}

fn on_update_doubles(
  state: LobbyActor,
  request_user_id: String,
  doubles: Bool,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
    actor.continue(state),
  )

  ws_lobby.UpdateDoublesPayload(state.lobby.id, doubles)
  |> ws_lobby.update_doubles_json()
  |> broadcast_json(state.meta, _)

  let lobby = lobby.set_doubles(state.lobby, doubles)

  LobbyActor(..state, lobby:) |> actor.continue()
}

fn on_update_hand_size(
  state: LobbyActor,
  request_user_id: String,
  hand_size: Int,
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
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

fn on_update_player_user_id(
  state: LobbyActor,
  request_user_id: String,
  player_index: Int,
  user_id: Option(String),
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
    actor.continue(state),
  )

  use lobby <- yuzu.ok(
    lobby.set_player_user_id(state.lobby, player_index, user_id),
    actor.continue(state),
  )

  ws_lobby.UpdatePlayerUserIdPayload(state.lobby.id, player_index, user_id)
  |> ws_lobby.update_player_user_id_json()
  |> broadcast_json(state.meta, _)

  LobbyActor(..state, lobby:) |> actor.continue()
}

fn on_update_traits(
  state: LobbyActor,
  request_user_id: String,
  traits: Dict(Face, List(Trait)),
) {
  use <- yuzu.true(
    request_user_id == state.lobby.owner_user_id,
    actor.continue(state),
  )

  ws_lobby.UpdateTraitsPayload(state.lobby.id, traits)
  |> ws_lobby.update_traits_json()
  |> broadcast_json(state.meta, _)

  let engine_settings = EngineSettings(..state.lobby.engine_settings, traits:)
  let lobby = Lobby(..state.lobby, engine_settings:)

  LobbyActor(..state, lobby:) |> actor.continue()
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn broadcast_json(meta: Dict(String, LobbyActorUserMeta), payload: Json) {
  dict.each(meta, fn(_, user_meta) {
    process.send(user_meta.subject, ipc.WebsocketJson(payload))
  })
}
