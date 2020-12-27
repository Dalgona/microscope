defmodule Microscope.Handler do
  @moduledoc false

  @behaviour :cowboy_handler

  alias Microscope.IndexBuilder

  @type req :: :cowboy_req.req()
  @type options :: %{src: binary(), base: binary(), cb_mods: [module], index: boolean}

  @spec init(req(), term()) :: {:ok, req(), term()}
  def init(req, state) do
    Enum.each(state.cb_mods, & &1.on_request())

    resp = handle(req, state)

    {:ok, resp, state}
  end

  @spec terminate(term(), req(), term()) :: :ok
  def terminate(_reason, _req, _state), do: :ok

  @spec handle(req(), term()) :: req()
  defp handle(req, state) do
    path = URI.decode(req.path)

    if String.starts_with?(path, state.base) do
      src = Path.join(state.src, String.replace_prefix(path, state.base, ""))

      serve(req, src, state)
    else
      respond_404(req, state)
    end
  end

  @spec serve(req(), binary(), options()) :: req()
  defp serve(req, path, state) do
    cond do
      !File.exists?(path) -> respond_404(req, state)
      File.dir?(path) -> serve_dir(req, path, state)
      :otherwise -> serve_file(req, path, state)
    end
  end

  @spec serve_dir(req(), binary(), options()) :: req()
  defp serve_dir(req, path, state) do
    path = (String.ends_with?(path, "/") && path) || "#{path}/"

    cond do
      File.exists?("#{path}index.html") ->
        serve_file(req, "#{path}index.html", state)

      File.exists?("#{path}index.htm") ->
        serve_file(req, "#{path}index.htm", state)

      state.index ->
        serve_index(req, path, state)

      :otherwise ->
        respond_404(req, state)
    end
  end

  @spec serve_index(req(), binary(), options()) :: req()
  defp serve_index(req, path, %{cb_mods: cb}) do
    url = URI.decode(req.path)
    page = IndexBuilder.build(url, path)
    headers = %{"content-type" => "text/html"}

    Enum.each(cb, &apply(&1, :on_200, get_callback_args(req)))

    :cowboy_req.reply(200, headers, page, req)
  end

  @spec serve_file(req(), binary(), options()) :: req()
  defp serve_file(req, path, %{cb_mods: cb}) do
    headers = %{"content-type" => MIME.from_path(path)}
    size = File.stat!(path).size
    resp = :cowboy_req.set_resp_body({:sendfile, 0, size, path}, req)
    resp = :cowboy_req.reply(200, headers, resp)

    Enum.each(cb, &apply(&1, :on_200, get_callback_args(req)))

    resp
  end

  @spec respond_404(req(), options()) :: req()
  defp respond_404(req, %{cb_mods: cb}) do
    headers = %{"content-type" => "text/plain"}

    Enum.each(cb, &apply(&1, :on_404, get_callback_args(req)))

    :cowboy_req.reply(404, headers, "404 Not Found", req)
  end

  @spec get_callback_args(req()) :: [binary()]
  defp get_callback_args(req) do
    ip_str = req.peer |> elem(0) |> Tuple.to_list() |> Enum.join(".")

    [ip_str, req.method, req.path]
  end
end
