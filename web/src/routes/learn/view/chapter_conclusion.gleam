import lustre/attribute.{type Attribute}
import lustre/element/html
import routes/learn/lib/chapter
import routes/learn/message.{type Message}
import routes/learn/model.{type Model}

pub fn view(_model: Model, attrs: List(Attribute(Message))) {
  html.section(attrs, [
    html.h2([], [html.text(chapter.get_title(chapter.Conclusion))]),
    html.text(
      "That's it! In total, March is a very minimal and simple game that offers
      a good amount of strategic depth. Be sure to check out the cheatsheet if
      you forget anything!",
    ),
  ])
}
