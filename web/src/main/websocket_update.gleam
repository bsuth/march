import core/yuzu
import gleam/dynamic/decode
import gleam/json
import gleam/option
import lustre/effect
import main/model.{type Model}
import modem

pub fn websocket_update(model: Model, message: String) {
  use event <- yuzu.ok(
    json.parse(message, {
      use event <- decode.field("event", decode.string)
      decode.success(event)
    }),
    #(model, effect.none()),
  )

  case event {
    "lobby_created" -> {
      let id_result =
        json.parse(message, {
          use id <- decode.field("payload", decode.string)
          decode.success(id)
        })

      case id_result {
        Ok(id) -> #(
          model,
          modem.push("/lobby/" <> id, option.None, option.None),
        )

        _ -> #(model, effect.none())
      }
    }

    _ -> #(model, effect.none())
  }
}
