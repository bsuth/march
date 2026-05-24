pub type Msg {
  PrevChapter
  NextChapter
  UserClickedTableOfContents
  UserClickedTableOfContentsChapter(new_chapter_index: Int)
}

pub type Model {
  Model(chapter_index: Int, num_chapters: Int, show_table_of_contents: Bool)
}
