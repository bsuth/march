import core/lobby.{type Lobby, Lobby}
import engine/board.{Board}
import engine/variant.{type Variant}
import gleam/json
import gleam/option.{type Option}
import lib/websocket
import lustre/effect
import modem
import routes/lobby/message.{type Message}
import routes/lobby/model.{type Model, Model}
import rsvp
import ws_api/ws_lobby
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyGetResponse(response) ->
      api_lobby_get_response(model, response)
    message.UserChangedBlack(black_user_id) ->
      user_changed_black(model, black_user_id)
    message.UserChangedBoard(width, height) ->
      user_changed_board(model, width, height)
    message.UserChangedEditName(new_edit_name) ->
      user_changed_edit_name(model, new_edit_name)
    message.UserChangedVariant(variant) -> user_changed_variant(model, variant)
    message.UserChangedVisibility(visible) ->
      user_changed_visibility(model, visible)
    message.UserChangedWhite(white_user_id) ->
      user_changed_white(model, white_user_id)
    message.UserDiscardedEditName -> user_discarded_edit_name(model)
    message.UserEnabledEditName -> user_enabled_edit_name(model)
    message.UserSavedEditName -> user_saved_edit_name(model)
    message.UserStartedGame -> user_started_game(model)
    message.UserTerminatedLobby -> user_terminated_lobby(model)
  }
}

fn api_lobby_get_response(
  model: Model,
  response: Result(Lobby, rsvp.Error(String)),
) {
  use lobby <- yuzu.ok(response, #(
    Model(..model, loading_lobby: False, lobby: option.None),
    effect.none(),
  ))

  case lobby.match_id {
    option.Some(match_id) -> #(
      model,
      modem.push("/match/" <> match_id, option.None, option.None),
    )

    option.None -> {
      ws_lobby.enter_json(lobby.id)
      |> json.to_string()
      |> websocket.send(model.app.ws, _)

      #(
        Model(..model, loading_lobby: False, lobby: option.Some(lobby)),
        effect.none(),
      )
    }
  }
}

fn user_changed_black(model: Model, black_user_id: Option(String)) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  use lobby <- yuzu.ok(lobby.assign_black(lobby, black_user_id), #(
    model,
    effect.none(),
  ))

  ws_lobby.UpdateBlackPayload(model.lobby_id, black_user_id:)
  |> ws_lobby.update_black_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_board(model: Model, board_width: Int, board_height: Int) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateBoardPayload(model.lobby_id, board_width, board_height)
  |> ws_lobby.update_board_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let lobby = Lobby(..lobby, board_width:, board_height:)
  let board = Board(..model.board, width: board_width, height: board_height)

  #(Model(..model, board:, lobby: option.Some(lobby)), effect.none())
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

  let lobby = Lobby(..lobby, variant:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_visibility(model: Model, visible: Bool) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateVisibilityPayload(model.lobby_id, visible)
  |> ws_lobby.update_visibility_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let lobby = Lobby(..lobby, visible:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_white(model: Model, white_user_id: Option(String)) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  use lobby <- yuzu.ok(lobby.assign_white(lobby, white_user_id), #(
    model,
    effect.none(),
  ))

  ws_lobby.UpdateWhitePayload(model.lobby_id, white_user_id:)
  |> ws_lobby.update_white_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

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

  let lobby = Lobby(..lobby, name:)

  ws_lobby.UpdateNamePayload(lobby.id, name)
  |> ws_lobby.update_name_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(
    Model(..model, lobby: option.Some(lobby), edit_name: option.None),
    effect.none(),
  )
}

fn user_started_game(model: Model) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.start_json(lobby.id)
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(model, effect.none())
}

fn user_terminated_lobby(model: Model) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.terminate_json(lobby.id)
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(model, effect.none())
}
