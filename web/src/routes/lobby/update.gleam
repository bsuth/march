import core/lobby.{type Lobby, Lobby}
import engine/board.{type Board}
import engine/face.{type Face}
import engine/settings.{Settings as EngineSettings}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
import gleam/json
import gleam/list
import gleam/option
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
    message.UserChangedBoard(board) -> user_changed_board(model, board)
    message.UserChangedDoubles(doubles) -> user_changed_doubles(model, doubles)
    message.UserChangedEditName(edit_name) ->
      user_changed_edit_name(model, edit_name)
    message.UserChangedHandSize(hand_size) ->
      user_changed_hand_size(model, hand_size)
    message.UserChangedPlayer(user_id, player_index) ->
      user_changed_player(model, user_id, player_index)
    message.UserChangedTraits(traits) -> user_changed_traits(model, traits)
    message.UserChangedVisibility(visible) ->
      user_changed_visibility(model, visible)
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
    Model(..model, lobby: option.None, lobby_loading: False),
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
        Model(..model, lobby: option.Some(lobby), lobby_loading: False),
        effect.none(),
      )
    }
  }
}

fn user_changed_board(model: Model, board: Board) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateBoardPayload(model.lobby_id, board)
  |> ws_lobby.update_board_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let engine_settings = EngineSettings(..lobby.engine_settings, board:)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_doubles(model: Model, doubles: Bool) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateDoublesPayload(model.lobby_id, doubles)
  |> ws_lobby.update_doubles_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let engine_settings = EngineSettings(..lobby.engine_settings, doubles:)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_edit_name(model: Model, new_edit_name: String) {
  #(Model(..model, edit_name: option.Some(new_edit_name)), effect.none())
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

fn user_changed_player(model: Model, user_id: String, player_index: Int) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  use player_user <- yuzu.ok(
    list.find(lobby.users, fn(user) { user.id == user_id }),
    #(model, effect.none()),
  )

  ws_lobby.UpdatePlayerPayload(model.lobby_id, user_id, player_index)
  |> ws_lobby.update_player_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let players =
    list.index_map(lobby.players, fn(lobby_player, index) {
      case index == player_index {
        True -> option.Some(player_user)
        False -> lobby_player
      }
    })

  let lobby = Lobby(..lobby, players:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn user_changed_traits(model: Model, traits: Dict(Face, List(Trait))) {
  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  ws_lobby.UpdateTraitsPayload(model.lobby_id, traits)
  |> ws_lobby.update_traits_json()
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  let engine_settings = EngineSettings(..lobby.engine_settings, traits:)
  let lobby = Lobby(..lobby, engine_settings:)

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
