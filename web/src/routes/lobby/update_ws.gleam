import entities/lobby_entity.{LobbyEntity}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/option
import lustre/effect
import routes/lobby/model.{type Model, Model}
import ws_api
import ws_api/ws_lobby
import yuzu

pub fn update_ws(model: Model, ws_message: ws_api.Message) {
  case ws_message.path {
    "lobby.update.board" -> lobby_update_board(model, ws_message.payload)
    "lobby.update.name" -> lobby_update_name(model, ws_message.payload)
    "lobby.update.variant" -> lobby_update_variant(model, ws_message.payload)
    "lobby.update.visibility" ->
      lobby_update_visibility(model, ws_message.payload)
    _ -> #(model, effect.none())
  }
}

fn lobby_update_board(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_board_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let lobby =
    LobbyEntity(
      ..lobby,
      board_width: payload.width,
      board_height: payload.height,
    )

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_name(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(decode.run(payload, ws_lobby.update_name_decoder()), #(
    model,
    effect.none(),
  ))

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let lobby = LobbyEntity(..lobby, name: payload.lobby_name)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_variant(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_variant_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let lobby = LobbyEntity(..lobby, variant: payload.variant)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}

fn lobby_update_visibility(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_visibility_decoder()),
    #(model, effect.none()),
  )

  use lobby <- yuzu.some(model.lobby, #(model, effect.none()))
  use <- yuzu.true(lobby.id == payload.lobby_id, #(model, effect.none()))

  let lobby = LobbyEntity(..lobby, is_public: payload.visible)

  #(Model(..model, lobby: option.Some(lobby)), effect.none())
}
