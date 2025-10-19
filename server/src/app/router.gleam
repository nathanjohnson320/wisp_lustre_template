import app/routes/items_routes.{items_middleware}
import app/web.{type Context}
import gleam/http
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)
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
      case req.method {
        http.Patch -> items_routes.patch_item(req, ctx, id)
        http.Delete -> items_routes.delete_item(req, ctx, id)
        _ -> wisp.method_not_allowed([http.Get, http.Patch, http.Delete])
      }
    }

    // All the empty responses
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-content"] -> wisp.unprocessable_content()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.content_too_large()
    ["bad-request"] -> wisp.bad_request("Bad request")
    _ -> wisp.not_found()
  }
}
