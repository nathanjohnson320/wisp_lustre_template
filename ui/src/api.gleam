import config.{type Config}
import gleam/string

pub fn url(config: Config, uri: String) -> String {
  string.join([config.api_url, uri], "/")
}
