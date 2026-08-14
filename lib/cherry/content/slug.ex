defmodule Cherry.Content.Slug do
  @moduledoc """
  Turns titles into URL slugs the same way everywhere: lowercase ASCII-ish,
  hyphen-separated, nothing else.
  """

  @doc """
  Slugifies a title.

  ## Examples

      iex> Cherry.Content.Slug.slugify("Hello, World! It's Cherry 2.0")
      "hello-world-its-cherry-2-0"

  """
  @spec slugify(String.t()) :: String.t()
  def slugify(title) do
    title
    |> String.downcase()
    |> String.replace("'", "")
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
