import lustre/effect.{type Effect}

@external(javascript, "./dom_ffi.mjs", "rect_xy")
pub fn get_bounding_client_rect(id: String) -> #(Int, Int)

pub fn document_mouse_move(move: fn(Int, Int) -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) {
    do_document_mouse_move(fn(x, y) { dispatch(move(x, y)) })
  })
}

@external(javascript, "./dom_ffi.mjs", "document_mouse_move")
pub fn do_document_mouse_move(_cb: fn(Int, Int) -> Nil) -> Nil {
  Nil
}

pub fn document_mouse_up(msg: msg) -> Effect(msg) {
  effect.from(fn(dispatch) { do_document_mouse_up(fn() { dispatch(msg) }) })
}

@external(javascript, "./dom_ffi.mjs", "document_mouse_up")
pub fn do_document_mouse_up(_cb: fn() -> Nil) -> Nil {
  Nil
}
