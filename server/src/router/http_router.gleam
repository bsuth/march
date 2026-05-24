import wisp

pub fn handler(req: wisp.Request) -> wisp.Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes()
  use req <- wisp.handle_head(req)
  use _ <- wisp.csrf_known_header_protection(req)
  wisp.html_response("<h1>Hello World!</h1>", 200)
}
