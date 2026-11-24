import blocks/board
import blocks/card
import components/admonition
import components/button
import core/engine/card_art
import core/engine/face.{type Face}
import core/engine/position_card.{PositionCard}
import core/engine/suit.{type Suit}
import gleam/dict
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor
import routes/learn_classic/chapter
import routes/learn_classic/message.{type Message}
import routes/learn_classic/model.{type Model}
import views/tutorial

pub fn view(model: Model) {
  tutorial.root_view([
    case model.show_table_of_contents, model.chapter {
      True, _ ->
        tutorial.table_of_contents_view(
          chapter.title(model.chapter),
          list.map(chapter.list, fn(chapter) {
            #(chapter.title(chapter), chapter.url(chapter))
          }),
        )

      _, chapter.Introduction -> chapter_introduction_view(model)
      _, chapter.Deck -> chapter_deck_view(model)
      _, chapter.Board -> chapter_board_view(model)
      _, chapter.TurnOverview -> chapter_turn_overview_view(model)
      _, chapter.Deploying -> chapter_deploying_view(model)
      _, chapter.Leading -> chapter_leading_view(model)
      _, chapter.Marching -> chapter_marching_view(model)
      _, chapter.TurnRecap -> chapter_turn_recap_view(model)
      _, chapter.Capturing -> chapter_capturing_view(model)
      _, chapter.CapturingPractice -> chapter_capturing_practice_view(model)
      _, chapter.Winning -> chapter_winning_view(model)
      _, chapter.Yielding -> chapter_yielding_view(model)
      _, chapter.Conclusion -> chapter_conclusion_view(model)
    },
    tutorial.footer_view(
      case chapter.previous(model.chapter), model.show_table_of_contents {
        Ok(chapter), False -> option.Some(chapter.url(chapter))
        _, _ -> option.None
      },
      case chapter.next(model.chapter), model.show_table_of_contents {
        Ok(next_chapter), False -> option.Some(chapter.url(next_chapter))
        _, _ -> option.None
      },
      message.ToggleTableOfContents,
    ),
  ])
}

fn chapter_introduction_view(model: Model) {
  section_view(model, [
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

fn chapter_deck_view(model: Model) {
  split_section_view(
    model,
    [
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
    ],
    [
      html.div([attribute.class("grid grid-cols-4 mb-auto gap-4")], [
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
    ],
  )
}

fn chapter_board_view(model: Model) {
  split_section_view(
    model,
    [
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
    ],
    [
      html.div([attribute.class("aspect-5/7")], [
        board.element([]),
      ]),
    ],
  )
}

fn chapter_turn_overview_view(model: Model) {
  section_view(model, [
    html.text(
      "Players alternate taking turns until the game is over, with each turn
      consisting of the following steps:",
    ),
    html.ol([], [
      html.li([], [html.text("1. Leading")]),
      html.li([], [html.text("2. Marching")]),
      html.li([], [html.text("3. Deploying")]),
    ]),
    html.p([], [
      html.text(
        "Leading / Marching both have to do with moving cards around on the
        board and are always skipped on the first turn of the game, so let's
        start with learning about Deploying.",
      ),
    ]),
  ])
}

fn chapter_deploying_view(model: Model) {
  split_section_view(
    model,
    [
      html.p([], [
        html.text(
          "Before a player can end their turn, they must play a card from their
          hand onto their base if possible, i.e. if the base is empty and the
          player has cards in their hand. If the player deployed a card, they
          additionally draws a card from their deck into their hand.",
        ),
      ]),
      html.p([], [
        html.text(
          "Go ahead and try deploying by clicking on any of the cards in your
          hand (represented by the cards below the board).",
        ),
      ]),
      html.p([], [
        html.text(
          "After deploying a card, you may click on the deployed card to undo
          it, or click on another card in hand to replace it.",
        ),
      ]),
      tutorial.deployment_alert_view(
        model.turn_request_engine,
        model.turn_request,
      ),
    ],
    [
      tutorial.game_view(
        model.turn_request_engine,
        model.turn_request,
        message.OnUpdateTurnRequest,
        message.Deploy,
      ),
    ],
  )
}

fn chapter_leading_view(model: Model) {
  split_section_view(
    model,
    [
      html.p([], [
        html.text(
          "At the beginning of your turn, you MUST move one of your cards on the
          board if possible. In Classic Mode, cards are allowed to move one
          square up, down, left, or right.",
        ),
      ]),
      html.p([], [
        html.text(
          "Go ahead and click on your card to select it, then click on the
          destination to move it.",
        ),
      ]),
      html.p([], [
        html.text(
          "After moving a card, you may undo by clicking on it again, or
          continue your turn by deploying a card from your hand.",
        ),
      ]),
      tutorial.lead_alert_view(model.engine, model.turn_request),
      tutorial.deployment_alert_view(
        model.turn_request_engine,
        model.turn_request,
      ),
    ],
    [
      tutorial.game_view(
        model.turn_request_engine,
        model.turn_request,
        message.OnUpdateTurnRequest,
        message.Deploy,
      ),
    ],
  )
}

fn chapter_marching_view(model: Model) {
  split_section_view(
    model,
    [
      html.p([], [
        html.text(
          "When moving a card, you may additionally move either a card directly
          below or to the right to fill the otherwise empty space left behind.",
        ),
      ]),
      html.p([], [
        html.text(
          "This is known as \"marching\", and can be chained together to move
          many cards in a single turn.",
        ),
      ]),
      html.p([], [
        html.text(
          "Try marching the card currently on your base after leading with the
          other card. When marching, you only need to click on the card once to
          move it, since the destination is already pre-determined.",
        ),
      ]),
      tutorial.lead_alert_view(model.engine, model.turn_request),
      tutorial.march_alert_view(model.turn_request),
      tutorial.deployment_alert_view(
        model.turn_request_engine,
        model.turn_request,
      ),
    ],
    [
      tutorial.game_view(
        model.turn_request_engine,
        model.turn_request,
        message.OnUpdateTurnRequest,
        message.Deploy,
      ),
    ],
  )
}

fn chapter_turn_recap_view(model: Model) {
  split_section_view(
    model,
    [
      html.text("Remember that every turn consists of the following steps:"),
      html.ol([], [
        html.li([], [html.text("1. Leading")]),
        html.li([], [html.text("2. Marching")]),
        html.li([], [html.text("3. Deploying")]),
      ]),
      html.text(
        "Feel free to take a moment and play around with the many different
        turns possible in this more advanced position.",
      ),
      tutorial.lead_alert_view(model.engine, model.turn_request),
      tutorial.march_alert_view(model.turn_request),
      tutorial.deployment_alert_view(
        model.turn_request_engine,
        model.turn_request,
      ),
      tutorial.valid_turn_alert_view(model.engine, model.turn_request),
      button.element(
        [
          attribute.class("w-fit"),
          button.disabled(option.is_none(model.turn_request.lead)),
          event.on_click(message.ResetTurnRequest),
        ],
        [html.text("Reset Position")],
      ),
    ],
    [
      tutorial.game_view(
        model.turn_request_engine,
        model.turn_request,
        message.OnUpdateTurnRequest,
        message.Deploy,
      ),
    ],
  )
}

fn chapter_capturing_view(model: Model) {
  section_view(model, [
    html.p([], [
      html.text(
        "When leading, you may remove an opponent's card from play by moving
        your card on top of theirs. However, some conditions must be met.",
      ),
    ]),
    html.p([], [
      html.text(
        "If the cards have suits of the same color (i.e. both black or both red),
        the opponent's card may only be captured if it has a face value less
        than or equal to the player's card:",
      ),
    ]),
    html.h5([attribute.class("text-center")], [
      html.text("J < Q < K < A"),
    ]),
    html.p([], [
      html.text("For example:"),
    ]),
    capture_examples_view([
      #(face.King, suit.Hearts, face.Jack, suit.Hearts),
      #(face.King, suit.Diamonds, face.Jack, suit.Hearts),
      #(face.King, suit.Diamonds, face.King, suit.Hearts),
    ]),
    html.p([], [
      html.text(
        "If the cards have suits of opposite color (i.e. red vs black suits),
        then your card's suit must be strong against the opponent's. Each
        suit is strong against one suit and weak the other:",
      ),
    ]),
    suit_comparison_grid_view(),
    html.p([], [
      html.text("For example:"),
    ]),
    capture_examples_view([
      #(face.King, suit.Spades, face.Jack, suit.Diamonds),
      #(face.Jack, suit.Hearts, face.King, suit.Spades),
      #(face.Queen, suit.Clubs, face.Ace, suit.Hearts),
    ]),
  ])
}

fn chapter_capturing_practice_view(model: Model) {
  split_section_view(
    model,
    [
      html.p([], [
        html.text(
          "You can use this section to practice capturing before moving on.
          It's recommended to take some time here, as capturing is both one of
          the trickiest and most important concepts to understand.",
        ),
      ]),
      html.p([], [
        html.text("Same Suit Color Rules:"),
      ]),
      html.h5([attribute.class("text-center")], [
        html.text("J < Q < K < A"),
      ]),
      html.p([], [
        html.text("Opposite Suit Color Rules:"),
      ]),
      suit_comparison_grid_view(),
      tutorial.capture_alert_view(model.engine, model.turn_request),
      button.element(
        [
          attribute.class("w-fit"),
          button.disabled(option.is_none(model.turn_request.lead)),
          event.on_click(message.ResetTurnRequest),
        ],
        [html.text("Reset Position")],
      ),
      button.element(
        [
          attribute.class("w-fit"),
          event.on_click(message.ShuffleCards),
        ],
        [html.text("Shuffle Cards")],
      ),
    ],
    [
      tutorial.game_view(
        model.turn_request_engine,
        model.turn_request,
        message.OnUpdateTurnRequest,
        message.Deploy,
      ),
    ],
  )
}

fn chapter_winning_view(model: Model) {
  split_section_view(
    model,
    [
      html.p([], [
        html.text(
          "The first player to move one of their cards onto the
          opponent's base wins the game.",
        ),
      ]),
      html.p([], [
        html.text("In the position on the right, black wins!"),
      ]),
    ],
    [
      html.div([attribute.class("aspect-5/7")], [
        board.element([
          [
            PositionCard(0, face.Ace, suit.Spades),
            PositionCard(0, face.Queen, suit.Hearts),
            PositionCard(0, face.King, suit.Clubs),
            PositionCard(1, face.King, suit.Clubs),
            PositionCard(0, face.Jack, suit.Diamonds),
            PositionCard(1, face.Queen, suit.Spades),
            PositionCard(1, face.Jack, suit.Hearts),
            PositionCard(1, face.Jack, suit.Diamonds),
            PositionCard(0, face.Ace, suit.Clubs),
            PositionCard(0, face.Jack, suit.Spades),
            PositionCard(1, face.Jack, suit.Clubs),
            PositionCard(1, face.Ace, suit.Spades),
            PositionCard(1, face.Ace, suit.Diamonds),
            PositionCard(0, face.Jack, suit.Hearts),
            PositionCard(0, face.King, suit.Diamonds),
            PositionCard(0, face.Queen, suit.Spades),
          ]
          |> list.index_map(fn(card, index) { #(index, option.Some(card)) })
          |> dict.from_list()
          |> board.position(),
        ]),
      ]),
    ],
  )
}

fn chapter_yielding_view(model: Model) {
  split_section_view(
    model,
    [
      html.p([], [
        html.text(
          "In the case that a player cannot do anything on their turn, the turn
          is skipped. This is known as \"yielding\", and happens when a player
          has both no valid leads and cannot deploy any cards.",
        ),
      ]),
      html.p([], [
        html.text(
          "In the position on the right, black cannot make any leads and
          consequently cannot free up space to deploy anything either. In this
          case, black's turn will be skipped.",
        ),
      ]),
    ],
    [
      html.div([attribute.class("aspect-5/7")], [
        board.element([
          [
            PositionCard(0, face.King, suit.Clubs),
            PositionCard(0, face.Jack, suit.Hearts),
            PositionCard(0, face.Queen, suit.Clubs),
            PositionCard(1, face.Jack, suit.Diamonds),
            PositionCard(0, face.Ace, suit.Diamonds),
            PositionCard(0, face.King, suit.Spades),
            PositionCard(1, face.Ace, suit.Spades),
            PositionCard(1, face.Jack, suit.Clubs),
            PositionCard(1, face.Queen, suit.Spades),
            PositionCard(1, face.Queen, suit.Hearts),
            PositionCard(1, face.King, suit.Clubs),
            PositionCard(1, face.Ace, suit.Hearts),
            PositionCard(1, face.Jack, suit.Hearts),
            PositionCard(1, face.King, suit.Spades),
            PositionCard(1, face.Ace, suit.Diamonds),
            PositionCard(1, face.Jack, suit.Spades),
          ]
          |> list.index_map(fn(card, index) { #(index, option.Some(card)) })
          |> dict.from_list()
          |> board.position(),
        ]),
      ]),
    ],
  )
}

fn chapter_conclusion_view(model: Model) {
  section_view(model, [
    html.p([], [
      html.text(
        "That's everything you need to know to start playing Classic Mode!",
      ),
    ]),
    html.p([], [
      html.text(
        "You can click on the button below to go to the Play page, where you
        can enter matchmaking against other players or create a private lobby.",
      ),
    ]),
    html.a([attribute.href("/play")], [
      button.element([], [html.text("Play")]),
    ]),
    html.p([], [
      html.text(
        "Alternatively, you can navigate back to the Learn page to learn about
        the other game modes or look more deeply into the official rules.",
      ),
    ]),
    html.a([attribute.href("/learn")], [
      button.element([], [html.text("Learn")]),
    ]),
  ])
}

fn section_view(model: Model, children: List(Element(Message))) {
  tutorial.section_view(chapter.title(model.chapter), "Classic Mode", children)
}

fn split_section_view(
  model: Model,
  left: List(Element(Message)),
  right: List(Element(Message)),
) {
  tutorial.split_section_view(
    chapter.title(model.chapter),
    "Classic Mode",
    left,
    right,
  )
}

fn capture_examples_view(examples: List(#(Face, Suit, Face, Suit))) {
  html.div(
    [attribute.class("flex flex-wrap justify-center gap-16")],
    list.map(examples, fn(example) {
      html.div([attribute.class("flex items-center gap-2")], [
        card.element([
          attribute.class("w-20"),
          card.variant(card.Front(face: example.0, suit: example.1)),
          card.card_art(card_art.DefaultBlack),
        ]),
        phosphor.arrow_right_regular([attribute.class("size-6")]),
        card.element([
          attribute.class("w-20"),
          card.variant(card.Front(face: example.2, suit: example.3)),
          card.card_art(card_art.DefaultWhite),
        ]),
      ])
    }),
  )
}

fn suit_comparison_grid_view() {
  html.div([attribute.class("p-4")], [
    html.div(
      [
        attribute.class("w-fit m-auto"),
        attribute.class("grid grid-cols-3 justify-center items-center gap-1"),
        attribute.class("rotate-45"),
      ],
      [
        phosphor.spade_fill([attribute.class("size-6 -rotate-45")]),
        phosphor.greater_than_bold([attribute.class("size-6")]),
        phosphor.diamond_fill([
          attribute.class("size-6 text-(--march-suit-red) -rotate-45"),
        ]),
        phosphor.greater_than_bold([attribute.class("size-6 -rotate-90")]),
        html.div([attribute.class("size-6")], []),
        phosphor.greater_than_bold([attribute.class("size-6 rotate-90")]),
        phosphor.heart_fill([
          attribute.class("size-6 text-(--march-suit-red) -rotate-45"),
        ]),
        phosphor.greater_than_bold([attribute.class("size-6 rotate-180")]),
        phosphor.club_fill([attribute.class("size-6 -rotate-45")]),
      ],
    ),
  ])
}
