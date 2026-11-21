import main/app.{type App}
import routes/learn_classic/chapter.{type Chapter}

pub type Model {
  Model(app: App, chapter: Chapter, show_table_of_contents: Bool)
}
