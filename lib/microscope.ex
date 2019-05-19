defmodule Microscope do
  @moduledoc """
  **Microscope** is a simple static web server built using `cowboy`.

  It's original purpose was to provide an easy way to test your static
  websites, but it's also useful as a temporary server for file sharing over
  HTTP.

  ## Getting started

  Use `Microscope.start_link/2` to start the web server.

  ```
  # Example:
  {:ok, pid} =
    Microscope.start_link("/home/user/www", [base: "/base", port: 8080])
  ```

  Then the HTTP server will start listening on port 8080, and when the user
  requests `/base/path/to/file`, the server will respond with the contents of
  `/home/user/www/path/to/file` on your system.
  """

  alias Microscope.Options

  @typedoc "A keyword list containing options for Microscope"
  @type options :: [
          port: non_neg_integer,
          base: String.t(),
          callbacks: [module],
          index: boolean,
          extra_routes: [route_path()]
        ]

  @type route_path ::
          {:_ | iodata(), module(), any()}
          | {:_ | iodata(), :cowboy.fields(), module(), any()}

  @doc """
  Starts Microscope simple static web server.

  By default, the server will start listening on port 8080, and serve files
  located under the `webroot` directory. This behavior can be customized by
  using the options below.

  ## Options

  The second argument of this function expects a keyword list containing zero
  or more options listed below:

  * `port`: A port the web server listens on. The default value is `8080`.
  * `base`: A string that represents the base URL. Any URL with the form of
      `<base>/path/to/file` will be mapped to `<webroot>/path/to/file`; any
      other requests will result in 404 error. The default value is `"/"`.
  * `index`: *See below.*
  * `callbacks`: *See below.*

  ## The "index" Option

  When a user requests a directory, Microscope looks for either `index.html`
  or `index.htm` under that directory, and serves the file if found. If neither
  of them exists, how the server responds is determined by this option.

  * If `index` is set to `true`, Microscope will generate an HTML page
      containing a list of subdirectories and files and respond with 200 OK.
  * If `index` is set to `false`, the user will receive a 404 error.

  The default value for this option is `false`.

  ## The "callbacks" Option

  The `callbacks` option expects a list of modules, each module implementing
  `Microscope.Callback` behaviour. For example, if you want a line of access
  log printed on every requests, use the built-in `Microscope.Logger` module.
  The default value is an empty list.

  ## Return Value

  This function returns `{:ok, pid}` on success, where `pid` is a PID of
  process which can be later be stopped using `Microscope.stop/1,2` function.

  If this function fails for some reason, one of the followings will happen:

  - If the calling process does not trap exits, the process will exit with
    `reason`, where `reason` is any Elixir term describing the error
    information.
  - Otherwise, this function will return `{:error, reason}` and the calling
    process will receive `{:EXIT, pid, reason}` message.
  """
  @spec start_link(String.t(), options) :: GenServer.on_start()
  def start_link(webroot, options \\ []) do
    parsed_opts = Options.parse([{:webroot, webroot} | options])

    Microscope.GenServer.start_link(parsed_opts)
  end

  @doc "Stops the server specified by `pid`."
  @spec stop(pid(), timeout()) :: :ok
  def stop(pid, timeout \\ :infinity) do
    GenServer.stop(pid, :normal, timeout)
  end
end
