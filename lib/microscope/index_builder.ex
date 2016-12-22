defmodule Microscope.IndexBuilder do
  alias Microscope.IndexBuilder.Payload

  # type, name, mtime, bytes
  @type entry :: {atom, String.t, String.t, non_neg_integer}
  @typep erl_datetime :: :calendar.datetime

  @spec build(String.t, String.t) :: String.t
  def build(url, localpath) do
    url = String.ends_with?(url, "/") && url || url <> "/"
    entries = make_entries localpath
    dir_entries =
      entries
      |> Enum.filter(fn {type, _, _, _} -> type == :directory end)
      |> Enum.sort(&ent_compare/2)
    reg_entries =
      entries
      |> MapSet.new
      |> MapSet.difference(MapSet.new dir_entries)
      |> Enum.sort(&ent_compare/2)
    Payload.page_template url, dir_entries ++ reg_entries
  end

  @spec make_entries(String.t) :: [entry]
  defp make_entries(localpath) do
    localpath
    |> File.ls!
    |> Stream.filter(&(not String.starts_with? &1, "."))
    |> Stream.map(fn fname ->
      %File.Stat{type: type, mtime: mtime, size: size} =
        File.stat! "#{localpath}/#{fname}"
      mtime_str = erl_to_string mtime
      {type, fname, mtime_str, size}
    end)
    |> Enum.to_list
  end

  @spec erl_to_string(erl_datetime) :: String.t
  defp erl_to_string(datetime) do
    pad = &String.pad_leading("#{&1}", 2, "0")
    {{year, mon, day}, {hour, min, sec}} = datetime
    datestr = "#{year}-#{pad.(mon)}-#{pad.(day)} "
    timestr = "#{pad.(hour)}:#{pad.(min)}:#{pad.(sec)}"
    datestr <> timestr
  end

  @spec ent_compare(entry, entry) :: boolean
  defp ent_compare(lhs, rhs) do
    {_, lname, _, _} = lhs
    {_, rname, _, _} = rhs
    lname <= rname
  end
end
