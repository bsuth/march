import components/field
import components/toggle
import core/lobby.{type Lobby}
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn lobby_doubles_view(model: Model, lobby: Lobby) {
  field.element([field.prop_label("Doubles")], [
    toggle.element([
      toggle.prop_disabled(model.app.user.id == lobby.owner.id),
      toggle.prop_value(lobby.engine_settings.doubles),
      toggle.on_update(message.UserChangedDoubles),
    ]),
  ])
}
