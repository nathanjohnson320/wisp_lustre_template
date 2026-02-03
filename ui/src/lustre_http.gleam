import gleam/dynamic/decode.{type Decoder}
import gleam/fetch
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response, Response}
import gleam/javascript/promise
import gleam/json.{type Json}
import gleam/result
import lustre/effect.{type Effect}

// SENDING REQUESTS ------------------------------------------------------------

/// Send a GET request to the given URL and say what kind of response you're
/// expecting. If the url is invalid, the expect handler will receive a `BadUrl`
/// error.
///
/// ### Usage
///
/// ```gleam
/// import lustre_http as http
///
/// type Msg {
///   GotIpAddress(Result(String, http.HttpError))
///   WhoAmI
/// }
///
/// fn update(model, msg) {
///   case msg {
///     GotIpAddress(Ok(ip)) -> ...
///     GotIpAddress(Error(err)) -> ...
///     WhoAmI -> #(
///       model,
///       http.get("https://api.ipify.org", http.expect_text(GotIpAddress)
///     )
///   }
/// }
/// ```
///
/// If you need tighter control over the request - e.g. to set headers - you can
/// construct the request manually using the [gleam_http](https://hexdocs.pm/gleam_http/gleam/http/request.html)
/// package and then use [`send`](#send) instead.
///
pub fn get(url: String, expect: Expect(msg)) -> Effect(msg) {
  effect.from(fn(dispatch) {
    case request.to(url) {
      Ok(req) -> do_send(req, expect, dispatch)
      Error(_) -> dispatch(expect.run(Error(BadUrl(url))))
    }
  })
}

/// Send a POST request to the given URL and say what kind of response you're
/// expecting. If the url is invalid, the expect handler will receive a `BadUrl`
/// error.
///
/// ### Usage
///
/// ```gleam
/// import lustre_http as http
/// import gleam/json.{type Json}
///
/// type Msg {
///   GotResponse(Result(Nil, http.HttpError))
///   CreatePost(body: Json)
/// }
///
/// fn update(model, msg) {
///   case msg {
///     GotResponse(Ok(_)) -> ...
///     GotResponse(Error(err)) -> ...
///     CreatePost(body) -> #(
///       model,
///       http.post(
///         "https://jsonplaceholder.typicode.com/posts",
///         body,
///         http.expect_anything(GotResponse))
///     )
///   }
/// }
/// ```
///
/// If you need tighter control over the request - e.g. to set headers - you can
/// construct the request manually using the [gleam_http](https://hexdocs.pm/gleam_http/gleam/http/request.html)
/// package and then use [`send`](#send) instead.
///
pub fn post(url: String, body: Json, expect: Expect(msg)) -> Effect(msg) {
  effect.from(fn(dispatch) {
    case request.to(url) {
      Ok(req) ->
        req
        |> request.set_method(http.Post)
        |> request.set_header("Content-Type", "application/json")
        |> request.set_body(json.to_string(body))
        |> do_send(expect, dispatch)
      Error(_) -> dispatch(expect.run(Error(BadUrl(url))))
    }
  })
}

/// Send a [gleam_http `Request`](https://hexdocs.pm/gleam_http/gleam/http/request.html#Request)
/// along with what kind of response you're expecting to receive. Once the request
/// is complete, the response will be turned into a message you can handle in
/// your `update` function.
///
/// If you just want to make a simple GET or POST request, you might find either
/// [`get`](#get) or [`post`](#post) easier to use!
///
pub fn send(req: Request(String), expect: Expect(msg)) -> Effect(msg) {
  effect.from(do_send(req, expect, _))
}

@target(javascript)
fn do_send(
  req: Request(String),
  expect: Expect(msg),
  dispatch: fn(msg) -> Nil,
) -> Nil {
  fetch.send(req)
  |> promise.try_await(fetch.read_text_body)
  |> promise.map(fn(response) {
    case response {
      Ok(res) -> expect.run(Ok(res))
      Error(_) -> expect.run(Error(NetworkError))
    }
  })
  |> promise.rescue(fn(_) { expect.run(Error(NetworkError)) })
  |> promise.tap(dispatch)

  Nil
}

@target(erlang)
fn do_send(
  req: Request(String),
  expect: Expect(msg),
  dispatch: fn(msg) -> Nil,
) -> Nil {
  // By providing an Erlang implementation of this function, even if it does
  // nothing, we can still compile Lustre apps that use lustre_http as server
  // components.
  //
  // In the future we can add support for gleam_httpc as an erlang HTTP client.
  Nil
}

// HANDLING ERRORS -------------------------------------------------------------

/// A HTTP request might fail in a few different ways: some of these are errors
/// from the server (e.g. a 404 `NotFound` error) but others are ways your request
/// can fail on the client. This type enumerates all of them.
///
pub type HttpError {
  /// Both [`get`](#get) and [`post`](#post) let you pass the request URL as a
  /// string. This error is returned if you pass in something that isn't a valid
  /// URL.
  BadUrl(String)

  /// The server returned a 500 Internal Server Error. The body of the response
  /// is included as a string.
  InternalServerError(String)

  /// When you use [`expect_json`](#expect_json) to decode an incoming response,
  /// this error is returned if the body is not valid JSON or the decoder fails.
  JsonError(json.DecodeError)

  /// If you try and make a request while the client is offline, this error is
  /// returned.
  NetworkError

  /// The server returned a 404 Not Found error.
  NotFound

  /// Any other non-200 response from the server that is not 404, 401 or 500 will
  /// be returned as this error. The status code and body of the response are
  /// included.
  OtherError(Int, String)

  /// The server returned a 401 Unauthorized error.
  Unauthorized
}

fn response_to_result(response: Response(String)) -> Result(String, HttpError) {
  case response {
    Response(status: status, headers: _, body: body)
      if 200 <= status && status <= 299
    -> Ok(body)
    Response(status: 401, headers: _, body: _) -> Error(Unauthorized)
    Response(status: 404, headers: _, body: _) -> Error(NotFound)
    Response(status: 500, headers: _, body: body) ->
      Error(InternalServerError(body))
    Response(status: code, headers: _, body: body) ->
      Error(OtherError(code, body))
  }
}

// EXPECTING RESPONSES ---------------------------------------------------------

/// An expectation of what kind of response we're expecting to receive. This is
/// how you an teach lustre_http to turn HTTP responses into messages your app
/// can handle.
///
/// For simple cases, you can use [`expect_text`](#expect_text) and
/// [`expect_json`](#expect_json). These functions handle the response for you
/// and you just need to provide a function to turn the text or JSON into a
/// message.
///
/// For more complex cases, you can use [`expect_text_response`](#expect_text_response)
/// instead. This function lets you handle the
/// [gleam_http Response](https://hexdocs.pm/gleam_http/gleam/http/response.html#Response)
/// directly and is useful if you want to handle specific HTTP status codes or
/// read the response headers.
///
pub opaque type Expect(msg) {
  ExpectTextResponse(run: fn(Result(Response(String), HttpError)) -> msg)
  // In the future we might be able to support Bytes responses here too. But for
  // now, gleam_fetch only supports text responses.
}

/// Expect any response. This is useful if you want to just fire off a request
/// and make sure it was successful. If you want to handle the response body in
/// some way, you should take a look at [`expect_text`](#expect_text) or
/// [`expect_json`](#expect_json) instead.
///
pub fn expect_anything(to_msg: fn(Result(Nil, HttpError)) -> msg) -> Expect(msg) {
  ExpectTextResponse(fn(response) {
    response
    |> result.try(response_to_result)
    |> result.replace(Nil)
    |> to_msg
  })
}

/// Expect a plain text response.
///
pub fn expect_text(to_msg: fn(Result(String, HttpError)) -> msg) -> Expect(msg) {
  ExpectTextResponse(fn(response) {
    response
    |> result.try(response_to_result)
    |> to_msg
  })
}

/// Expect a JSON response. The decoder is used to decode the JSON into a
/// well-typed Gleam value. If this fails, the `JsonError` error variant will be
/// returned.
///
/// ### Usage
///
/// ```gleam
/// import lustre_http as http
/// import gleam/dynamic/decode
///
/// type Post {
///   Post(id: Int, title: String, body: String)
/// }
///
/// type Msg {
///   GotPosts(Result(List(Post), http.HttpError))
/// }
///
/// fn get_posts() -> Effect(msg) {
///   let url = "https://jsonplaceholder.typicode.com/posts"
///   let decoder = {
///     use id <- decode.field("id", decode.int)
///     use title <- decode.field("title", decode.string)
///     use body <- decode.field("body", decode.string)
///     decode.success(Post(id, title, body))
///   }
///
///   http.get(url, http.expect_json(decode.list(decoder), GotPosts))
/// }
/// ```
///
pub fn expect_json(
  decoder: Decoder(a),
  to_msg: fn(Result(a, HttpError)) -> msg,
) -> Expect(msg) {
  ExpectTextResponse(fn(response) {
    response
    |> result.try(response_to_result)
    |> result.try(fn(body) {
      case json.parse(from: body, using: decoder) {
        Ok(json) -> Ok(json)
        Error(json_error) -> Error(JsonError(json_error))
      }
    })
    |> to_msg
  })
}

/// Expect a [gleam_http `Response`](https://hexdocs.pm/gleam_http/gleam/http/response.html#Response)
/// and handle it yourself. This is necessary if you want to handle specific
/// HTTP status codes or read the response headers.
///
pub fn expect_text_response(
  on_response: fn(Response(String)) -> Result(a, e),
  on_failure: fn(HttpError) -> e,
  to_msg: fn(Result(a, e)) -> msg,
) -> Expect(msg) {
  ExpectTextResponse(fn(response) {
    case response {
      Ok(response) -> to_msg(on_response(response))
      Error(error) -> to_msg(Error(on_failure(error)))
    }
  })
}
