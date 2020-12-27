defmodule Microscope.GenServer do
  @moduledoc false

  use GenServer

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  @spec init(term()) :: {:ok, map()} | {:stop, term()}
  def init(args) do
    false = Process.flag(:trap_exit, true)
    %{port: port, extra_routes: extra_routes} = args

    handler_state = %{
      src: args.webroot,
      base: args.base,
      cb_mods: args.callbacks,
      index: args.index
    }

    routes = [
      _: extra_routes ++ [{"/[...]", Microscope.Handler, handler_state}]
    ]

    uniq = Base.url_encode64(:crypto.strong_rand_bytes(6))
    name = "microscope_#{port}_#{uniq}"
    trans_opts = [port: port]
    proto_opts = %{env: %{dispatch: :cowboy_router.compile(routes)}}

    case :cowboy.start_clear(name, trans_opts, proto_opts) do
      {:ok, pid} ->
        IO.puts("[ * ] The HTTP server is listening on port #{port}.")
        {:ok, %{pid: pid, name: name, handler_state: handler_state}}

      {:error, error} ->
        {:stop, error}
    end
  end

  @impl GenServer
  def terminate(_reason, %{name: name}) do
    :cowboy.stop_listener(name)
  end
end
