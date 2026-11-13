import gleam/erlang/process
import ipc

pub type Names {
  Names(
    match_manager: process.Name(ipc.MatchManager),
    lobby_manager: process.Name(ipc.LobbyManager),
    matchmaker: process.Name(ipc.Matchmaker),
  )
}
