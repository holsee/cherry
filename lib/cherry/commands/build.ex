defmodule Cherry.Commands.Build do
  @doc_text """
  Builds the site into `_site/`.

  ## Usage

      mix cherry.build [--source DIR] [--out DIR] [--json]

  * `--source` — site root containing `cherry.exs` (default: cwd)
  * `--out` — output directory (default: `SOURCE/_site`)

  With `--json`, emits the standard envelope with page and asset counts.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, out: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    output = Keyword.get(opts, :out, Path.join(source, "_site"))

    case Cherry.build(source: source, output: output) do
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
