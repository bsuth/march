import gleam/erlang/process
import gleam/otp/static_supervisor
import logging
import names.{Names}
import supervisor/database
import supervisor/lobby_manager
import supervisor/match_manager
import supervisor/matchmaker
import supervisor/router

pub fn main() {
  logging.configure()

  let names =
    Names(
      database: process.new_name("database"),
      lobby_manager: process.new_name("lobby_manager"),
      match_manager: process.new_name("match_manager"),
      matchmaker: process.new_name("matchmaker"),
    )

  let assert Ok(_) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(database.supervised(names))
    |> static_supervisor.add(lobby_manager.supervised(names))
    |> static_supervisor.add(match_manager.supervised(names))
    |> static_supervisor.add(matchmaker.supervised(names))
    |> static_supervisor.add(router.supervised(names))
    |> static_supervisor.start()

  // Supervisors run in new Erlang processes, so we can just put this one to
  // sleep forever.
  process.sleep_forever()
}
