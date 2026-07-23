import lustre/attribute.{type Attribute}
import lustre/element/html
import routes/learn/lib/chapter
import routes/learn/message.{type Message}
import routes/learn/model.{type Model}

pub fn view(_model: Model, attrs: List(Attribute(Message))) {
  html.section(attrs, [
    html.h2([], [html.text(chapter.get_title(chapter.NotFound))]),
    html.text("You found an impossible chapter! But how?..."),
  ])
}
