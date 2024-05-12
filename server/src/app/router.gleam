import app/routes/items_routes.{items_middleware}
import app/web.{type Context}
import gleam/http
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _req <- web.middleware(req, ctx)
  use ctx <- items_middleware(req, ctx)

  case wisp.path_segments(req) {
    ["items"] -> {
      use <- wisp.require_method(req, http.Get)
      items_routes.list_items(req, ctx)
    }
    ["items", "create"] -> {
      use <- wisp.require_method(req, http.Post)
      items_routes.post_create_item(req, ctx)
    }

    ["items", id] -> {
      use <- wisp.require_method(req, http.Delete)
      items_routes.delete_item(req, ctx, id)
    }

    ["items", id, "completion"] -> {
      use <- wisp.require_method(req, http.Patch)
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
