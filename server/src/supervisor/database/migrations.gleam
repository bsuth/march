import pog

pub fn create_users_table(db: pog.Connection) {
  "CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(50) UNIQUE NOT NULL
  );"
  |> pog.query()
  |> pog.execute(db)
}
