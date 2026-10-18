import actors/match_registry
import core/engine.{type Engine}
import core/engine/settings.{type Settings}
import core/engine/turn
import core/match.{type Match, Match}
import core/user.{type User}
import core/util
import core/ws_api/ws_match
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json.{type Json}
import gleam/list
import gleam/otp/actor
import ipc
import names.{type Names}
import yuzu

// TODO: auto terminate game after X seconds when players leave
//    If only 1 player leaves, other wins. otherwise draw
// TODO: auto terminate game after X seconds when game ends
// TODO: enforce maximum number of users in a match

pub type StartArgs {
  StartArgs(engine_settings: Settings, players: List(User), visible: Bool)
}

pub type MatchActor {
  MatchActor(
    engine: Engine,
    match: Match,
    meta: Dict(String, MatchActorUserMeta),
    selector: process.Selector(ipc.Match),
  )
}

pub type MatchActorUserMeta {
  MatchActorUserMeta(subject: Subject(ipc.Websocket), monitor: process.Monitor)
}

pub fn start(names: Names, args: StartArgs) {
  actor.new_with_initialiser(100, fn(_) {
    let #(id, subjects) = match_registry.register_self(names)

    let match =
      Match(
        id:,
        engine_kernel: engine.new_kernel(args.engine_settings),
        players: args.players,
        visible: args.visible,
      )

    let engine = engine.new(match.engine_kernel)
    let selector = list.fold(subjects, process.new_selector(), process.select)
    let state = MatchActor(engine:, match:, meta: dict.new(), selector:)

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

fn handler(state: MatchActor, message: ipc.Match) {
  case message {
    ipc.MatchEnter(user, subject) -> enter_handler(state, user, subject)
    ipc.MatchExit(id) -> exit_handler(state, id)
    ipc.MatchGet(requester) -> get_handler(state, requester)
    ipc.MatchRequestTurn(id, turn_request) ->
      request_turn_handler(state, id, turn_request)
  }
}

fn enter_handler(
  state: MatchActor,
  enter_user: User,
  enter_user_subject: Subject(ipc.Websocket),
) {
  use user_pid <- yuzu.ok(
    process.subject_owner(enter_user_subject),
    actor.continue(state),
  )

  let monitor = process.monitor(user_pid)

  let meta =
    dict.insert(
      state.meta,
      enter_user.id,
      MatchActorUserMeta(subject: enter_user_subject, monitor:),
    )

  // TODO
  // ws_lobby.EnteredPayload(state.lobby.id, enter_user)
  // |> ws_lobby.entered_json()
  // |> broadcast_json(meta, _)
  broadcast_json(meta, json.null())

  let selector =
    process.select_specific_monitor(state.selector, monitor, fn(_) {
      ipc.MatchExit(enter_user.id)
    })

  MatchActor(..state, meta:, selector:)
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn exit_handler(state: MatchActor, exit_user_id: String) {
  use exit_user_meta <- yuzu.ok(
    dict.get(state.meta, exit_user_id),
    actor.continue(state),
  )

  let meta = dict.delete(state.meta, exit_user_id)

  // TODO
  // ws_lobby.ExitedPayload(state.lobby.id, exit_user_id)
  // |> ws_lobby.exited_json()
  // |> broadcast_json(meta, _)
  broadcast_json(meta, json.null())

  let selector =
    process.deselect_specific_monitor(state.selector, exit_user_meta.monitor)

  process.demonitor_process(exit_user_meta.monitor)

  MatchActor(..state, meta:, selector:)
  |> actor.continue()
  |> actor.with_selector(selector)
}

fn get_handler(state: MatchActor, requester: Subject(Match)) {
  process.send(requester, state.match)
  actor.continue(state)
}

fn request_turn_handler(
  state: MatchActor,
  request_user_id: String,
  turn_request: turn.Request,
) {
  use request_player_index <- yuzu.ok(
    state.match.players
      |> list.map(fn(user) { user.id })
      |> util.find_list_index(request_user_id),
    actor.continue(state),
  )

  use <- yuzu.true(
    state.engine.active_player_index == request_player_index,
    actor.continue(state),
  )

  use engine <- yuzu.ok(
    engine.commit_turn_request(state.engine, turn_request),
    actor.continue(state),
  )

  let assert [turn, ..] = engine.kernel.turns

  dict.each(state.meta, fn(user_id, user_meta) {
    case user_id == request_user_id {
      True -> turn
      False -> turn.to_observed(turn)
    }
    |> ws_match.TurnEndedPayload(state.match.id, _)
    |> ws_match.turn_ended_json()
    |> ipc.WebsocketJson()
    |> process.send(user_meta.subject, _)
  })

  let match = Match(..state.match, engine_kernel: engine.kernel)

  MatchActor(..state, engine:, match:) |> actor.continue()
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn broadcast_json(meta: Dict(String, MatchActorUserMeta), payload: Json) {
  dict.each(meta, fn(_, user_meta) {
    process.send(user_meta.subject, ipc.WebsocketJson(payload))
  })
}
