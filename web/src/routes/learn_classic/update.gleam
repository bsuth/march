import core/engine/move
import core/engine/position
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import lustre/effect
import routes/learn_classic/message.{type Message}
import routes/learn_classic/model.{type Model, Model}
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.LeadBoardClick(click_index) -> lead_board_click(model, click_index)
    message.ToggleTableOfContents -> #(
      Model(..model, show_table_of_contents: !model.show_table_of_contents),
      effect.none(),
    )
  }
}

fn lead_board_click(model: Model, click_index: Int) {
  use click_card <- yuzu.ok(dict.get(model.board_position, click_index), #(
    Model(..model, board_hover_index: option.None),
    effect.none(),
  ))

  use board_hover_index <- yuzu.some(model.board_hover_index, #(
    Model(
      ..model,
      board_hover_index: option.map(click_card, fn(_) { click_index }),
    ),
    effect.none(),
  ))

  use <- yuzu.true(
    board_hover_index
      |> move.list_raw_dest_indices(model.board_position, model.engine_settings)
      |> list.contains(click_index),
    #(Model(..model, board_hover_index: option.None), effect.none()),
  )

  #(
    Model(
      ..model,
      board_hover_index: option.None,
      board_position: position.move_one(model.board_position, #(
        board_hover_index,
        click_index,
      )),
    ),
    effect.none(),
  )
}
