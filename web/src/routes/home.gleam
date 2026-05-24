import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import phosphor
import x.{type Model, type Msg}

type LinkCard {
  LinkCard(title: String, link: String, body: String)
}

const link_cards = [
  LinkCard(title: "Learn", link: "./learn", body: "Learn how to play March."),
  LinkCard(
    title: "Versus",
    link: "./versus",
    body: "Play against someone online.",
  ),
  LinkCard(
    title: "Cheatsheet",
    link: "./cheatsheet",
    body: "A quick reference of the basic rules and interactions. Recommended for those who have played before.",
  ),
]

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.div(
    [
      attribute.class(
        "max-w-4xl m-auto flex flex-col items-center gap-12 px-4 py-8",
      ),
      ..attrs
    ],
    [
      html.p([], [
        html.img([attribute.src("/logo.svg"), attribute.width(128)]),
      ]),
      html.div([attribute.class("flex flex-col gap-4 items-center")], [
        html.h1([], [
          html.text("March"),
        ]),
        html.p([attribute.class("text-center")], [
          html.text(
            "March is a simple, modern, tactical card game that utilizes standard decks of playing cards.",
          ),
        ]),
      ]),
      html.div(
        [attribute.class("flex gap-4")],
        list.map(link_cards, fn(link_card) {
          html.a(
            [
              attribute.class(
                "bg-gray-700 rounded p-4 flex-1 flex flex-col gap-2 text-white hover:text-blue-400",
              ),
              attribute.href(link_card.link),
            ],
            [
              html.div(
                [attribute.class("flex gap-2 justify-between items-center")],
                [
                  html.h3([], [html.text(link_card.title)]),
                  phosphor.arrow_right_bold([
                    attribute.class("w-6 h-6"),
                  ]),
                ],
              ),
              html.div([], [html.text(link_card.body)]),
            ],
          )
        }),
      ),
      html.div([attribute.class("flex flex-col gap-4 items-center")], [
        html.h2([], [
          html.text("About"),
        ]),
        html.p([], [
          html.text(
            "March was created by a software engineer who likes to play card games and board games with coworkers after work. It was particular inspired after playing the wonderful ",
          ),
          html.a([attribute.href("https://www.regicidegame.com/")], [
            html.text("Regicide"),
          ]),
          html.text(
            " and having a coworker express their desire for more modern card games that utilize the standard deck of playing cards.",
          ),
        ]),
      ]),
      html.div([attribute.class("flex flex-col gap-4 items-center")], [
        html.h2([], [
          html.text("Attributions"),
        ]),
        html.p([], [
          html.text("TODO"),
          html.text("Gleam"),
          html.text("Lustre"),
          html.text("Phosphor Icons"),
        ]),
      ]),
    ],
  )
}
