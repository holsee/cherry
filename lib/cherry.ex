defmodule Cherry do
  @moduledoc """
  A static site generator for hackers — a modern take on Octopress.

  Cherry builds fast static sites with a blog and a data-driven portfolio,
  driven by mix tasks (or the standalone `cherry` binary). See the
  [README](readme.html) for the tour; the design lives in the
  [GitHub repo](https://github.com/holsee/cherry).
  """

  @doc """
  The Cherry version string, as compiled into the application spec.

  ## Examples

      iex> Cherry.version() =~ ~r/^\\d+\\.\\d+\\.\\d+/
      true

  """
  @spec version() :: String.t()
  def version do
    :cherry |> Application.spec(:vsn) |> to_string()
  end
end
