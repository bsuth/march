import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import x.{type Model, type Msg}

const navbar_routes = [
  #("/", "Home"),
  #("/learn", "Learn"),
  #("/versus", "Versus"),
  #("/cheatsheet", "CheatSheet"),
]

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.nav([attribute.class("bg-gray-900"), ..attrs], [
    html.ul(
      [attribute.class("flex justify-center")],
      list.map(navbar_routes, fn(navbar_route) {
        html.li([], [
          html.a(
            [
              attribute.class("p-4 block hover:bg-gray-700 text-white"),
              attribute.href(navbar_route.0),
            ],
            [html.text(navbar_route.1)],
          ),
        ])
      }),
    ),
  ])
}
