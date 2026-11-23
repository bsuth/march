import blocks/board
import components/button
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import phosphor
import routes/home/message.{type Message}
import routes/home/model.{type Model}

pub fn view(model: Model) {
  html.div([attribute.class("py-16 flex flex-col gap-16")], [
    hero_view(model),
    how_to_play_view(),
    // TODO: add interactive tutorial on home page?
  ])
}

fn hero_view(model: Model) {
  html.div(
    [
      attribute.class("w-full max-w-5xl m-auto px-16"),
      attribute.class("flex justify-around items-center gap-8"),
    ],
    [
      html.div([attribute.class("flex flex-col gap-4")], [
        html.div([attribute.class("flex flex-col gap-1")], [
          html.h1([], [html.text("March")]),
          html.text("A deceptively simple card game for strategists."),
        ]),
        html.a([attribute.href("/play")], [
          button.element([], [
            html.text("Play"),
          ]),
        ]),
      ]),
      // TODO: make this a real game replay?
      // TODO: remove cursor-pointer
      html.div([attribute.class("w-48 h-48")], [
        board.element([
          board.position(model.hero_engine.position),
          board.settings(model.hero_engine.kernel.settings),
        ]),
      ]),
    ],
  )
}

fn how_to_play_view() {
  section_view("How to Play", [
    html.div(
      [
        attribute.class("max-w-4xl m-auto px-16"),
        attribute.class("grid grid-cols-3 items-start gap-8"),
      ],
      [
        how_to_play_step_view(
          "Deploy Cards",
          "Play cards from your hand onto your base.",
          phosphor.hand_deposit_regular,
        ),
        how_to_play_step_view(
          "March Forward",
          "Chain moves together and advance towards the opponent.",
          phosphor.arrow_fat_lines_up_regular,
        ),
        how_to_play_step_view(
          "Capture the Base",
          "Occupy the opponent's base to win.",
          phosphor.flag_regular,
        ),
      ],
    ),
    html.a([attribute.href("/learn")], [
      button.element([attribute.class("m-auto")], [
        html.text("Learn the Rules"),
      ]),
    ]),
  ])
}

fn how_to_play_step_view(
  title: String,
  summary: String,
  icon: fn(List(Attribute(Message))) -> Element(Message),
) {
  html.div([attribute.class("flex flex-col justify-center text-center")], [
    html.h6(
      [
        attribute.class("flex justify-center items-center gap-2"),
        attribute.class("text-nowrap"),
      ],
      [
        icon([]),
        html.text(title),
      ],
    ),
    html.text(summary),
  ])
}

fn section_view(title: String, children: List(Element(Message))) {
  html.div([attribute.class("flex flex-col items-center gap-8")], [
    html.div(
      [attribute.class("w-full flex justify-center items-center gap-4")],
      [
        html.hr([attribute.class("w-1/5 opacity-40")]),
        html.text(title),
        html.hr([attribute.class("w-1/5 opacity-40")]),
      ],
    ),
    ..children
  ])
}
