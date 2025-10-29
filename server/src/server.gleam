import app/router
import app/web.{Context}
import dot_env
import dot_env/env
import gleam/erlang/process
import gleam/otp/static_supervisor as supervisor
import mist
import pog
import wisp
import wisp/wisp_mist

const app_name = "server"

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

  let pool_name = process.new_name(app_name)
  let assert Ok(db_config) = pog.url_config(pool_name, db_url)

  let db =
    db_config
    |> pog.pool_size(15)
    |> pog.supervised

  let ctx =
    Context(static_directory: static_directory(), repo: fn() -> pog.Connection {
      pog.named_connection(pool_name)
    })

  let handler = router.handle_request(_, ctx)

  let web =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.supervised()

  let assert Ok(_) =
    supervisor.new(supervisor.RestForOne)
    |> supervisor.add(db)
    |> supervisor.add(web)
    |> supervisor.start

  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory(app_name)
  priv_directory <> "/static"
}
