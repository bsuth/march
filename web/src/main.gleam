import blocks
import components
import lustre
import main/init.{init}
import main/update.{update}
import main/view.{view}

pub fn main() {
  let assert Ok(_) = components.register()
  let assert Ok(_) = blocks.register()

  let assert Ok(_) =
    lustre.application(init, update, view) |> lustre.start("#app", Nil)
}
