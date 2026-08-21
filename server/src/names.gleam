import gleam/erlang/process
import group_registry
import ipc

pub type Names {
  Names(
    match_registry: process.Name(group_registry.Message(ipc.Match)),
    lobby_registry: process.Name(group_registry.Message(ipc.Lobby)),
    matchmaker: process.Name(ipc.Matchmaker),
  )
}
