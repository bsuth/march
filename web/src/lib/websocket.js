export function new_(url) {
  return new WebSocket(url);
}

export function send(ws, msg) {
  ws.send(msg);
}

export function on_open(ws, callback) {
  ws.addEventListener("open", callback);
}

export function on_message(ws, callback) {
  ws.addEventListener("message", ({ data }) => {
    if (typeof data === "string") {
      // To keep things simple, we assume the event data is always a string.
      // However, this could technically be an ArrayBuffer or Blob, which may
      // need to be properly handled in the future.
      //
      // See: https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/message_event#event_properties
      callback(data)
    }
  });
}

export function on_close(ws, callback) {
  ws.addEventListener("close", callback);
}

export function on_error(ws, callback) {
  ws.addEventListener("error", callback);
}
