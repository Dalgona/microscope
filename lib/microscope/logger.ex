defmodule Microscope.Logger do
  @moduledoc "A callback module that logs HTTP requests to the stdout."

  @behaviour Microscope.Callback

  @spec on_request() :: :ok
  def on_request, do: :ok

  @spec on_200(String.t(), String.t(), String.t()) :: :ok
  def on_200(from, method, path), do: log(200, from, method, path)

  @spec on_404(String.t(), String.t(), String.t()) :: :ok
  def on_404(from, method, path), do: log(404, from, method, path)

  @spec log(non_neg_integer(), String.t(), String.t(), String.t()) :: :ok
  defp log(status, from, method, path) do
    [
      [color_from_status(status), "[#{status}]", :reset],
      [" #{from} #{method} ", :bright, path]
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  @spec color_from_status(non_neg_integer()) :: IO.ANSI.ansicode()
  defp color_from_status(status)
  defp color_from_status(status) when status in 200..299, do: :green
  defp color_from_status(status) when status in 400..499, do: :red
  defp color_from_status(_status), do: :reset
end
