import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element/html
import phosphor
import routes/learn/lib/chapter
import routes/learn/message.{type Message}
import routes/learn/model.{type Model}

pub fn view(_model: Model, attrs: List(Attribute(Message))) {
  html.section(attrs, [
    html.h2([], [html.text(chapter.get_title(chapter.Setup))]),
    html.text(
      "March is played with two players sitting on opposing sides of a 4x4 grid.
      Each player's respective bottom right corner constitutes their \"base\",
      which serves a central role during gameplay.",
    ),
    html.div([attribute.class("flex flex-col gap-4 items-center")], [
      phosphor.person_regular([attribute.class("w-12 h-12")]),
      html.div(
        [attribute.class("grid grid-cols-4 border")],
        list.index_map(list.repeat(0, 16), fn(_, index) {
          html.div(
            [
              attribute.class(
                "w-16 h-16 flex justify-center items-center border",
              ),
            ],
            case index {
              0 -> [phosphor.star_regular([attribute.class("w-8 h-8")])]
              15 -> [phosphor.star_fill([attribute.class("w-8 h-8")])]
              _ -> []
            },
          )
        }),
      ),
      phosphor.person_fill([attribute.class("w-12 h-12")]),
    ]),
    html.text(
      "Each player uses their own deck consisting of the Jacks, Queens, Kings,
      and Aces from a standard deck of playing cards:",
    ),
    html.div([attribute.class("grid grid-cols-4 w-fit m-auto gap-4")], [
      html.img([attribute.src("/cards/spades_jack.svg")]),
      html.img([attribute.src("/cards/spades_queen.svg")]),
      html.img([attribute.src("/cards/spades_king.svg")]),
      html.img([attribute.src("/cards/spades_ace.svg")]),
      html.img([attribute.src("/cards/diamonds_jack.svg")]),
      html.img([attribute.src("/cards/diamonds_queen.svg")]),
      html.img([attribute.src("/cards/diamonds_king.svg")]),
      html.img([attribute.src("/cards/diamonds_ace.svg")]),
      html.img([attribute.src("/cards/clubs_jack.svg")]),
      html.img([attribute.src("/cards/clubs_queen.svg")]),
      html.img([attribute.src("/cards/clubs_king.svg")]),
      html.img([attribute.src("/cards/clubs_ace.svg")]),
      html.img([attribute.src("/cards/hearts_jack.svg")]),
      html.img([attribute.src("/cards/hearts_queen.svg")]),
      html.img([attribute.src("/cards/hearts_king.svg")]),
      html.img([attribute.src("/cards/hearts_ace.svg")]),
    ]),
    html.text(
      "To start the game, each player shuffles their deck, then draws 4 cards.",
    ),
  ])
}
