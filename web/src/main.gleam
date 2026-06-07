import blocks
import components
import lustre
import main/init.{init}
import main/update.{update}
import main/view.{view}
import routes

pub fn main() {
  let assert Ok(_) = components.register()
  let assert Ok(_) = blocks.register()
  let assert Ok(_) = routes.register()

  let assert Ok(_) =
    lustre.application(init, update, view) |> lustre.start("#app", Nil)
}
