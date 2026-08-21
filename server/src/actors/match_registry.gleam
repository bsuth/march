import gleam/erlang/process
import group_registry.{type GroupRegistry}
import ipc
import lib/anid
import names.{type Names}

pub fn supervised(names: Names) {
  group_registry.supervised(names.match_registry)
}

pub fn generate_game_id(registry: GroupRegistry(ipc.Match)) {
  let game_id = anid.generate(8)

  case group_registry.members(registry, game_id) {
    [] -> game_id
    _ -> generate_game_id(registry)
  }
}

pub fn register_self(names: Names) {
  let self = process.self()
  let registry = group_registry.get_registry(names.match_registry)
  let game_id = generate_game_id(registry)

  #(game_id, [
    group_registry.join(registry, game_id, self),
    group_registry.join(registry, "list", self),
  ])
}

pub fn get(names: Names, game_id: String) {
  let registry = group_registry.get_registry(names.match_registry)

  case group_registry.members(registry, game_id) {
    [subject] -> Ok(subject)
    _ -> Error(Nil)
  }
}

pub fn list(names: Names) {
  let registry = group_registry.get_registry(names.match_registry)
  group_registry.members(registry, "list")
}
