defmodule Cherry.Serve.Names do
  @moduledoc """
  Optional named local URLs for serve, via a running
  [cherrypicker](https://github.com/holsee/cherrypicker) daemon:
  `cherry serve --name mysite` registers the bound port and the site
  answers at `http://mysite.localhost[:proxy port]`.

  Deliberately stdlib-only (`:httpc` + the daemon's tiny control API)
  rather than a dependency: no daemon running is the common case, and
  it must cost nothing. `:error` here always means "fall back to the
  port URL", never a failed serve.
  """

  @doc """
  Registers `name` → `127.0.0.1:port` with a local cherrypicker daemon.

  Returns the named URL, or `:error` when no daemon is reachable or the
  daemon refuses the name (a diagnostic is printed for that case — the
  author asked for a name and should learn why it did not take).
  """
  @spec register(String.t(), :inet.port_number()) :: {:ok, String.t()} | :error
  def register(name, port) do
    with {:ok, proxy_port} <- daemon_port() do
      put_route(proxy_port, name, port)
    end
  end

  # The daemon advertises its bound port in ~/.cherrypicker/daemon.json
  # (CHERRYPICKER_HOME overrides, matching cherrypicker itself).
  defp daemon_port do
    home =
      System.get_env("CHERRYPICKER_HOME") || Path.join(System.user_home!(), ".cherrypicker")

    with {:ok, raw} <- File.read(Path.join(home, "daemon.json")),
         {:ok, %{"port" => port}} when is_integer(port) <- decode(raw) do
      {:ok, port}
    else
      _missing_or_malformed -> :error
    end
  end

  defp put_route(proxy_port, name, port) do
    url = ~c"http://127.0.0.1:#{proxy_port}/routes/#{URI.encode_www_form(name)}"
    headers = [{~c"host", ~c"cherrypicker.localhost"}]
    body = JSON.encode!(%{port: port})
    request = {url, headers, ~c"application/json", body}

    case :httpc.request(:put, request, [timeout: 2_000], body_format: :binary) do
      {:ok, {{_http, 200, _reason}, _headers, response}} ->
        named_url(response, proxy_port)

      {:ok, {{_http, _status, _reason}, _headers, response}} ->
        report_refusal(name, response)
        :error

      {:error, _reason} ->
        :error
    end
  end

  defp named_url(response, proxy_port) do
    case decode(response) do
      {:ok, %{"url" => url}} when proxy_port == 80 -> {:ok, url}
      {:ok, %{"url" => url}} -> {:ok, url <> ":#{proxy_port}"}
      _unexpected -> :error
    end
  end

  defp report_refusal(name, response) do
    reason =
      case decode(response) do
        {:ok, %{"error" => message}} -> message
        _unexpected -> "the daemon refused it"
      end

    IO.puts(:stderr, "warning: --name #{name} not registered: #{reason}")
  end

  defp decode(raw) do
    {:ok, JSON.decode!(raw)}
  rescue
    _error -> :malformed
  end
end
