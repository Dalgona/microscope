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

  @doc """
  Starts Microscope simple static web server.
  """
  @spec start_link(String.t, String.t, pos_integer) :: {:ok, pid}
  def start_link(src, base, port) when is_integer(port) do
    if port <= 0, do: raise ArgumentError, "port must be a positive integer"

    routes = [
      {"/[...]", Microscope.Handler, [src: src, base: base]}
    ]
    dispatch = :cowboy_router.compile [{:_, routes}]
    opts = [port: port]
    env = [dispatch: dispatch]

    {:ok, pid} = :cowboy.start_http "static_#{src}", 100, opts, env: env
    {:ok, pid}
  end
end
