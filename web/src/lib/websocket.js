const WEBSOCKET_RECONNECT_INTERVAL_MS = 3000;

export function new_(url) {
  return {
    url,
    ws: null,
    queue: [],
    listeners: {} ,
  }
}

export function connect(conn) {
  if (conn.ws != null) {
    return;
  }

  console.log("connecting");
  conn.ws = new WebSocket(conn.url);

  conn.ws.addEventListener("open", () => {
    for (const message of conn.queue) {
      conn.ws.send(message);
    }

    conn.queue = [];
    conn.listeners?.open();
  });

  conn.ws.addEventListener("message", ({ data }) => {
    if (typeof data === "string") {
      // To keep things simple, we assume the event data is always a string.
      // However, this could technically be an ArrayBuffer or Blob, which may
      // need to be properly handled in the future.
      //
      // See: https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/message_event#event_properties
      conn.listeners?.message(data);
    }
  });

  conn.ws.addEventListener("close", () => {
    conn.ws = null;
    conn.listeners?.close();
    setTimeout(() => void connect(conn), WEBSOCKET_RECONNECT_INTERVAL_MS);
  });

  conn.ws.addEventListener("error", () => {
    conn.listeners?.error();
  });
}

export function on_open(conn, callback) {
  conn.listeners.open = callback;
}

export function on_message(conn, callback) {
  conn.listeners.message = callback;
}

export function on_close(conn, callback) {
  conn.listeners.close = callback;
}

export function on_error(conn, callback) {
  conn.listeners.error = callback;
}

export function send(conn, message) {
  if (conn.ws?.readyState === WebSocket.OPEN) {
    conn.ws.send(message);
  } else {
    conn.queue.push(message);
  }
}
