import lustre/effect
import main/app.{type App}
import routes/learn/model.{Model}

pub fn init(app: App) {
  #(Model(app:, chapter_index: 0, show_table_of_contents: False), effect.none())
}
