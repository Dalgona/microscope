defmodule Microscope.Handler do
  @moduledoc false

  @type req :: :cowboy_req.req

  @content_plain {"content-type", "text-plain"}

  def init({:tcp, :http}, req, [src: src, base: base, cb_mods: cb_mods]) do
    for mod <- cb_mods, do: apply mod, :on_request, []

    base = String.replace_suffix base, "/", ""
    {:ok, req, [src: src, base: base, cb_mods: cb_mods]}
  end

  def handle(req, [src: src, base: base, cb_mods: cb_mods]) do
    path = r req, :path
    {:ok, resp} =
      if String.starts_with? path, base do
        serve req, src <> String.replace_prefix(path, base, ""), cb_mods
      else
        respond_404 req, cb_mods
      end
    {:ok, resp, nil}
  end

  def terminate(_reason, _req, _state), do: :ok

  @spec serve(req, String.t, [module]) :: {:ok, req}
  defp serve(req, path, cb) do
    cond do
      !(File.exists? path) -> respond_404 req, cb
      File.dir? path       -> serve_dir req, path, cb
      :otherwise           -> serve_file req, path, cb
    end
  end

  @spec serve_dir(req, String.t, [module]) :: {:ok, req}
  defp serve_dir(req, path, cb) do
    path = String.ends_with?(path, "/") && path || path <> "/"
    cond do
      File.exists? path <> "index.html" ->
        serve_file req, path <> "index.html", cb
      File.exists? path <> "index.htm" ->
        serve_file req, path <> "index.htm", cb
      :otherwise ->
        respond_404 req, cb
    end
  end

  @spec serve_file(req, String.t, [module]) :: {:ok, req}
  defp serve_file(req, path, cb) do
    mime = MIME.from_path path
    size = (File.stat! path).size
    fun = fn sock, trans -> trans.sendfile sock, path end
    for mod <- cb, do: apply mod, :on_200, get_callback_args(req)

    resp = :cowboy_req.set_resp_body_fun size, fun, req
    :cowboy_req.reply 200, [{"content-type", mime}], resp
  end

  @spec respond_404(req, [module]) :: {:ok, req}
  defp respond_404(req, cb) do
    for mod <- cb, do: apply mod, :on_404, get_callback_args(req)
    :cowboy_req.reply 404, [@content_plain], "404 Not Found", req
  end

  @spec get_callback_args(req) :: [String.t]
  defp get_callback_args(req) do
    {{i1, i2, i3, i4}, _port} = r req, :peer
    ["#{i1}.#{i2}.#{i3}.#{i4}", r(req, :method), r(req, :path)]
  end

  @spec r(:cowboy_req.req, atom) :: term
  defp r(req, field) do
    {x, _} = apply :cowboy_req, field, [req]
    x
  end
end
