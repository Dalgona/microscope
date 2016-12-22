defmodule Mix.Tasks.Microscope do
  @moduledoc """
  A Mix task that provides an express way to launch a static web server.
  """

  use Mix.Task

  @opt_def      [base: :string, port: :integer, index: :boolean]
  @opt_alias    [b: :base, p: :port]
  @default_base "/"
  @default_port 8080

  @shortdoc "Launches Microscope static web server"
  @spec run([String.t]) :: any
  def run(args) do
    {parsed, argv, errors}
      = OptionParser.parse args, strict: @opt_def, aliases: @opt_alias
    cond do
      errors != []      -> usage
      length(argv) != 1 -> usage
      :otherwise        -> start_server parsed, argv
    end
  end

  @spec start_server(keyword, [String.t]) :: any
  defp start_server(opts, argv) do
    Application.ensure_all_started :cowboy

    base    = Keyword.get opts, :base, "/"
    port    = Keyword.get opts, :port, 8080
    index   = Keyword.get opts, :index, false
    [src|_] = argv

    opts = [
      port: port,
      base: base,
      callbacks: [Microscope.Logger],
      index: index
    ]
    {:ok, _pid} = Microscope.start_link src, opts
    looper
  end

  @spec looper() :: no_return
  defp looper do
    IO.gets ""
    looper
  end

  @spec usage() :: :ok
  defp usage do
    IO.puts """
    Usage: mix microscope <src> [options]
    Available Options:
    \t-b(--base) <base>  Base URL
    \t-p(--port) <port>  Port number
    \t--index            Respond with auto-generated "Index of" page when
    \t                   the requested directory contains no default page

    The default base URL is "#{@default_base}".
    The default port is #{@default_port}.
    """
  end
end
