defmodule Cherry.Commands.Serve do
  @doc_text """
  Builds the site and serves it locally with live reload.

  ## Usage

      mix cherry.serve [--source DIR] [--out DIR] [--port N] [--json]

  Drafts are included (this is your writing loop). Edits to content,
  static files, themes, or `cherry.exs` rebuild automatically and reload
  connected browsers; a broken edit keeps the last good output serving
  and prints its diagnostics.

  `--port` defaults to 4000. `--port 0` binds an ephemeral free port —
  handy for agents and CI, where a fixed port may already be taken; the
  port actually bound is in the banner and the `--json` envelope.

  When no file-watcher backend is available (on Linux this means
  inotify-tools is not installed), the site still serves — just without
  live reload. The banner says so and the envelope carries
  `live_reload: false`.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, out: :string, port: :integer]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    output = Keyword.get(opts, :out, Path.join(source, "_site"))
    port = Keyword.get(opts, :port, 4000)

    case Cherry.Serve.start(source: source, output: output, port: port) do
      {:ok, pid, bound_port} ->
        {:ok,
         %{
           url: "http://localhost:#{bound_port}",
           port: bound_port,
           output: output,
           live_reload: Cherry.Serve.live_reload?(pid)
         }}

      {:error, message} ->
        {:error, %Error{code: :serve_failed, message: message}}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{url: url, live_reload: false}) do
    "Serving at #{url} (live reload unavailable, see the warning above) — Ctrl-C to stop."
  end

  def human(%{url: url}) do
    "Serving with live reload at #{url} — Ctrl-C to stop."
  end
end
