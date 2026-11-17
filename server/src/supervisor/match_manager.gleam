import actors/match
import core/engine/settings.{type Settings as EngineSettings}
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
    matches: Dict(String, Subject(ipc.Match)),
    names: Names,
    selector: process.Selector(ipc.MatchManager),
  )
}

pub fn supervised(names: Names) {
  supervision.supervisor(fn() {
    actor.new_with_initialiser(100, fn(default_subject) {
      let selector =
        process.new_selector()
        |> process.select(default_subject)

      State(matches: dict.new(), names:, selector:)
      |> actor.initialised()
      |> actor.selecting(selector)
      |> Ok()
    })
    |> actor.named(names.match_manager)
    |> actor.on_message(on_message)
    |> actor.start()
  })
}

// -----------------------------------------------------------------------------
// Messages
// -----------------------------------------------------------------------------

fn on_message(state: State, message: ipc.MatchManager) {
  case message {
    ipc.MatchManagerDelete(match_id:) -> on_delete(state, match_id)
    ipc.MatchManagerForward(match_id:, message:) ->
      on_forward(state, match_id, message)
    ipc.MatchManagerNew(reply_subject:, engine_settings:, player_user_ids:) ->
      on_new(state, reply_subject, engine_settings, player_user_ids)
  }
}

fn on_delete(state: State, match_id: String) {
  State(..state, matches: dict.delete(state.matches, match_id))
  |> actor.continue()
}

fn on_forward(state: State, match_id: String, match_message: ipc.Match) {
  use match_subject <- yuzu.ok(
    dict.get(state.matches, match_id),
    actor.continue(state),
  )

  process.send(match_subject, match_message)
  actor.continue(state)
}

fn on_new(
  state: State,
  reply_subject: Subject(String),
  engine_settings: EngineSettings,
  player_user_ids: List(String),
) {
  let assert Ok(match_id) = new_match_id(state, 16)

  use actor.Started(match_actor_pid, match_actor_state) <- yuzu.ok(
    match.start(match_id, state.names, engine_settings, player_user_ids),
    actor.continue(state),
  )

  process.send(reply_subject, match_id)

  let matches = dict.insert(state.matches, match_id, match_actor_state.subject)
  let selector =
    process.select_specific_monitor(
      state.selector,
      process.monitor(match_actor_pid),
      fn(_) { ipc.MatchManagerDelete(match_id:) },
    )

  State(..state, matches:, selector:)
  |> actor.continue()
  |> actor.with_selector(selector)
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn new_match_id(state: State, attempts: Int) {
  use <- yuzu.true(attempts > 0, Error("failed to generate new match id"))

  let match_id = anid.random(8)

  case dict.has_key(state.matches, match_id) {
    True -> new_match_id(state, attempts - 1)
    False -> Ok(match_id)
  }
}
