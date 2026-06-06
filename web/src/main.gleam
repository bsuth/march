import components/button
import components/field
import components/float_input
import components/int_input
import components/location_input
import components/multi_select
import components/multi_upload
import components/radio
import components/single_select
import components/single_upload
import components/text_area
import components/text_input
import components/toggle
import gleam/io
import gleam/json
import lib/websocket
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import navbar
import router
import routes/cheatsheet
import routes/learn
import x.{type Model, type Msg}

pub fn main() {
  let app = lustre.application(init, update, view)

  let assert Ok(_) = button.register()
  let assert Ok(_) = field.register()
  let assert Ok(_) = float_input.register()
  let assert Ok(_) = int_input.register()
  let assert Ok(_) = location_input.register()
  let assert Ok(_) = multi_select.register()
  let assert Ok(_) = multi_upload.register()
  let assert Ok(_) = radio.register()
  let assert Ok(_) = single_select.register()
  let assert Ok(_) = single_upload.register()
  let assert Ok(_) = text_area.register()
  let assert Ok(_) = text_input.register()
  let assert Ok(_) = toggle.register()

  let assert Ok(_) = learn.register()
  let assert Ok(_) = cheatsheet.register()

  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_) -> #(Model, Effect(Msg)) {
  let #(route, router_effect) = router.init()

  let model = x.Model(route:, ws: websocket.new("ws://localhost:8000/ws"))

  let effect =
    effect.batch([
      router_effect,
      websocket.on_message(model.ws, ws_update),
    ])

  #(model, effect)
}

fn ws_update(message: String) -> Msg {
  case message {
    "pong" -> x.Pong
    "matched" -> x.Matched
    _ -> x.WebsocketError(message)
  }
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    x.OnRouteChange(route) -> #(x.Model(..model, route:), effect.none())

    x.UserClickedTest -> {
      [
        #("method", json.string("enter_matchmaking")),
        #("payload", json.null()),
      ]
      |> json.object()
      |> json.to_string()
      |> websocket.send(model.ws, _)
      #(model, effect.none())
    }

    x.Pong -> {
      io.print("ponged")
      #(model, effect.none())
    }

    x.Matched -> {
      io.print("matched")
      #(model, effect.none())
    }

    x.WebsocketError(message) -> {
      io.print("error: " <> message)
      #(model, effect.none())
    }
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.class(
        "text-white bg-gray-800 h-dvh flex flex-col overflow-auto",
      ),
    ],
    [
      navbar.view(model, []),
      router.view(model, [attribute.class("grow")]),
    ],
  )
}
