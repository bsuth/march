import envoy
import gleam/otp/supervision
import names.{type Names}
import pog
import supervisor/database/migrations
import yuzu

pub fn supervised(names: Names) {
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(database_config) = pog.url_config(names.database, database_url)

  supervision.supervisor(fn() {
    use pog_actor <- yuzu.ok_(pog.start(database_config))

    let db = pog_actor.data
    let assert Ok(_) = migrations.create_users_table(db)

    Ok(pog_actor)
  })
}
