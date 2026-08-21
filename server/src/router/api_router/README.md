Each file handles HTTP Methods belonging to the root path, and otherwise
forwards any non-root requests to sub-routers.

Each file takes the form `${directory}_router.gleam`. Sub-routers should be
placed in a directory of the form `${directory}_router`.

Example:

- `GET /a` -> `a_router.gleam` -> `fn post() { ... }`
- `POST /a` -> `a_router.gleam` -> `fn get() { ... }`
- `GET /a/b` -> `a_router/b_router.gleam` -> `fn get() { ... }`
- `DELETE /a/c` -> `a_router/c_router.gleam` -> `fn delete() { ... }`
