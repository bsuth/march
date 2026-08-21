import blocks/old_game/slot_view.{empty_slot_view, unit_slot_view}
import blocks/old_game/x
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element/html
import old_engine/classic
import old_engine/unit.{type Unit}
import yuzu

pub fn board_view(model: x.Model) {
  html.div(
    [
      attribute.class("grid gap-4"),
      attribute.style(
        "grid-template-columns",
        "repeat(" <> int.to_string(model.game.board.size) <> ", auto)",
      ),
    ],
    int.range(
      model.game.board.size * model.game.board.size - 1,
      -1,
      [],
      fn(children, index) {
        model
        |> board_cell_view(index)
        |> list.prepend(children, _)
      },
    ),
  )
}

fn board_cell_view(model: x.Model, index: Int) {
  case dict.get(model.game.board.cells, index) {
    Ok(option.Some(unit)) -> board_occupied_cell_view(model, unit, index)
    _ -> empty_slot_view(get_move_option(model, index), [])
  }
}

fn board_occupied_cell_view(model: x.Model, unit: Unit, index: Int) {
  unit_slot_view(
    unit,
    {
      use <- yuzu.none_(get_hover_option(model, index))
      use <- yuzu.none_(get_unhover_option(model, index))
      use <- yuzu.none_(get_move_option(model, index))
      use <- yuzu.none_(get_march_option(model, index))
      use <- yuzu.none_(get_undo_option(model, index))
      option.None
    },
    [],
  )
}

fn get_hover_option(model: x.Model, index: Int) {
  use <- yuzu.none(model.hover_index, option.None)
  use cell_moves <- yuzu.ok(dict.get(model.board_moves, index), option.None)

  case cell_moves {
    [] -> option.None
    _ -> option.Some(x.Hover(index))
  }
}

fn get_unhover_option(model: x.Model, index: Int) {
  use hover_index <- yuzu.some(model.hover_index, option.None)

  case index == hover_index {
    True -> option.Some(x.Unhover)
    False -> option.None
  }
}

fn get_move_option(model: x.Model, index: Int) {
  use hover_index <- yuzu.some(model.hover_index, option.None)

  use hover_cell_moves <- yuzu.ok(
    dict.get(model.board_moves, hover_index),
    option.None,
  )

  echo hover_cell_moves

  case list.any(hover_cell_moves, fn(move) { move.1 == index }) {
    True -> option.Some(x.Move(hover_index, index))
    False -> option.None
  }
}

fn get_march_option(model: x.Model, index: Int) {
  case list.contains(model.board_marches, index) {
    True -> option.Some(x.March(index))
    False -> option.None
  }
}

fn get_undo_option(model: x.Model, index: Int) {
  case model.game.history {
    [classic.Move(_, dest_index, _), ..] -> {
      case index == dest_index {
        True -> option.Some(x.Undo)
        False -> option.None
      }
    }

    [classic.March(_, dest_index), ..] -> {
      case index == dest_index {
        True -> option.Some(x.Undo)
        False -> option.None
      }
    }

    [classic.Deploy(_), ..] -> {
      let active_player_base_index =
        classic.get_base_index(model.game.board, model.game.active_player_color)

      case index == active_player_base_index {
        True -> option.Some(x.Undo)
        False -> option.None
      }
    }

    _ -> option.None
  }
}
