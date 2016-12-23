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

  @default_base "/"
  @default_port 8080

  @typedoc "A keyword list containing options for Microscope"
  @type options :: [port: non_neg_integer,
                    base: String.t,
                    callbacks: [module],
                    index: boolean]

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
  """
  @spec start_link(String.t, options) :: {:ok, pid} | {:error, atom}
  def start_link(webroot, options \\ []) do
    port    = Keyword.get options, :port, @default_port
    base    = Keyword.get options, :base, @default_base
    cb_mods = Keyword.get options, :callbacks, []
    index   = Keyword.get options, :index, false
    opts2   = [port: port, base: base, callbacks: cb_mods, index: index]
    validate_args webroot, opts2

    handler_opts = %{src: webroot, base: base, cb_mods: cb_mods, index: index}
    routes = [{"/[...]", Microscope.Handler, handler_opts}]
    dispatch = :cowboy_router.compile [{:_, routes}]
    t_opts = [port: port]
    p_opts = [compress: true, env: [dispatch: dispatch]]

    start_result = :cowboy.start_http "static_#{port}", 100, t_opts, p_opts

    case start_result do
      {:ok, pid} ->
        IO.puts "[ * ] Server started listening on port #{port}."
        {:ok, pid}
      {:error, err_info} ->
        filter_error err_info
    end
  end

  @spec filter_error(term) :: {:error, term}
  defp filter_error({{:shutdown, {_, _, {_, _, r}}}, _}), do: {:error, r}

  @spec validate_args(String.t, options) :: :ok
  defp validate_args(webroot, options) do
    do_validate_webroot webroot
    do_validate_port Keyword.get(options, :port)
    do_validate_base Keyword.get(options, :base)
    do_validate_callbacks Keyword.get(options, :callbacks)
    do_validate_index Keyword.get(options, :index)
    :ok
  end

  @spec do_validate_webroot(String.t) :: :ok
  defp do_validate_webroot(webroot) when is_binary(webroot) do
    if not File.dir?(webroot) do
      raise ArgumentError, "`#{webroot}' is not a directory"
    else
      :ok
    end
  end

  defp do_validate_webroot(x) do
    raise ArgumentError, "`webroot' expects a string, got #{inspect x}"
  end

  @spec do_validate_port(non_neg_integer) :: :ok
  defp do_validate_port(port) when is_integer(port) do
    if port < 1 or port > 0xFFFF do
      raise ArgumentError, "`port' number out of range"
    else
      :ok
    end
  end

  defp do_validate_port(x) do
    raise ArgumentError, "`port' expects an integer value, got #{inspect x}"
  end

  @spec do_validate_base(String.t) :: :ok
  defp do_validate_base(base) when is_binary(base), do: :ok

  defp do_validate_base(x),
    do: raise ArgumentError, "`base' expects a string, got #{inspect x}"

  @spec do_validate_callbacks([module]) :: :ok
  defp do_validate_callbacks([]), do: :ok

  defp do_validate_callbacks(cb_mods) do
    cb_test = cb_mods |> Enum.map(&is_atom(&1)) |> Enum.uniq
    case cb_test do
      [true] -> :ok
      _ -> raise ArgumentError,
        "`callbacks' expects a list of modules, got #{inspect cb_mods}"
    end
  end

  @spec do_validate_index(boolean) :: :ok
  defp do_validate_index(index) when is_boolean(index), do: :ok

  defp do_validate_index(x),
    do: raise ArgumentError, "`index' expects a boolean, got #{inspect x}"
end
