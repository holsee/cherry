defmodule Cherry.Commands.Serve do
  @doc_text """
  Builds the site and serves it locally with live reload.

  ## Usage

      mix cherry.serve [--source DIR] [--out DIR] [--port N] [--name NAME] [--json]

  Drafts are included (this is your writing loop). Edits to content,
  static files, themes, or `cherry.exs` rebuild automatically and reload
  connected browsers; a broken edit keeps the last good output serving
  and prints its diagnostics.

  `--port` defaults to the `PORT` environment variable when set (what
  proxy runners hand out), then 4000. `--port 0` binds an ephemeral
  free port — handy for agents and CI, where a fixed port may already
  be taken; the port actually bound is in the banner and the `--json`
  envelope.

  `--name NAME` registers the bound port with a running
  [cherrypicker](https://github.com/holsee/cherrypicker) daemon, so the
  site also answers at a stable `http://NAME.localhost` URL. No daemon
  running simply means the port URL, never a failed serve.

  A site with a `base_path` serves under that prefix, exactly as
  production will: the banner URL carries it, the bare root redirects
  to it, and an unprefixed path that would 404 on the real host 404s
  here too.

  The server listens on both IPv4 and IPv6 (falling back to IPv4-only
  where IPv6 is unavailable), so `localhost` never stalls on hosts that
  resolve it to `::1` first. `--verbose` logs every request: method,
  path, status, and how long the response took.

  When no file-watcher backend is available (on Linux this means
  inotify-tools is not installed), the site still serves — just without
  live reload. The banner says so and the envelope carries
  `live_reload: false`.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Serve.Names

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, out: :string, port: :integer, name: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts, verbose?: verbose?}) do
    source = Keyword.get(opts, :source, File.cwd!())
    output = Keyword.get(opts, :out, Path.join(source, "_site"))
    port = Keyword.get_lazy(opts, :port, &port_env/0)

    case Cherry.Serve.start(source: source, output: output, port: port, verbose: verbose?) do
      {:ok, pid, bound_port, base} ->
        url = named_url(opts[:name], bound_port) || "http://localhost:#{bound_port}"

        {:ok,
         %{
           url: url <> base_suffix(base),
           port: bound_port,
           output: output,
           live_reload: Cherry.Serve.live_reload?(pid)
         }}

      {:error, message} ->
        {:error, %Error{code: :serve_failed, message: message}}
    end
  end

  # Proxy runners (cherrypicker, portless, foreman) hand out a port via
  # the environment; an explicit --port always wins over it.
  defp port_env do
    with value when is_binary(value) <- System.get_env("PORT"),
         {port, ""} <- Integer.parse(value) do
      port
    else
      _absent_or_malformed -> 4000
    end
  end

  # A base_path site serves under its prefix, so the URL people click
  # carries it; root sites keep the bare URL.
  defp base_suffix(""), do: ""
  defp base_suffix(base), do: base <> "/"

  defp named_url(nil, _port), do: nil

  defp named_url(name, port) do
    case Names.register(name, port) do
      {:ok, url} -> url
      :error -> nil
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
