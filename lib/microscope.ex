defmodule Microscope do
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
