defmodule Microscope.IndexBuilder do
  @moduledoc false

  alias Microscope.IndexBuilder.Payload

  # type, name, mtime, bytes
  @type entry :: {atom, String.t(), String.t(), non_neg_integer}

  @spec build(String.t(), String.t()) :: String.t()
  def build(url, localpath) do
    url = (String.ends_with?(url, "/") && url) || url <> "/"
    entries = make_entries(localpath)

    dir_entries =
      entries
      |> Enum.filter(fn {type, _, _, _} -> type == :directory end)
      |> Enum.sort(&compare_entries/2)

    reg_entries =
      entries
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(dir_entries))
      |> Enum.sort(&compare_entries/2)

    Payload.page_template(url, dir_entries ++ reg_entries)
  end

  @spec make_entries(String.t()) :: [entry()]
  defp make_entries(localpath) do
    localpath
    |> File.ls!()
    |> Stream.filter(&(not String.starts_with?(&1, ".")))
    |> Stream.map(&{&1, File.stat("#{localpath}/#{&1}")})
    |> Stream.filter(fn {_, {result, _}} -> result == :ok end)
    |> Stream.map(fn {fname, {_, stat}} ->
      %File.Stat{type: type, mtime: mtime, size: size} = stat
      mtime_str = erl_to_string(mtime)
      {type, fname, mtime_str, size}
    end)
    |> Enum.to_list()
  end

  @spec erl_to_string(:calendar.datetime()) :: String.t()
  defp erl_to_string(datetime) do
    datetime
    |> NaiveDateTime.from_erl!()
    |> NaiveDateTime.to_string()
  end

  @spec compare_entries(entry(), entry()) :: boolean()
  defp compare_entries(lhs, rhs) do
    {_, lname, _, _} = lhs
    {_, rname, _, _} = rhs

    lname <= rname
  end
end
