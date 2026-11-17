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
import gleam/otp/actor
import ipc
import names.{type Names}
import yuzu

// TODO: properly handle user enter + exit broadcast
// TODO: save to db when finished
// TODO: auto terminate game after X seconds when players leave
//    If only 1 player leaves, other wins. otherwise draw
// TODO: auto terminate game after X seconds when game ends
// TODO: enforce maximum number of spectators in a match?

pub type MatchActor {
  MatchActor(
    engine: Engine,
    match: Match,
    meta: Dict(String, MatchActorUserMeta),
    names: Names,
    selector: process.Selector(ipc.Match),
    subject: process.Subject(ipc.Match),
  )
}

pub type MatchActorUserMeta {
  MatchActorUserMeta(subject: Subject(ipc.Websocket), monitor: process.Monitor)
}

pub fn start(
  id: String,
  names: Names,
  engine_settings: Settings,
  player_user_ids: List(String),
) {
  actor.new_with_initialiser(100, fn(default_subject) {
    let selector = process.new_selector() |> process.select(default_subject)

    let match =
      Match(
        id:,
        engine_kernel: engine.new_kernel(engine_settings),
        player_user_ids:,
      )

    let state =
      MatchActor(
        engine: engine.new(match.engine_kernel),
        match:,
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

fn on_message(state: MatchActor, message: ipc.Match) {
  case message {
    ipc.MatchEnter(enter_user:, enter_user_subject:) ->
      on_enter(state, enter_user, enter_user_subject)
    ipc.MatchExit(exit_user_id:) -> on_exit(state, exit_user_id)
    ipc.MatchGet(reply_subject:) -> on_get(state, reply_subject)
    ipc.MatchRequestTurn(request_user_id:, turn_request:) ->
      on_request_turn(state, request_user_id, turn_request)
  }
}

fn on_enter(
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

fn on_exit(state: MatchActor, exit_user_id: String) {
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

fn on_get(state: MatchActor, reply_subject: Subject(Match)) {
  process.send(reply_subject, state.match)
  actor.continue(state)
}

fn on_request_turn(
  state: MatchActor,
  request_user_id: String,
  turn_request: turn.Request,
) {
  use request_player_index <- yuzu.ok(
    util.find_list_index(state.match.player_user_ids, request_user_id),
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
