defmodule Microscope do
  @moduledoc """
  **Microscope** is a simple static web server built using `cowboy`. It's
  purpose is to provide an easy way to test your static websites.

  ## Getting started

  Use `Microscope.start_link/3` to start the web server.

  ```
  # Example:
  iex> {:ok, pid} = Microscope.start_link("/home/user/www", "/base", 8080)
  ```

  Then the HTTP server will start listening on port 8080, and when the user
  requests `/base/path/to/file`, the server will respond with the contents of
  `/home/user/www/path/to/file` on your system.

  Microscope can also handle directory requests. In this case, the web server
  will look for `index.html` or `index.htm` under the specified directory and
  serve the file if found.
  """

  @type callback :: (() -> any) | nil

  @doc """
  Starts Microscope simple static web server.

  The server will start listening on port specified by `port` argument. The
  server expects request URLs starting with `base`, so when a user requests
  `<base>/file`, the server will respond with the contents of `<src>/file` on
  disk, any other request URLs will result in 404.

  You can also specify a function which is executed on every HTTP request, by
  passing a function to `on_req` argument. `on_req` expects a zero-arity
  function, and the return value will be ignored. If `on_req` is `nil`, no
  function will be executed.
  """
  @spec start_link(String.t, String.t, pos_integer, callback) :: {:ok, pid}
  def start_link(src, base, port, on_req \\ nil) when is_integer(port) do
    if port <= 0, do: raise ArgumentError, "port must be a positive integer"

    routes = [
      {"/[...]", Microscope.Handler, [src: src, base: base, fun: on_req]}
    ]
    dispatch = :cowboy_router.compile [{:_, routes}]
    opts = [port: port]
    env = [dispatch: dispatch]

    {:ok, pid} = :cowboy.start_http "static_#{src}", 100, opts, env: env
    {:ok, pid}
  end
end
