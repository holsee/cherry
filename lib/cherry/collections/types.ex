defmodule Cherry.Collections.Types do
  @moduledoc """
  Shared NimbleOptions custom validators for collection schemas.

  YAML frontmatter arrives with string keys and loosely-typed values;
  these validators normalise into the typed shapes the rest of the
  pipeline relies on, with error messages that read well after the
  schema prefixes the source file and field.
  """

  @doc "Accepts a `Date` or an ISO 8601 string."
  @spec validate_date(term()) :: {:ok, Date.t()} | {:error, String.t()}
  def validate_date(%Date{} = date), do: {:ok, date}

  def validate_date(value) when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, "expected an ISO 8601 date, got: #{inspect(value)}"}
    end
  end

  def validate_date(value), do: {:error, "expected an ISO 8601 date, got: #{inspect(value)}"}

  alias Cherry.Portfolio.{CV, Link}

  @doc """
  Validates a `cv:` curation block (DESIGN.md §4): `include`, `weight`,
  `highlights`. Returns a `Cherry.Portfolio.CV` struct with defaults.
  """
  @spec validate_cv(term()) :: {:ok, CV.t()} | {:error, String.t()}
  def validate_cv(value) when is_map(value) do
    Enum.reduce_while(value, {:ok, %CV{}}, fn
      {"include", flag}, {:ok, %CV{} = acc} when is_boolean(flag) ->
        {:cont, {:ok, %CV{acc | include: flag}}}

      {"weight", weight}, {:ok, %CV{} = acc} when is_integer(weight) ->
        {:cont, {:ok, %CV{acc | weight: weight}}}

      {"highlights", highlights}, {:ok, %CV{} = acc} ->
        if is_list(highlights) and Enum.all?(highlights, &is_binary/1) do
          {:cont, {:ok, %CV{acc | highlights: highlights}}}
        else
          {:halt, {:error, "cv.highlights must be a list of strings"}}
        end

      {key, _value}, {:ok, _acc} when key in ["include", "weight"] ->
        {:halt, {:error, "cv.#{key} has the wrong type"}}

      {key, _value}, {:ok, _acc} ->
        {:halt, {:error, "unknown cv key #{inspect(key)} (include, weight, highlights)"}}
    end)
  end

  def validate_cv(value), do: {:error, "expected a cv map, got: #{inspect(value)}"}

  @doc """
  Validates a `links:` list: each entry a map with `label` and `url`.
  Returns `Cherry.Portfolio.Link` structs in the given order.
  """
  @spec validate_links(term()) :: {:ok, [Link.t()]} | {:error, String.t()}
  def validate_links(value) when is_list(value) do
    value
    |> Enum.reduce_while({:ok, []}, fn
      %{"label" => label, "url" => url}, {:ok, acc} when is_binary(label) and is_binary(url) ->
        {:cont, {:ok, [%Link{label: label, url: url} | acc]}}

      other, {:ok, _acc} ->
        {:halt, {:error, "each link needs label and url, got: #{inspect(other)}"}}
    end)
    |> case do
      {:ok, links} -> {:ok, Enum.reverse(links)}
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_links(value), do: {:error, "expected a list of links, got: #{inspect(value)}"}
end
