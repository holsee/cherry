defmodule Cherry.Commands.Build do
  @doc_text """
  Builds the site into `_site/`.

  ## Usage

      mix cherry.build [--source DIR] [--out DIR] [--drafts] [--future] [--json]

  * `--source` — site root containing `cherry.exs` (default: cwd)
  * `--out` — output directory (default: `SOURCE/_site`)
  * `--drafts` — include posts marked `draft: true`
  * `--future` — include posts dated after today

  With `--json`, emits the standard envelope with page and asset counts.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, out: :string, drafts: :boolean, future: :boolean]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    output = Keyword.get(opts, :out, Path.join(source, "_site"))

    build_opts = [
      source: source,
      output: output,
      drafts: Keyword.get(opts, :drafts, false),
      future: Keyword.get(opts, :future, false)
    ]

    case Cherry.build(build_opts) do
      {:ok, build} ->
        {:ok, %{output: output, pages: length(build.pages), assets: length(build.assets)}}

      {:error, reason} ->
        {:error, %Error{code: :build_failed, message: reason}}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{output: output, pages: pages, assets: assets}) do
    "Built #{pages} page(s), #{assets} asset(s) → #{output}"
  end
end
