defmodule Microscope.Handler do
  @moduledoc false

  alias Microscope.IndexBuilder

  @type req :: :cowboy_req.req
  @type options :: %{src: String.t,
                     base: String.t,
                     cb_mods: [module],
                     index: boolean}

  @content_plain {"content-type", "text-plain"}

  def init({:tcp, :http}, req, opts) do
    for mod <- opts.cb_mods, do: mod.on_request()
    base = String.replace_suffix opts.base, "/", ""
    opts = %{opts | base: base}
    {:ok, req, opts}
  end

  def handle(req, opts) do
    path = URI.decode r(req, :path)
    {:ok, resp} =
      if String.starts_with? path, opts.base do
        src = opts.src <> String.replace_prefix path, opts.base, ""
        serve req, src, opts
      else
        respond_404 req, opts
      end
    {:ok, resp, nil}
  end

  def terminate(_reason, _req, _state), do: :ok

  @spec serve(req, String.t, options) :: {:ok, req}

  defp serve(req, path, opts) do
    cond do
      !(File.exists? path) -> respond_404 req, opts
      File.dir? path       -> serve_dir req, path, opts
      :otherwise           -> serve_file req, path, opts
    end
  end

  @spec serve_dir(req, String.t, options) :: {:ok, req}

  defp serve_dir(req, path, opts) do
    path = String.ends_with?(path, "/") && path || "#{path}/"
    cond do
      File.exists? "#{path}index.html" ->
        serve_file req, "#{path}index.html", opts
      File.exists? "#{path}index.htm" ->
        serve_file req, "#{path}index.htm", opts
      opts.index ->
        serve_index req, path, opts
      :otherwise ->
        respond_404 req, opts
    end
  end

  @spec serve_index(req, String.t, options) :: {:ok, req}

  defp serve_index(req, path, %{cb_mods: cb}) do
    url = URI.decode r(req, :path)
    page = IndexBuilder.build url, path
    for mod <- cb, do: apply mod, :on_200, get_callback_args(req)
    :cowboy_req.reply 200, [{"content-type", "text/html"}], page, req
  end

  @spec serve_file(req, String.t, options) :: {:ok, req}

  defp serve_file(req, path, %{cb_mods: cb}) do
    c_type = {"content-type", MIME.from_path(path)}
    size = (File.stat! path).size
    {:ok, resp} =
      if size < 32_768 do
        # Files smaller than 32768 bytes will be read into the memory,
        # and then compressed.
        content = File.read! path
        :cowboy_req.reply 200, [c_type], content, req
      else
        # Files larger than or equal to 32768 bytes will be directly
        # send to the client using sendfile.
        fun = fn sock, trans -> trans.sendfile sock, path end
        resp = :cowboy_req.set_resp_body_fun size, fun, req
        :cowboy_req.reply 200, [c_type], resp
      end
    for mod <- cb, do: apply mod, :on_200, get_callback_args(req)
    {:ok, resp}
  end

  @spec respond_404(req, options) :: {:ok, req}

  defp respond_404(req, %{cb_mods: cb}) do
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
