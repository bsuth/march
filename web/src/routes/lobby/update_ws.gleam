import core/lobby.{Lobby}
import engine/settings.{Settings as EngineSettings}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/option
import lustre/effect
import modem
import routes/lobby/model.{type Model, Model}
import ws_api
import ws_api/ws_lobby
import yuzu

pub fn update_ws(model: Model, ws_message: ws_api.Message) {
  case ws_message.path {
    "lobby.entered" -> lobby_entered(model, ws_message.payload)
    "lobby.exited" -> lobby_exited(model, ws_message.payload)
    "lobby.started" -> lobby_started(model, ws_message.payload)
    "lobby.terminated" -> lobby_terminated(model, ws_message.payload)
    "lobby.update.board" -> lobby_update_board(model, ws_message.payload)
    "lobby.update.doubles" -> lobby_update_doubles(model, ws_message.payload)
    "lobby.update.hand_size" ->
      lobby_update_hand_size(model, ws_message.payload)
    "lobby.update.name" -> lobby_update_name(model, ws_message.payload)
    "lobby.update.player" -> lobby_update_player(model, ws_message.payload)
    "lobby.update.traits" -> lobby_update_traits(model, ws_message.payload)
    "lobby.update.visibility" ->
      lobby_update_visibility(model, ws_message.payload)
    _ -> #(model, effect.none())
  }
}

fn lobby_entered(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(decode.run(payload, ws_lobby.entered_decoder()), #(
    model,
    effect.none(),
  ))

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  let users =
    lobby.users
    |> list.filter(fn(user) { user.id != payload.user.id })
    |> list.prepend(payload.user)

  let lobby = Lobby(..lobby, users:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_exited(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(decode.run(payload, ws_lobby.exited_decoder()), #(
    model,
    effect.none(),
  ))

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))

  let lobby = lobby.remove_user(lobby, payload.user_id)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_started(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(decode.run(payload, ws_lobby.started_decoder()), #(
    model,
    effect.none(),
  ))

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  #(model, modem.push("/match/" <> payload.match_id, option.None, option.None))
}

fn lobby_terminated(model: Model, payload: Dynamic) {
  use lobby_id <- yuzu.ok(decode.run(payload, ws_lobby.terminated_decoder()), #(
    model,
    effect.none(),
  ))

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == lobby_id, #(model, effect.none()))

  // TODO: Show toast

  #(model, modem.push("/", option.None, option.None))
}

fn lobby_update_board(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_board_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let engine_settings =
    EngineSettings(..lobby.engine_settings, board: payload.board)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_doubles(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_doubles_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let engine_settings =
    EngineSettings(..lobby.engine_settings, doubles: payload.doubles)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_hand_size(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_hand_size_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let engine_settings =
    EngineSettings(..lobby.engine_settings, hand_size: payload.hand_size)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_name(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(decode.run(payload, ws_lobby.update_name_decoder()), #(
    model,
    effect.none(),
  ))

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let lobby = Lobby(..lobby, name: payload.lobby_name)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_player(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_player_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  use player_user <- yuzu.ok(
    list.find(lobby.users, fn(user) { user.id == payload.user_id }),
    #(model, effect.none()),
  )

  let players =
    list.index_map(lobby.players, fn(lobby_player, index) {
      case index == payload.player_index {
        True -> option.Some(player_user)
        False -> lobby_player
      }
    })

  let lobby = Lobby(..lobby, players:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_traits(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_traits_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let engine_settings =
    EngineSettings(..lobby.engine_settings, traits: payload.traits)
  let lobby = Lobby(..lobby, engine_settings:)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_visibility(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_visibility_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let lobby = Lobby(..lobby, visible: payload.visible)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}
