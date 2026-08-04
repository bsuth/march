import components/field
import components/single_select
import engine/variant
import entities/lobby_entity.{type LobbyEntity}
import lib/labels
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn lobby_variant_view(model: Model, lobby: LobbyEntity) {
  field.element([field.label("Variant")], [
    case model.app.user_id == lobby.owner_user_id {
      False -> labels.variant(lobby.variant) |> html.text()

      True ->
        single_select.element([
          lobby.variant
            |> variant.to_string()
            |> single_select.value(),
          single_select.options([
            #("standard", labels.variant(variant.Standard)),
            #("classic", labels.variant(variant.Classic)),
          ]),
          single_select.on_change(fn(variant_string) {
            let assert Ok(variant) = variant.from_string(variant_string)
            message.UserChangedVariant(variant)
          }),
        ])
    },
  ])
}
