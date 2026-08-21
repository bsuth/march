import components/button
import lustre/attribute
import lustre/element/html
import routes/home/message
import routes/home/model.{type Model}
import routes/home/view/create_lobby_view.{create_lobby_view}
import routes/home/view/lobby_list_view.{lobby_list_view}

pub fn view(model: Model) {
  html.div([attribute.class("m-auto"), attribute.class("flex flex-col gap-4")], [
    html.div([attribute.class("flex gap-4")], [
      lobby_list_view(model),
      create_lobby_view(model),
    ]),
    button.element(
      [
        button.loading(model.get_lobby_list_loading),
        button.on_click(message.UserRefreshedLobbyList),
      ],
      // TODO: Remove this in favor of auto-refresh
      [html.text("Refresh")],
    ),
  ])
}
