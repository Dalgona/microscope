defmodule Microscope.Callback do
  @moduledoc """
  A behaviour module for implementing callback modules for Microscope static
  web server.
  """

  @doc """
  Called when the server received a request, and before the server sends
  a response.
  """
  @callback on_request() :: :ok

  @doc "Called when the server replied with HTTP 200 (OK)."
  @callback on_200(from :: String.t(), method :: String.t(), path :: String.t()) :: :ok

  @doc "Called when the server replied with HTTP 404 (Not Found)."
  @callback on_404(from :: String.t(), method :: String.t(), path :: String.t()) :: :ok
end
