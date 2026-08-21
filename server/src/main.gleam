import actors/lobby_registry
import actors/match_registry
import actors/matchmaker
import gleam/erlang/process
import gleam/otp/static_supervisor
import logging
import names.{Names}
import router

pub fn main() {
  logging.configure()

  let names =
    Names(
      match_registry: process.new_name("match_registry"),
      lobby_registry: process.new_name("lobby_registry"),
      matchmaker: process.new_name("matchmaker"),
    )

  let assert Ok(_) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(match_registry.supervised(names))
    |> static_supervisor.add(lobby_registry.supervised(names))
    |> static_supervisor.add(matchmaker.supervised(names))
    |> static_supervisor.add(router.supervised(names))
    |> static_supervisor.start()

  // Supervisors run in new Erlang processes, so we can just put this one to
  // sleep forever.
  process.sleep_forever()
}
