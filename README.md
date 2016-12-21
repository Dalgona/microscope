# Microscope

[Microscope on hex.pm](https://hex.pm/packages/microscope)

Microscope is a simple static web server written in [Elixir](http://elixir-lang.org)
using [cowboy](https://hex.pm/packages/cowboy).

Originally it was a part of [Serum](http://dalgona.hontou.moe/Serum) development
server, but I decided to separate into the other project for better
maintainability.

## Installation

Add `microscope` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:microscope, "~> 0.3"}]
end
```

## Using Microscope

### Using in Your Module

Start Microscope using `Microscope.start_link/3`.

```elixir
{:ok, pid} = Microscope.start_link("/home/user/www", "/base/url", 8080)
```

The server will start listening on port `8080`. Open a web browser and navigate
to `http://<your-host>:8080/base/url/path/to/file`, and the contents of
`/home/user/www/path/to/file` will be displayed.

You may request either a file or a directory. If you request a file, Microscope
will try to serve the requested file, or respond with HTTP 404 if the file does
not exist. And if you request a directory, Microscope will look for `index.html`
or `index.htm` inside the requested directory and serve one if found.

### As a Command-line Application

Microscope also comes with a Mix task which provides a way to launch a static
web server right away.

```
% mix microscope <src> [(-b|--base) <base-url>] [(-p|--port) <port>]
```

For example, suppose you have generated docs for your project with ExDoc, and
you want to see them before publishing to Hex. Then, simply type the command
below:

```
% mix microscope doc
```

Now open a web browser and navigate to `http://<your-host>:8080/` to see the
docs. Easy and real quick! :rocket:

## License

MIT. Please read `LICENSE` file for the full text.
