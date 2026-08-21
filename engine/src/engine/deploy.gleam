import engine/board.{type Board}
import engine/card.{type Card}
import engine/player.{type Player}
import gleam/option.{type Option}
import yuzu

pub fn commit(card: Option(Card), player: Player, board: Board) {
  let base_index = board.get_base_index(board, player.color)

  case card {
    option.Some(card) -> {
      use <- yuzu.true(board.is_none(board, base_index), Error(Nil))
      use player <- yuzu.ok(player.deploy(player, card), Error(Nil))
      Ok(#(player, board))
    }

    option.None -> {
      case board.is_some(board, base_index) {
        True -> Ok(#(player, board))
        False -> Error(Nil)
      }
    }
  }
}
