defmodule Microscope.Handler do
  @type req :: :cowboy_req.req

  @content_plain {"Content-Type", "text-plain"}

  def init({:tcp, :http}, req, [src: src, base: base]) do
    base = String.replace_suffix base, "/", ""
    {:ok, req, [src: src, base: base]}
  end

  def handle(req, [src: src, base: base]) do
    path = r req, :path
    {:ok, resp} =
      if String.starts_with? path, base do
        serve req, src <> String.replace_prefix(path, base, "")
      else
        respond_404 req
      end
    {:ok, resp, nil}
  end

  def terminate(_reason, _req, _state), do: :ok

  @spec serve(req, String.t) :: {:ok, req}
  defp serve(req, path) do
    cond do
      !(File.exists? path) -> respond_404 req
      File.dir? path       -> serve_dir req, path
      :otherwise           -> serve_file req, path
    end
  end

  @spec serve_dir(req, String.t) :: {:ok, req}
  defp serve_dir(req, path) do
    path = String.ends_with?(path, "/") && path || path <> "/"
    cond do
      File.exists? path <> "index.html" ->
        serve_file req, path <> "index.html"
      File.exists? path <> "index.htm" ->
        serve_file req, path <> "index.htm"
      :otherwise ->
        respond_404 req
    end
  end

  @spec serve_file(req, String.t) :: {:ok, req}
  defp serve_file(req, path) do
    mime = MIME.from_path path
    content = File.read! path
    log req, 200
    :cowboy_req.reply 200, [{"Content-Type", mime}], content, req
  end

  @spec respond_404(req) :: {:ok, req}
  defp respond_404(req) do
    log req, 404
    :cowboy_req.reply 404, [@content_plain], "404 Not Found", req
  end

  @spec log(req, non_neg_integer) :: :ok
  defp log(req, code) do
    message = "#{color_from_status(code)}[#{code}]\e[0m " <> r(req, :path)
    IO.puts message
  end

  @spec color_from_status(non_neg_integer) :: String.t
  defp color_from_status(code) do
    cond do
      code < 200 -> ""        # 1xx Informational: none
      code < 300 -> "\e[32m"  # 2xx Completed: green
      code < 400 -> "\e[33m"  # 3xx Redirect: yellow
      code < 500 -> "\e[31m"  # 4xx Client Error: red
      :otherwise -> "\e[35m"  # 5xx Server Error: purple
    end
  end

  @spec r(:cowboy_req.req, atom) :: term
  defp r(req, field) do
    {x, _} = apply :cowboy_req, field, [req]
    x
  end
end
