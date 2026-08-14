defmodule Cherry.Content.Frontmatter do
  @moduledoc """
  Splits and parses YAML frontmatter fenced by `---` lines.

  YAML because it is what the whole SSG ecosystem writes — humans and agents
  both already know it. Keys stay strings here; they are matched against a
  collection's schema keys during validation, so no unknown atoms are ever
  created from user content.
  """

  @fence ~r/\A---\s*\r?\n(.*?)\r?\n---\s*\r?\n/s

  @doc """
  Splits a file into `{frontmatter_map, body}`.

  Returns `{:ok, nil, content}` when the file has no frontmatter fence —
  callers decide whether bare files are allowed in their collection.
  """
  @spec parse(String.t()) :: {:ok, map() | nil, String.t()} | {:error, String.t()}
  def parse(content) do
    case Regex.run(@fence, content, return: :index) do
      [{0, fence_end}, {yaml_start, yaml_length}] ->
        yaml = binary_part(content, yaml_start, yaml_length)
        body = binary_part(content, fence_end, byte_size(content) - fence_end)
        decode(yaml, body)

      nil ->
        {:ok, nil, content}
    end
  end

  defp decode(yaml, body) do
    case YamlElixir.read_from_string(yaml) do
      {:ok, map} when is_map(map) -> {:ok, map, body}
      {:ok, _other} -> {:error, "frontmatter must be a YAML mapping"}
      {:error, error} -> {:error, "invalid YAML frontmatter: #{Exception.message(error)}"}
    end
  end
end
