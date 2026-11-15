import gleam/erlang/process
import ipc
import pog

pub type Names {
  Names(
    database: process.Name(pog.Message),
    match_manager: process.Name(ipc.MatchManager),
    lobby_manager: process.Name(ipc.LobbyManager),
    matchmaker: process.Name(ipc.Matchmaker),
  )
}
