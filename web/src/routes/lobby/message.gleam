import engine/variant.{type Variant}
import http_api/http_lobby
import rsvp

pub type Message {
  ApiLobbyGetResponse(Result(http_lobby.GetResponse, rsvp.Error(String)))
  UserAssignedWhite(String)
  UserAssignedBlack(String)
  UserChangedBoard(Int, Int)
  UserChangedEditName(String)
  UserChangedVariant(Variant)
  UserChangedVisibility(Bool)
  UserDiscardedEditName
  UserEnabledEditName
  UserSavedEditName
}
