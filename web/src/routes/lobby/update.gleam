import core/engine/board.{type Board}
import core/engine/mode.{type Mode}
import core/engine/settings.{Settings as EngineSettings}
import core/lobby.{type Lobby, Lobby}
import core/ws_api/ws_lobby
import gleam/json
import gleam/option.{type Option}
import lib/websocket
import lustre/effect
import routes/lobby/message.{type Message}
import routes/lobby/model.{type Model, Model}
import rsvp
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyGetResponse(response) ->
      api_lobby_get_response(model, response)
    message.UserChangedBoard(board) -> user_changed_board(model, board)
    message.UserChangedDoubles(doubles) -> user_changed_doubles(model, doubles)
    message.UserChangedHandSize(hand_size) ->
      user_changed_hand_size(model, hand_size)
    message.UserChangedPlayerUserId(player_index, user_id) ->
      user_changed_player_user_id(model, player_index, user_id)
    message.UserChangedMode(mode) -> user_changed_mode(model, mode)
    message.UserStartedGame -> user_started_game(model)
    message.UserTerminatedLobby -> user_terminated_lobby(model)
  }
}

fn api_lobby_get_response(
  model: Model,
  response: Result(Lobby, rsvp.Error(String)),
) {
  use lobby <- yuzu.ok(response, #(
    Model(..model, lobby: option.None, lobby_loading: False),
    effect.none(),
  ))

  ws_lobby.enter_json(lobby.id)
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(
    Model(..model, lobby: option.Some(lobby), lobby_loading: False),
    effect.none(),
  )
}

fn user_changed_board(model: Model, board: Board) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateBoardPayload(model.lobby_id, board)
  |> ws_lobby.update_board_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let doubles = case board.height < 2 {
    True -> False
    False -> lobby.engine_settings.doubles
  }
  let engine_settings =
    EngineSettings(..lobby.engine_settings, board:, doubles:)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_doubles(model: Model, doubles: Bool) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateDoublesPayload(model.lobby_id, doubles)
  |> ws_lobby.update_doubles_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let lobby = lobby.set_doubles(lobby, doubles)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_hand_size(model: Model, hand_size: Int) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateHandSizePayload(model.lobby_id, hand_size)
  |> ws_lobby.update_hand_size_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let engine_settings = EngineSettings(..lobby.engine_settings, hand_size:)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_mode(model: Model, mode: Mode) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateModePayload(model.lobby_id, mode)
  |> ws_lobby.update_mode_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let engine_settings = EngineSettings(..lobby.engine_settings, mode:)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_player_user_id(
  model: Model,
  player_index: Int,
  user_id: Option(String),
) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  use lobby <- yuzu.ok(
    lobby.set_player_user_id(lobby, player_index, user_id),
    #(model, effect.none()),
  )

  ws_lobby.UpdatePlayerUserIdPayload(model.lobby_id, player_index, user_id)
  |> ws_lobby.update_player_user_id_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
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
