import app/router
import app/web.{Context}
import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import sqlight
import wisp

pub fn main() {
  wisp.configure_logger()
  dot_env.load()

  let assert Ok(secret_key_base) = env.get("SECRET_KEY_BASE")

  use repo <- sqlight.with_connection(":memory:")
  let ctx = Context(static_directory: static_directory(), repo: conn)

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp.mist_handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("example")
  priv_directory <> "/static"
}
