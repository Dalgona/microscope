defmodule Mix.Tasks.Microscope do
  @moduledoc """
  A Mix task that provides an express way to launch a static web server.
  """

  use Mix.Task

  @opt_def      [base: :string, port: :integer]
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

    base    = Keyword.get(opts, :base) || "/"
    port    = Keyword.get(opts, :port) || 8080
    [src|_] = argv

    {:ok, _pid} = Microscope.start_link src, base, port, [Microscope.Logger]
    looper
  end

  @spec looper() :: no_return
  defp looper do
    IO.gets ""
    looper
  end

  @spec usage() :: :ok
  defp usage do
    IO.puts "Usage: mix microscope <src> "
      <> "[(-b|--base) <base>] [(-p|--port) <port>]"
    IO.puts "The default base URL is \"#{@default_base}\"."
    IO.puts "The default port is #{@default_port}.\n"
  end
end
