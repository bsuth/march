import gleam/erlang/process
import group_registry.{type GroupRegistry}
import ipc
import lib/anid
import names.{type Names}

pub fn supervised(names: Names) {
  group_registry.supervised(names.lobby_registry)
}

pub fn generate_lobby_id(registry: GroupRegistry(ipc.Lobby)) {
  let lobby_id = anid.generate(8)

  case group_registry.members(registry, lobby_id) {
    [] -> lobby_id
    _ -> generate_lobby_id(registry)
  }
}

pub fn register_self(names: Names) {
  let self = process.self()
  let registry = group_registry.get_registry(names.lobby_registry)
  let lobby_id = generate_lobby_id(registry)

  #(lobby_id, [
    group_registry.join(registry, lobby_id, self),
    group_registry.join(registry, "list", self),
  ])
}

pub fn get(names: Names, lobby_id: String) {
  let registry = group_registry.get_registry(names.lobby_registry)

  case group_registry.members(registry, lobby_id) {
    [subject] -> Ok(subject)
    _ -> Error(Nil)
  }
}

pub fn list(names: Names) {
  let registry = group_registry.get_registry(names.lobby_registry)
  group_registry.members(registry, "list")
}
