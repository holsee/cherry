defmodule Cherry.StableJSON do
  @moduledoc """
  Byte-deterministic JSON for emitted output (ADR 0005): object keys
  are written in sorted order.

  The VM iterates atom-keyed maps in atom-creation order, which varies
  between runs — `JSON.encode!/1` alone cannot promise the same bytes
  for the same value. Every JSON document that lands in `_site/` goes
  through here instead.
  """

  @doc "Encodes with every object's keys sorted — same value, same bytes."
  @spec encode!(term()) :: String.t()
  def encode!(value), do: stable(value)

  defp stable(map) when is_map(map) do
    inner =
      map
      |> Enum.map(fn {key, value} -> {to_string(key), value} end)
      |> Enum.sort_by(fn {key, _value} -> key end)
      |> Enum.map_join(",", fn {key, value} -> JSON.encode!(key) <> ":" <> stable(value) end)

    "{" <> inner <> "}"
  end

  defp stable(list) when is_list(list) do
    "[" <> Enum.map_join(list, ",", &stable/1) <> "]"
  end

  defp stable(other), do: JSON.encode!(other)
end
