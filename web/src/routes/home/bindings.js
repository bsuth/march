export function set_timeout(callback, timeout_ms) {
  return window.setTimeout(callback, timeout_ms)
}

export function clear_timeout(timeout_id) {
  return window.clearTimeout(timeout_id)
}
