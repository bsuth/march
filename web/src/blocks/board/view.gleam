import blocks/board/model.{type Model}
import blocks/board/view/card_view.{card_view}
import engine/board
import engine/board/cell.{Cell}
import engine/color.{type Color}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import lib/theme.{type Theme}
import lustre/attribute
import lustre/element
import lustre/element/html
import phosphor
import yuzu

pub fn view(model: Model) {
  html.div(
    [
      attribute.class("grid gap-0"),
      attribute.style(
        "grid-template-columns",
        "repeat(" <> int.to_string(model.board.width) <> ", 1fr)",
      ),
      attribute.style(
        "grid-template-rows",
        "repeat(" <> int.to_string(model.board.height) <> ", 1fr)",
      ),
    ],
    int.range(0, model.board.width * model.board.height, [], fn(cells, index) {
      cell_view(model, model.board.width * model.board.height - 1 - index)
      |> list.prepend(cells, _)
    }),
  )
}

fn cell_view(model: Model, render_index: Int) {
  let white_base_index = board.get_base_index(model.board, color.White)

  let cell_index = case model.color {
    color.White -> render_index
    color.Black -> model.board.width * model.board.height - 1 - render_index
  }

  use cell <- yuzu.ok(dict.get(model.board.cells, cell_index), element.none())

  html.div(
    [
      attribute.class("aspect-square"),
      attribute.class("flex justify-center items-center"),
      attribute.class("border-b border-r"),
      attribute.class("cursor-pointer"),
      case render_index / model.board.width {
        0 -> attribute.class("border-t")
        _ -> attribute.none()
      },
      case render_index % model.board.width {
        0 -> attribute.class("border-l")
        _ -> attribute.none()
      },
    ],
    [
      case cell, cell_index {
        Cell(_, _, option.Some(card)), _ ->
          card_view([attribute.class("w-full h-full")], card)

        _, 0 -> base_icon_view(color.Black, model.theme)

        _, _ if cell_index == white_base_index ->
          base_icon_view(color.White, model.theme)

        _, _ -> element.none()
      },
    ],
  )
}

fn base_icon_view(color: Color, theme: Theme) {
  let icon = case color, theme {
    color.White, theme.Light -> phosphor.castle_turret_light
    color.White, theme.Dark -> phosphor.castle_turret_fill
    color.Black, theme.Light -> phosphor.castle_turret_fill
    color.Black, theme.Dark -> phosphor.castle_turret_light
  }

  icon([attribute.class("size-1/2")])
}
