import gleam/option.{type Option}

pub fn true(
  condition: Bool,
  default_return_value: return_value,
  callback: fn() -> return_value,
) {
  case condition {
    True -> callback()
    False -> default_return_value
  }
}

pub fn false(
  condition: Bool,
  default_return_value: return_value,
  callback: fn() -> return_value,
) {
  case condition {
    True -> default_return_value
    False -> callback()
  }
}

pub fn ok(
  result: Result(ok_value, error_value),
  default_return_value: return_value,
  callback: fn(ok_value) -> return_value,
) {
  case result {
    Ok(ok_value) -> callback(ok_value)
    Error(_) -> default_return_value
  }
}

pub fn ok_(
  result: Result(ok_value, error_value),
  callback: fn(ok_value) -> Result(ok_value, error_value),
) {
  case result {
    Ok(ok_value) -> callback(ok_value)
    Error(_) -> result
  }
}

pub fn error(
  result: Result(ok_value, error_value),
  default_return_value: return_value,
  callback: fn(error_value) -> return_value,
) {
  case result {
    Ok(_) -> default_return_value
    Error(error_value) -> callback(error_value)
  }
}

pub fn error_(
  result: Result(ok_value, error_value),
  callback: fn(error_value) -> Result(ok_value, error_value),
) {
  case result {
    Ok(_) -> result
    Error(error_value) -> callback(error_value)
  }
}

pub fn some(
  option: Option(some_value),
  default_return_value: return_value,
  callback: fn(some_value) -> return_value,
) {
  case option {
    option.Some(some_value) -> callback(some_value)
    option.None -> default_return_value
  }
}

pub fn some_(
  option: Option(some_value),
  callback: fn(some_value) -> Option(some_value),
) {
  case option {
    option.Some(some_value) -> callback(some_value)
    option.None -> option
  }
}

pub fn none(
  option: Option(some_value),
  default_return_value: return_value,
  callback: fn() -> return_value,
) {
  case option {
    option.Some(_) -> default_return_value
    option.None -> callback()
  }
}

pub fn none_(option: Option(some_value), callback: fn() -> Option(some_value)) {
  case option {
    option.Some(_) -> option
    option.None -> callback()
  }
}

pub fn non_empty_list(
  items: List(element),
  default_return_value: return_value,
  callback: fn(element, List(element)) -> return_value,
) {
  case items {
    [head, ..tail] -> callback(head, tail)
    [] -> default_return_value
  }
}
