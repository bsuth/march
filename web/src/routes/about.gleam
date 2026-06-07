import components/text_link
import gleam/string
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import main/message.{type Message}
import phosphor

pub fn view(attrs: List(Attribute(Message))) {
  html.div(
    [
      attribute.class("max-w-3xl m-auto px-4 py-8"),
      attribute.class("flex flex-col gap-12"),
      ..attrs
    ],
    [
      html.div([attribute.class("flex flex-col items-center gap-4")], [
        html.h2([], [
          html.text("About"),
        ]),
        html.p([], [
          html.text(
            string.concat([
              "March was created by a software engineer who likes to play ",
              "game with coworkers after work. It was particular inspired ",
              "after playing the wonderful ",
            ]),
          ),
          text_link.element([text_link.href("https://www.regicidegame.com/")], [
            html.text("Regicide"),
          ]),
          html.text(
            string.concat([
              " and having a coworker express their desire for more modern ",
              "card games that utilize the standard deck of playing cards.",
            ]),
          ),
        ]),
      ]),
      html.div([attribute.class("flex flex-col gap-4 items-center")], [
        html.h2([], [
          html.text("Attributions"),
        ]),
        html.p([], [
          html.text(
            string.concat([
              "This website would not be possible without standing on the ",
              "shoulders of giants. If you have enjoyed March, please take ",
              "the time to check out the following amazing projects and ",
              "consider supporting them as well.",
            ]),
          ),
        ]),
        html.div([attribute.class("w-full flex flex-col gap-4")], [
          attribution_view(
            "Gleam",
            "https://gleam.run/",
            html.img([attribute.class("w-8 h-8"), attribute.src("/gleam.svg")]),
            string.concat([
              "A wonderfully designed type-safe functional programming language ",
              "that can compile to either Erlang or JavaScript. The vast ",
              "majority of March is written in Gleam.",
            ]),
          ),
          attribution_view(
            "Lustre",
            "https://lustre.hexdocs.pm/",
            html.img([attribute.class("w-8 h-8"), attribute.src("/lustre.png")]),
            string.concat([
              "A simple, powerful, and elegant frontend framework inspired by ",
              "Elm and written in Gleam. This page you are reading right now ",
              "is written using Lustre!",
            ]),
          ),
          attribution_view(
            "Phosphor Icons",
            "https://phosphoricons.com/",
            phosphor.phosphor_logo_fill([attribute.class("w-8 h-8")]),
            string.concat([
              "A beautifully designed, open-source icon family distributed ",
              "under the permissive MIT license. This is the icon family ",
              "March uses for all of its icons.",
            ]),
          ),
        ]),
      ]),
    ],
  )
}

fn attribution_view(
  title: String,
  href: String,
  icon: Element(Message),
  description: String,
) {
  html.a(
    [
      attribute.class("p-4 flex flex-col gap-2"),
      attribute.class("rounded"),
      attribute.class("bg-(--bg-1)"),
      attribute.class("hover:bg-(--bg-2)"),
      attribute.class("cursor-pointer"),
      attribute.href(href),
    ],
    [
      html.div([attribute.class("flex items-center gap-2")], [
        icon,
        html.h3([], [html.text(title)]),
        phosphor.arrow_square_out_fill([attribute.class("w-6 h-6 ml-auto")]),
      ]),
      html.p([], [html.text(description)]),
    ],
  )
}
