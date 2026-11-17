import core/engine/settings
import gleam/dynamic/decode
import gleam/option
import lustre/effect
import modem
import routes/home/bindings
import routes/home/message.{type Message}
import routes/home/model.{type Model, Model}
import rsvp

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyPostResponse(response) ->
      api_lobby_post_response(model, response)

    message.HeroEngineResolveTimeout -> hero_engine_resolve_timeout(model)

    message.HeroEngineSetTimeout(hero_engine_timeout) -> #(
      Model(..model, hero_engine_timeout:),
      effect.none(),
    )

    message.SubmitLobbyPostRequest -> submit_post_lobby_request(model)
  }
}

fn api_lobby_post_response(
  model: Model,
  response: Result(String, rsvp.Error(String)),
) {
  case response {
    Ok(lobby_id) -> {
      #(
        Model(..model, post_lobby_request_loading: False),
        modem.push("/lobby/" <> lobby_id, option.None, option.None),
      )
    }

    Error(_) -> {
      // TODO: show error
      #(Model(..model, post_lobby_request_loading: False), effect.none())
    }
  }
}

fn hero_engine_resolve_timeout(model: Model) {
  // TODO: advance the game
  echo "timeout"

  #(
    model,
    effect.from(fn(dispatch) {
      fn() { dispatch(message.HeroEngineResolveTimeout) }
      |> bindings.set_timeout(1000)
      |> message.HeroEngineSetTimeout()
      |> dispatch
    }),
  )
}

fn submit_post_lobby_request(model: Model) {
  #(
    Model(..model, post_lobby_request_loading: True),
    rsvp.post(
      "/api/lobby",
      // TODO: Allow adjusting settings
      settings.json(settings.standard()),
      rsvp.expect_json(decode.string, message.ApiLobbyPostResponse),
    ),
  )
}
