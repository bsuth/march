import blocks/board
import components/admonition
import components/button
import lustre/attribute
import lustre/element/html
import lustre/event
import phosphor
import routes/learn_classic/chapter
import routes/learn_classic/message
import routes/learn_classic/model.{type Model}

pub fn view(model: Model) {
  html.div(
    [
      attribute.class("grow w-full max-w-4xl mx-auto p-16"),
      attribute.class("flex flex-col gap-4"),
    ],
    [
      case model.chapter {
        chapter.Introduction -> chapter_introduction_view()
        chapter.Deck -> chapter_deck_view()
        chapter.Board -> chapter_board_view()
        chapter.Turn -> chapter_turn_view()
        chapter.Leading -> chapter_leading_view(model)
        chapter.Marching -> chapter_marching_view(model)
        chapter.Deploying -> chapter_deploying_view(model)
        chapter.Capturing -> chapter_capturing_view(model)
        chapter.Winning -> chapter_winning_view(model)
        chapter.Conclusion -> chapter_conclusion_view()
      },
      footer_view(model),
    ],
  )
}

fn chapter_introduction_view() {
  html.div([attribute.class("grow flex flex-col gap-4")], [
    title_view("Introduction"),
    html.p([], [
      html.text(
        "This is the tutorial for Classic Mode. Classic Mode is the recommended
        game mode to start with, as other game modes will build off of the rules
        introduced here.",
      ),
    ]),
    admonition.element([admonition.variant(admonition.Tip)], [
      html.text(
        "This game mode remains surprisingly close to the very
        first ruleset, back when March was being play tested for the first time
        with coworkers. Since then, additional game modes have been introduced,
        hence why this game mode is now called \"Classic Mode\".",
      ),
    ]),
  ])
}

fn chapter_deck_view() {
  html.div([attribute.class("grow flex gap-8")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("The Deck"),
      html.p([], [
        html.text(
          "Each player uses their own deck of cards consisting of the Jacks,
          Queens, Kings, and Aces from a standard deck of playing cards.",
        ),
      ]),
      html.p([], [
        html.text(
          "At the start of the game, each player shuffles their deck, then
          draws 4 cards.",
        ),
      ]),
    ]),
    html.div([attribute.class("flex-1 grid grid-cols-4 mb-auto gap-4")], [
      html.img([attribute.src("/decks/default_black/JS.png")]),
      html.img([attribute.src("/decks/default_black/JD.png")]),
      html.img([attribute.src("/decks/default_black/JC.png")]),
      html.img([attribute.src("/decks/default_black/JH.png")]),
      html.img([attribute.src("/decks/default_black/QS.png")]),
      html.img([attribute.src("/decks/default_black/QD.png")]),
      html.img([attribute.src("/decks/default_black/QC.png")]),
      html.img([attribute.src("/decks/default_black/QH.png")]),
      html.img([attribute.src("/decks/default_black/KS.png")]),
      html.img([attribute.src("/decks/default_black/KD.png")]),
      html.img([attribute.src("/decks/default_black/KC.png")]),
      html.img([attribute.src("/decks/default_black/KH.png")]),
      html.img([attribute.src("/decks/default_black/AS.png")]),
      html.img([attribute.src("/decks/default_black/AD.png")]),
      html.img([attribute.src("/decks/default_black/AC.png")]),
      html.img([attribute.src("/decks/default_black/AH.png")]),
    ]),
  ])
}

fn chapter_board_view() {
  html.div([attribute.class("grow flex gap-8 min-h-96")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("The Board"),
      html.p([], [
        html.text(
          "Classic Mode is played with two players sitting on opposing sides of
          a 4x4 grid.",
        ),
      ]),
      html.p([], [
        html.text(
          "Each player's respective bottom right corner constitutes their
          \"base\", which serves a central role during gameplay.",
        ),
      ]),
    ]),
    html.div([attribute.class("flex-1 min-w-0 h-fit aspect-5/7")], [
      board.element([]),
    ]),
  ])
}

fn chapter_turn_view() {
  html.div([attribute.class("grow flex flex-col gap-4")], [
    title_view("Turn Overview"),
    html.text(
      "Players alternate taking turns until the game is over, with each turn
      consisting of the following steps:",
    ),
    html.ol([], [
      html.li([], [html.text("1. Leading")]),
      html.li([], [html.text("2. Marching")]),
      html.li([], [html.text("3. Deploying")]),
    ]),
    html.text(
      "In the next chapters, we'll take a closer look at each of these
      steps.",
    ),
  ])
}

fn chapter_leading_view(model: Model) {
  html.div([attribute.class("grow flex gap-8 min-h-96")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("Leading"),
      html.p([], [
        html.text(
          "At the beginning of your turn, you MUST move a card on the board
          if possible. This first card move is called the \"Lead\", and is
          allowed more freedom than subsequent marching (as we will see in the
          next section).",
        ),
      ]),
      html.p([], [
        html.text(
          "In Classic Mode, every card is allowed to move exactly one
          square in any of the four cardinal directions, i.e. Up, Down, Left, or
          Right.",
        ),
      ]),
      html.p([], [
        html.text(
          "Go ahead and try moving the card around on the board. First, click on
          the card to select it, then click on the destination to move it.",
        ),
      ]),
    ]),
    html.div([attribute.class("flex-1 min-w-0 h-fit aspect-5/7")], [
      board.element([
        board.highlight_index(model.board_hover_index),
        board.position(model.board_position),
        board.on_cell_click(message.LeadBoardClick),
      ]),
    ]),
  ])
}

fn chapter_marching_view(model: Model) {
  html.div([attribute.class("grow flex gap-8 min-h-96")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("Marching"),
      html.p([], [
        html.text("TODO"),
      ]),
    ]),
    html.div([attribute.class("flex-1 min-w-0 h-fit aspect-5/7")], [
      board.element([
        board.highlight_index(model.board_hover_index),
        board.position(model.board_position),
        board.on_cell_click(message.LeadBoardClick),
      ]),
    ]),
  ])
}

fn chapter_deploying_view(model: Model) {
  html.div([attribute.class("grow flex gap-8 min-h-96")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("Deploying"),
      html.p([], [
        html.text("TODO"),
      ]),
    ]),
    html.div([attribute.class("flex-1 min-w-0 h-fit aspect-5/7")], [
      board.element([
        board.highlight_index(model.board_hover_index),
        board.position(model.board_position),
        board.on_cell_click(message.LeadBoardClick),
      ]),
    ]),
  ])
}

fn chapter_capturing_view(model: Model) {
  html.div([attribute.class("grow flex gap-8 min-h-96")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("Capturing"),
      html.p([], [
        html.text("TODO"),
      ]),
    ]),
    html.div([attribute.class("flex-1 min-w-0 h-fit aspect-5/7")], [
      board.element([
        board.highlight_index(model.board_hover_index),
        board.position(model.board_position),
        board.on_cell_click(message.LeadBoardClick),
      ]),
    ]),
  ])
}

fn chapter_winning_view(model: Model) {
  html.div([attribute.class("grow flex gap-8 min-h-96")], [
    html.div([attribute.class("flex-1 flex flex-col gap-4")], [
      title_view("Winning"),
      html.p([], [
        html.text("TODO"),
      ]),
    ]),
    html.div([attribute.class("flex-1 min-w-0 h-fit aspect-5/7")], [
      board.element([
        board.highlight_index(model.board_hover_index),
        board.position(model.board_position),
        board.on_cell_click(message.LeadBoardClick),
      ]),
    ]),
  ])
}

fn chapter_conclusion_view() {
  html.div([attribute.class("grow flex flex-col gap-4")], [
    title_view("Conclusion"),
    html.p([], [
      html.text("TODO"),
    ]),
  ])
}

fn title_view(title: String) {
  html.div([], [
    html.h3([], [
      html.text(title),
    ]),
    html.h6([attribute.class("text-(--march-600)")], [
      html.text("Classic Mode"),
    ]),
  ])
}

fn footer_view(model: Model) {
  html.div([attribute.class("flex justify-center items-center gap-2")], [
    html.a(
      case chapter.previous(model.chapter) {
        Ok(previous_chapter) -> [attribute.href(chapter.url(previous_chapter))]
        _ -> [attribute.class("invisible")]
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
        event.on_click(message.ToggleTableOfContents),
      ],
      [phosphor.list_bullets_regular([attribute.class("min-h-lh")])],
    ),
    html.a(
      case chapter.next(model.chapter) {
        Ok(next_chapter) -> [attribute.href(chapter.url(next_chapter))]
        _ -> [attribute.class("invisible")]
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
