defmodule Microscope.Logger do
  @moduledoc "A callback module that logs HTTP requests to the stdout."

  @behaviour Microscope.Callback

  @spec on_request() :: no_return
  def on_request(), do: nil

  @spec on_200(String.t, String.t, String.t) :: no_return
  def on_200(from, method, path), do: log 200, from, method, path

  @spec on_404(String.t, String.t, String.t) :: no_return
  def on_404(from, method, path), do: log 404, from, method, path

  @spec log(non_neg_integer, String.t, String.t, String.t) :: :ok
  defp log(status, from, method, path) do
    message =
      "#{color_from_status(status)}[#{status}]\e[0m "
      <> "#{from} #{method} "
      <> "\e[1m#{path}\e[0m"
    IO.puts message
  end

  @spec color_from_status(non_neg_integer) :: String.t
  defp color_from_status(200), do: "\e[32m"
  defp color_from_status(404), do: "\e[31m"
end
