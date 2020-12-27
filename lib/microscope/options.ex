defmodule Microscope.Options do
  @moduledoc false

  @spec parse(keyword()) :: map() | no_return()
  def parse(keyword) do
    map = Map.merge(default_options(), Map.new(keyword))

    map
    |> Enum.map(fn {k, v} -> {k, validate_field(k, v)} end)
    |> Enum.filter(&(elem(&1, 1) !== :ok))
    |> case do
      [] ->
        map

      errors ->
        message =
          errors
          |> Enum.map(fn {k, {:invalid, s}} ->
            "    - the option '#{k}' violates the constraint '#{s}'\n"
          end)
          |> IO.iodata_to_binary()

        raise ArgumentError, "failed to parse options:\n" <> message
    end
  end

  @spec default_options() :: map()
  def default_options do
    %{
      port: 8080,
      base: "/",
      callbacks: [],
      index: false,
      gen_server_options: [],
      extra_routes: []
    }
  end

  rules =
    quote do
      [
        webroot: [{:is_binary, []}, {{File, :dir?}, []}],
        port: [{:is_integer, []}, {:>, [0]}, {:<, [0x10000]}],
        base: [{:is_binary, []}],
        callbacks: [{:is_list, []}, {{Enum, :all?}, [&is_atom/1]}],
        index: [{:is_boolean, []}],
        gen_server_options: [{{Keyword, :keyword?}, []}],
        extra_routes: [{:is_list, []}]
      ]
    end

  @spec validate_field(atom(), term()) :: :ok | {:invalid, binary()}

  Enum.each(rules, fn {key, exprs} ->
    [x | xs] =
      Enum.map(exprs, fn
        {{mod, fun}, args} ->
          quote do
            unquote(mod).unquote(fun)(var!(value), unquote_splicing(args))
          end

        {fun, args} ->
          quote(do: unquote(fun)(var!(value), unquote_splicing(args)))
      end)

    check_expr = Enum.reduce(xs, x, &quote(do: unquote(&2) and unquote(&1)))

    [y | ys] =
      Enum.map(exprs, fn
        {{mod, fun}, args} ->
          quote do
            unquote(mod).unquote(fun)(value, unquote_splicing(args))
          end

        {fun, args} ->
          quote(do: unquote(fun)(value, unquote_splicing(args)))
      end)

    check_str =
      ys
      |> Enum.reduce(y, &quote(do: unquote(&2) and unquote(&1)))
      |> Macro.to_string()

    defp validate_field(unquote(key), value) do
      if unquote(check_expr) do
        :ok
      else
        {:invalid, unquote(check_str)}
      end
    end
  end)
end
