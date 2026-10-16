Each file takes the form `http_${path}.gleam` and holds both the HTTP Request
and Response types, as well as their respective JSON encoders / decoders.

Note that `path` should be the full API path, with directories separate via
underscores. This keeps the directory shallow and (more importantly) removes
ambiguity when importing a nested endpoint, in particular when multiple
endpoints have the same final directory (ex. `/a/b` vs `/z/b`).
