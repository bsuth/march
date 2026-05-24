import gleam/option.{None}
import mist.{type WebsocketConnection}
import wisp

pub type MyMessage {
  Broadcast(String)
}

pub fn on_init(_conn: WebsocketConnection) {
  wisp.log_info("ws init")
  #(Nil, None)
}

pub fn on_close(_state: state) -> Nil {
  wisp.log_info("ws close")
  Nil
}

pub fn handler(state, message, conn: WebsocketConnection) {
  case message {
    mist.Text("ping") -> {
      let assert Ok(_) = mist.send_text_frame(conn, "pong")
      mist.continue(state)
    }

    mist.Text(msg) -> {
      wisp.log_info("Received text frame: " <> msg)
      mist.continue(state)
    }

    mist.Binary(_msg) -> {
      wisp.log_info("Received binary frame")
      mist.continue(state)
    }

    mist.Custom(Broadcast(text)) -> {
      let assert Ok(_) = mist.send_text_frame(conn, text)
      mist.continue(state)
    }

    mist.Closed | mist.Shutdown -> mist.stop()
  }
}
