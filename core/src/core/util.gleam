import yuzu

pub fn get_list_index(list: List(a), index: Int) {
  use <- yuzu.false(index < 0, Error(Nil))
  use head, tail <- yuzu.non_empty_list(list, Error(Nil))

  case index {
    0 -> Ok(head)
    _ -> get_list_index(tail, index - 1)
  }
}

pub fn set_list_index(list: List(a), index: Int, value: a) {
  use <- yuzu.true(index > -1, Error(Nil))
  use head, tail <- yuzu.non_empty_list(list, Error(Nil))
  use <- yuzu.false(index == 0, Ok([value, ..tail]))

  case set_list_index(tail, index - 1, value) {
    Ok(tail) -> Ok([head, ..tail])
    error -> error
  }
}
