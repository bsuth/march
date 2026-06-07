import blocks/theme_toggle
import lustre/attribute
import lustre/element/html
import main/model.{type Model}
import routes

pub fn view(model: Model) {
  html.div(
    [
      attribute.class("h-dvh flex flex-col overflow-auto"),
      attribute.class("text-(--fg) bg-(--bg-0)"),
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
            navbar_item_view("Versus", "/versus"),
            navbar_item_view("Learn", "/learn"),
            navbar_item_view("About", "/about"),
          ]),
          theme_toggle.element([]),
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
