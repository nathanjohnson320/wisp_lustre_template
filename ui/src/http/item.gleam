import api
import config.{type Config}
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/json
import gleam/result
import lustre/effect.{type Effect}
import lustre_http.{type HttpError}
import models/item.{type Item, item_decoder, item_encoder}

pub fn list_items(
  config: Config,
  msg: fn(Result(List(Item), HttpError)) -> t,
) -> Effect(t) {
  config
  |> api.url("items")
  |> lustre_http.get(lustre_http.expect_json(decode.list(item_decoder()), msg))
}

pub fn create_item(
  config: Config,
  item: Item,
  msg: fn(Result(Item, HttpError)) -> t,
) -> Effect(t) {
  let body = item_encoder(item)

  config
  |> api.url("items")
  |> lustre_http.post(body, lustre_http.expect_json(item_decoder(), msg))
}

pub fn delete_item(
  config: Config,
  item_id: String,
  msg: fn(Result(Item, HttpError)) -> t,
) -> Effect(t) {
  let url = api.url(config, "items" <> "/" <> item_id)
  let req =
    url
    |> request.to()
    |> result.unwrap(request.new())

  req
  |> request.set_method(http.Delete)
  |> lustre_http.send(lustre_http.expect_json(item_decoder(), msg))
}

pub fn update_item(
  config: Config,
  item: Item,
  msg: fn(Result(Item, HttpError)) -> t,
) -> Effect(t) {
  let url = api.url(config, "items" <> "/" <> item.id)
  let req =
    url
    |> request.to()
    |> result.unwrap(request.new())

  req
  |> request.set_method(http.Patch)
  |> request.set_header("Content-Type", "application/json")
  |> request.set_body(json.to_string(item_encoder(item)))
  |> lustre_http.send(lustre_http.expect_json(item_decoder(), msg))
}
