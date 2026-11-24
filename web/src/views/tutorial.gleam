import blocks/game_board
import blocks/player_hand
import components/alert
import components/button
import core/engine.{type Engine}
import core/engine/card.{type Card}
import core/engine/turn
import core/util
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor
import yuzu

pub fn root_view(children: List(Element(message))) {
  html.div(
    [
      attribute.class("grow w-full max-w-4xl mx-auto p-16"),
      attribute.class("flex flex-col gap-8"),
    ],
    children,
  )
}

pub fn section_view(
  title: String,
  subtitle: String,
  children: List(Element(message)),
) {
  html.div([attribute.class("flex-1 flex flex-col gap-4")], [
    html.div([], [
      html.h3([], [
        html.text(title),
      ]),
      html.h6([attribute.class("text-(--march-600)")], [
        html.text(subtitle),
      ]),
    ]),
    ..children
  ])
}

pub fn split_section_view(
  title: String,
  subtitle: String,
  left: List(Element(message)),
  right: List(Element(message)),
) {
  html.div(
    [
      attribute.class("grow flex gap-8"),
      attribute.class("lg:flex-row max-lg:flex-col"),
    ],
    [
      section_view(title, subtitle, left),
      html.div([attribute.class("flex-1")], right),
    ],
  )
}

pub fn table_of_contents_view(
  current_chapter: String,
  chapters: List(#(String, String)),
) {
  html.div(
    [
      attribute.class("w-full max-w-xl m-auto p-16"),
      attribute.class("flex flex-col justify-center gap-4"),
    ],
    [
      html.div([attribute.class("flex justify-center items-center gap-4")], [
        html.hr([attribute.class("grow opacity-40")]),
        html.h6([], [html.text("Table of Contents")]),
        html.hr([attribute.class("grow opacity-40")]),
      ]),
      html.ol(
        [],
        list.map(chapters, fn(chapter) {
          html.li([], [
            html.a(
              [
                attribute.class("px-2 py-1 block text-center"),
                attribute.class("hover:bg-(--march-200)"),
                case chapter.0 == current_chapter {
                  True -> attribute.class("text-(--march-primary)")
                  False -> attribute.none()
                },
                attribute.href(chapter.1),
              ],
              [html.text(chapter.0)],
            ),
          ])
        }),
      ),
    ],
  )
}

pub fn footer_view(
  previous_chapter_url: Option(String),
  next_chapter_url: Option(String),
  on_table_of_contents_click: message,
) {
  html.div([attribute.class("flex justify-center items-center gap-2")], [
    html.a(
      case previous_chapter_url {
        option.Some(url) -> [attribute.href(url)]
        option.None -> [attribute.class("invisible")]
      },
      [
        button.element([button.class("w-32")], [
          phosphor.arrow_left_regular([]),
          html.text("Previous"),
        ]),
      ],
    ),
    button.element(
      [
        attribute.title("Table of Contents"),
        event.on_click(on_table_of_contents_click),
      ],
      [phosphor.list_bullets_regular([attribute.class("min-h-lh")])],
    ),
    html.a(
      case next_chapter_url {
        option.Some(url) -> [attribute.href(url)]
        option.None -> [attribute.class("invisible")]
      },
      [
        button.element([button.class("w-32")], [
          html.text("Next"),
          phosphor.arrow_right_regular([]),
        ]),
      ],
    ),
  ])
}

pub fn game_view(
  turn_request_engine: Engine,
  turn_request: turn.Request,
  on_update_turn_request: fn(turn.Request) -> message,
  on_deploy: fn(Card) -> message,
) {
  let assert Ok(active_player) =
    util.get_list_index(
      turn_request_engine.players,
      turn_request_engine.active_player_index,
    )

  html.div([attribute.class("flex flex-col gap-4")], [
    html.div([attribute.class("aspect-5/7")], [
      game_board.element([
        game_board.engine(turn_request_engine),
        game_board.turn_request(turn_request),
        game_board.on_update_turn_request(on_update_turn_request),
      ]),
    ]),
    player_hand.element([
      player_hand.player(active_player),
      player_hand.on_card_click(on_deploy),
    ]),
  ])
}

pub fn lead_alert_view(engine: Engine, turn_request: turn.Request) {
  case turn_request.lead, engine.kernel.turns {
    option.Some(_), _ ->
      alert.element([alert.variant(alert.Success)], [
        html.text("Has Lead"),
      ])

    option.None, [] ->
      alert.element([alert.variant(alert.Info)], [
        html.text("No Lead"),
      ])

    option.None, _ ->
      alert.element([alert.variant(alert.Danger)], [
        html.text("Needs Lead"),
      ])
  }
}

pub fn march_alert_view(turn_request: turn.Request) {
  case turn_request.marches {
    [] ->
      alert.element([alert.variant(alert.Info)], [
        html.text("No Marches"),
      ])

    [_] ->
      alert.element([alert.variant(alert.Success)], [
        html.text("Has 1 March"),
      ])

    _ ->
      alert.element([alert.variant(alert.Success)], [
        html.text(
          "Has "
          <> turn_request.marches |> list.length() |> int.to_string()
          <> " Marches",
        ),
      ])
  }
}

pub fn deployment_alert_view(
  turn_request_engine: Engine,
  turn_request: turn.Request,
) {
  let needs_deployment =
    turn_request_engine.position
    |> dict.get(0)
    |> result.unwrap(option.None)
    |> option.is_none()

  case turn_request.deploy, needs_deployment {
    option.Some(_), _ ->
      alert.element([alert.variant(alert.Success)], [
        html.text("Has Deployment"),
      ])

    option.None, True ->
      alert.element([alert.variant(alert.Danger)], [
        html.text("Needs Deployment"),
      ])

    option.None, False ->
      alert.element([alert.variant(alert.Info)], [
        html.text("No Deployment"),
      ])
  }
}

pub fn capture_alert_view(engine: Engine, turn_request: turn.Request) {
  let has_capture = {
    use lead <- yuzu.some(turn_request.lead, False)
    dict.get(engine.position, lead.1)
    |> result.unwrap(option.None)
    |> option.is_some()
  }

  case has_capture {
    True ->
      alert.element([alert.variant(alert.Success)], [
        html.text("Has Capture"),
      ])

    False ->
      alert.element([alert.variant(alert.Info)], [
        html.text("No Capture"),
      ])
  }
}

pub fn valid_turn_alert_view(engine: Engine, turn_request: turn.Request) {
  case engine.validate_turn_request(engine, turn_request) {
    True ->
      alert.element([alert.variant(alert.Success)], [
        html.text("Valid Turn"),
      ])

    False ->
      alert.element([alert.variant(alert.Danger)], [
        html.text("Invalid Turn"),
      ])
  }
}
