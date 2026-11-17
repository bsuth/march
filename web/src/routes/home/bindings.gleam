@external(javascript, "./bindings.js", "set_timeout")
pub fn set_timeout(callback: fn() -> Nil, timeout: Int) -> Int

@external(javascript, "./bindings.js", "clear_timeout")
pub fn clear_timeout(timeout_id: Int) -> Nil
