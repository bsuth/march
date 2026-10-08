import components/icon_button
import lib/theme
import lustre/attribute
import lustre/element/html
import lustre/event
import main/message
import main/model.{type Model}
import phosphor
import routes

pub fn view(model: Model) {
  let app = model.get_app(model)

  html.div(
    [
      attribute.class("h-dvh flex flex-col overflow-auto"),
      attribute.class("bg-(--march-100)"),
      attribute.class("text-(--march-950)"),
    ],
    [
      html.nav(
        [
          attribute.class("px-16 py-2"),
          attribute.class("flex justify-between items-center gap-2"),
        ],
        [
          html.ul([attribute.class("flex justify-center")], [
            navbar_item_view("Home", "/"),
            navbar_item_view("Learn", "/learn"),
            navbar_item_view("About", "/about"),
          ]),
          icon_button.element([event.on_click(message.ToggleTheme)], [
            case app.theme {
              theme.Light -> phosphor.sun_fill([attribute.class("size-6")])
              theme.Dark -> phosphor.moon_fill([attribute.class("size-6")])
            },
          ]),
        ],
      ),
      routes.view(model, []),
    ],
  )
}

fn navbar_item_view(label: String, href: String) {
  html.li([], [
    html.a(
      [
        attribute.class("p-4 block"),
        attribute.class("hover:text-blue-600"),
        attribute.href(href),
      ],
      [html.text(label)],
    ),
  ])
}
