defmodule Cherry do
  @moduledoc """
  A static site generator for hackers — a modern take on Octopress.

  Cherry builds fast static sites with a blog and a data-driven portfolio,
  driven by mix tasks (or the standalone `cherry` binary). See the
  [README](readme.html) for the tour; the design lives in the
  [GitHub repo](https://github.com/holsee/cherry).
  """

  alias Cherry.Build
  alias Cherry.Pipeline
  alias Cherry.Site

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

  @doc """
  Builds a site: loads `cherry.exs` from `:source` and runs the pipeline.

  Options: `:source` (site root, required), `:output` (defaults to
  `source/_site`), plus the selection options of `Cherry.Build.Options`
  (`:drafts`, `:future`, `:today`).
  """
  @spec build(keyword()) :: {:ok, Build.t()} | {:error, String.t()}
  def build(opts) do
    source = Keyword.fetch!(opts, :source)
    output = Keyword.get(opts, :output, Path.join(source, "_site"))
    options = Build.Options.new(opts)

    with {:ok, site} <- Site.load(source, output: output) do
      Pipeline.run(Build.new(site, options), Pipeline.default_stages())
    end
  end

  @doc """
  Verifies a site: builds it in memory (nothing is written) and runs
  every `Cherry.Check` rule against the result.
  """
  @spec check(keyword()) :: {:ok, Build.t(), [Cherry.Check.Diagnostic.t()]} | {:error, String.t()}
  def check(opts) do
    source = Keyword.fetch!(opts, :source)
    options = Build.Options.new(opts)
    stages = Pipeline.default_stages() -- [Pipeline.Stages.Emit, Pipeline.Stages.Post]

    with {:ok, site} <- Site.load(source),
         {:ok, build} <- Pipeline.run(Build.new(site, options), stages) do
      {:ok, build, Cherry.Check.run(build)}
    end
  end
end
