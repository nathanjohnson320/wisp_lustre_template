import app/router
import app/web.{Context}
import dot_env
import dot_env/env
import gleam/erlang/process
import gleam/string
import mist
import sqlight
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  dot_env.new()
  |> dot_env.load()

  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")
  let assert Ok(db_url) = env.get_string("DATABASE_URL")
  let port = case env.get_int("PORT") {
    Ok(port) -> port
    Error(_) -> 9999
  }

  use repo <- sqlight.with_connection(string.crop(from: db_url, before: "db/"))

  let ctx = Context(static_directory: static_directory(), repo: repo)

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start

  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("server")
  priv_directory <> "/static"
}
