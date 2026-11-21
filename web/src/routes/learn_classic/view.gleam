import blocks/board
import components/button
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor
import routes/learn_classic/message.{type Message}
import routes/learn_classic/model.{type Model}

pub fn view(model: Model) {
  html.div([attribute.class("max-w-4xl mx-auto p-16")], [
    case model.chapter_index {
      1 -> setup_view()
      _ -> introduction_view()
    },

    html.div([attribute.class("flex items-center gap-2")], [
      button.element(
        [
          button.class("w-32"),
          event.on_click(message.PreviousChapter),
        ],
        [
          phosphor.arrow_left_regular([]),
          html.text("Previous"),
        ],
      ),
      button.element(
        [
          button.class("w-32"),
          event.on_click(message.NextChapter),
        ],
        [
          html.text("Next"),
          phosphor.arrow_right_regular([]),
        ],
      ),
    ]),
  ])
}

fn introduction_view() {
  section_view("Introduction", [
    html.p([], [
      html.text(
        "This is the tutorial for the classic mode for March. Classic Mode is
        considered to be the \"purest\" way to play and the recommended game mode
        to start with, as other game modes will build off of the rules
        introduced here.",
      ),
    ]),
    html.p([], [
      html.text(
        "Fun Fact: This game mode remains surprisingly close to the very
        first ruleset, back when March was being play tested for the first time
        with coworkers. Since then, additional game modes have been introduced,
        hence why this game mode is now called \"Classic\" mode.",
      ),
    ]),
  ])
}

fn setup_view() {
  html.section([], [
    html.h2([], [html.text("Setup")]),
    html.text(
      "March is played with two players sitting on opposing sides of a 4x4 grid.
      Each player's respective bottom right corner constitutes their \"base\",
      which serves a central role during gameplay.",
    ),
    html.div([attribute.class("flex flex-col gap-4 items-center")], [
      phosphor.person_regular([attribute.class("size-12")]),
      board.element([
        attribute.class("w-64 h-64"),
      ]),
      phosphor.person_fill([attribute.class("size-12")]),
    ]),
    html.text(
      "Each player uses their own deck consisting of the Jacks, Queens, Kings,
      and Aces from a standard deck of playing cards:",
    ),
    html.div([attribute.class("w-xl h-xl grid grid-cols-4 m-auto gap-4")], [
      html.img([attribute.src("/decks/default_black/JS.png")]),
      html.img([attribute.src("/decks/default_black/QS.png")]),
      html.img([attribute.src("/decks/default_black/KS.png")]),
      html.img([attribute.src("/decks/default_black/AS.png")]),
      html.img([attribute.src("/decks/default_black/JD.png")]),
      html.img([attribute.src("/decks/default_black/QD.png")]),
      html.img([attribute.src("/decks/default_black/KD.png")]),
      html.img([attribute.src("/decks/default_black/AD.png")]),
      html.img([attribute.src("/decks/default_black/JC.png")]),
      html.img([attribute.src("/decks/default_black/QC.png")]),
      html.img([attribute.src("/decks/default_black/KC.png")]),
      html.img([attribute.src("/decks/default_black/AC.png")]),
      html.img([attribute.src("/decks/default_black/JH.png")]),
      html.img([attribute.src("/decks/default_black/QH.png")]),
      html.img([attribute.src("/decks/default_black/KH.png")]),
      html.img([attribute.src("/decks/default_black/AH.png")]),
    ]),
    html.text(
      "To start the game, each player shuffles their deck, then draws 4 cards.",
    ),
  ])
}

fn section_view(title: String, children: List(Element(Message))) {
  html.section([attribute.class("flex flex-col gap-4")], [
    html.div([], [
      html.h3([], [html.text(title)]),
      html.h6([attribute.class("text-(--march-600)")], [
        html.text("Classic Mode"),
      ]),
    ]),
    ..children
  ])
}
