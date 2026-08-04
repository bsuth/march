import engine/variant.{type Variant}
import entities/lobby_entity.{LobbyEntity}
import gleam/json
import gleam/option
import http_api/http_lobby
import lib/websocket
import lustre/effect
import routes/lobby/message.{type Message}
import routes/lobby/model.{type Model, Model}
import rsvp
import ws_api/ws_lobby
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyGetResponse(response) ->
      api_lobby_get_response(model, response)
    message.UserAssignedWhite(user_id) -> user_assigned_white(model, user_id)
    message.UserAssignedBlack(user_id) -> user_assigned_black(model, user_id)
    message.UserChangedBoard(width, height) ->
      user_changed_board(model, width, height)
    message.UserChangedVariant(variant) -> user_changed_variant(model, variant)
    message.UserChangedVisibility(visible) ->
      user_changed_visibility(model, visible)
    message.UserChangedEditName(new_edit_name) ->
      user_changed_edit_name(model, new_edit_name)
    message.UserDiscardedEditName -> user_discarded_edit_name(model)
    message.UserEnabledEditName -> user_enabled_edit_name(model)
    message.UserSavedEditName -> user_saved_edit_name(model)
  }
}

fn api_lobby_get_response(
  model: Model,
  response: Result(http_lobby.GetResponse, rsvp.Error(String)),
) {
  use response <- yuzu.ok(response, #(
    Model(..model, lobby: option.None),
    effect.none(),
  ))

  #(Model(..model, lobby: option.Some(response.lobby)), effect.none())
}

fn user_assigned_white(model: Model, user_id: String) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  let lobby =
    LobbyEntity(
      ..lobby,
      white_user_id: option.Some(user_id),
      black_user_id: case lobby.black_user_id {
        option.None -> option.None
        option.Some(black_user_id) if black_user_id == user_id -> option.None
        option.Some(black_user_id) -> option.Some(black_user_id)
      },
    )

  lobby
  |> ws_lobby.update_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_assigned_black(model: Model, user_id: String) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  let lobby =
    LobbyEntity(
      ..lobby,
      black_user_id: option.Some(user_id),
      white_user_id: case lobby.white_user_id {
        option.None -> option.None
        option.Some(white_user_id) if white_user_id == user_id -> option.None
        option.Some(white_user_id) -> option.Some(white_user_id)
      },
    )

  lobby
  |> ws_lobby.update_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_board(model: Model, width: Int, height: Int) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateBoardPayload(model.lobby_id, width, height)
  |> ws_lobby.update_board_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let lobby = LobbyEntity(..lobby, board_width: width, board_height: height)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_edit_name(model: Model, new_edit_name: String) {
  #(Model(..model, edit_name: option.Some(new_edit_name)), effect.none())
}

fn user_changed_variant(model: Model, variant: Variant) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateVariantPayload(model.lobby_id, variant)
  |> ws_lobby.update_variant_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let lobby = LobbyEntity(..lobby, variant:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_visibility(model: Model, visible: Bool) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateVisibilityPayload(model.lobby_id, visible)
  |> ws_lobby.update_visibility_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let lobby = LobbyEntity(..lobby, is_public: visible)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_discarded_edit_name(model: Model) {
  #(Model(..model, edit_name: option.None), effect.none())
}

fn user_enabled_edit_name(model: Model) {
  let edit_name = case model.lobby {
    option.Some(lobby) -> lobby.name
    option.None -> ""
  }

  #(Model(..model, edit_name: option.Some(edit_name)), effect.none())
}

fn user_saved_edit_name(model: Model) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use name <- yuzu.some(model.edit_name, #(model, effect.none()))

  let lobby = LobbyEntity(..lobby, name: name)

  ws_lobby.UpdateNamePayload(lobby.id, name)
  |> ws_lobby.update_name_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(
    Model(..model, lobby: option.Some(lobby), edit_name: option.None),
    effect.none(),
  )
}
