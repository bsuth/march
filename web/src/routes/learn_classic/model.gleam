import main/app.{type App}

pub type Model {
  Model(app: App, chapter_index: Int, show_table_of_contents: Bool)
}
