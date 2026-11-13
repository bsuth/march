import lustre/attribute
import lustre/element/html
import routes/home/model.{type Model}
import routes/home/view/create_lobby_view.{create_lobby_view}

pub fn view(model: Model) {
  html.div([attribute.class("m-auto"), attribute.class("flex flex-col gap-4")], [
    html.div([attribute.class("flex gap-4")], [
      create_lobby_view(model),
    ]),
  ])
}
