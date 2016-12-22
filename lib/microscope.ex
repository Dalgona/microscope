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

  @default_base "/"
  @default_port 8080

  @type options :: [port: pos_integer,
                    base: String.t,
                    callbacks: [module],
                    index: boolean]

  # TODO: update docs according to the new spec
  @doc """
  Starts Microscope simple static web server.

  The server will start listening on port specified by `port` argument. The
  server expects request URLs starting with `base`, so when a user requests
  `<base>/file`, the server will respond with the contents of `<src>/file` on
  disk, any other request URLs will result in 404.

  `cb_mods` argument expects a list of modules, each module implementing
  `Microscope.Callback` behaviour. For example, if you want a line of access
  log printed on every requests, use the built-in `Microscope.Logger` module.
  """
  @spec start_link(String.t, options) :: {:ok, pid}
  def start_link(src, options \\ []) do
    port    = Keyword.get options, :port, @default_port
    base    = Keyword.get options, :base, @default_base
    cb_mods = Keyword.get options, :callbacks, []
    index   = Keyword.get options, :index, false

    if port <= 0, do: raise ArgumentError, "port must be a positive integer"

    handler_opts = %{src: src, base: base, cb_mods: cb_mods, index: index}
    routes = [{"/[...]", Microscope.Handler, handler_opts}]
    dispatch = :cowboy_router.compile [{:_, routes}]
    t_opts = [port: port]
    p_opts = [compress: true, env: [dispatch: dispatch]]

    {:ok, pid} = :cowboy.start_http "static_#{port}", 100, t_opts, p_opts
    IO.puts "[ * ] Server started listening on port #{port}."

    {:ok, pid}
  end
end
