import app/routes/items_routes.{items_middleware}
import app/web.{type Context}
import gleam/http
import gleam/int
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _req <- web.middleware(req, ctx)
  use ctx <- items_middleware(req, ctx)

  case wisp.path_segments(req) {
    ["items"] -> {
      case req.method {
        http.Get -> items_routes.list_items(req, ctx)
        http.Post -> items_routes.post_create_item(req, ctx)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }
    }

    ["items", id] -> {
      use <- wisp.require_method(req, http.Delete)
      let id = result.unwrap(int.parse(id), 0)
      items_routes.delete_item(req, ctx, id)
    }

    ["items", id, "completion"] -> {
      use <- wisp.require_method(req, http.Patch)
      let id = result.unwrap(int.parse(id), 0)
      items_routes.patch_toggle_todo(req, ctx, id)
    }

    // All the empty responses
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
