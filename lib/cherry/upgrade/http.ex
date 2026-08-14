defmodule Cherry.Upgrade.HTTP do
  @moduledoc """
  The one HTTP client in Cherry: plain `:httpc` (no runtime deps), TLS
  verification against the OS trust store, redirects followed — GitHub
  serves release assets through a redirect to its CDN.

  `Cherry.Upgrade` takes this module's `fetch/1` as its default fetcher;
  tests inject a local stand-in instead.
  """

  @user_agent ~c"cherry-upgrade (+https://cherrybomb.dev)"

  @doc "GETs a URL, returning the body on 200."
  @spec fetch(String.t()) :: {:ok, binary()} | {:error, term()}
  def fetch(url) do
    {:ok, _apps} = Application.ensure_all_started([:inets, :ssl])

    headers = [
      {~c"user-agent", @user_agent},
      {~c"accept", ~c"application/vnd.github+json, application/octet-stream"}
    ]

    request = {String.to_charlist(url), headers}
    http_opts = [timeout: 120_000, connect_timeout: 15_000] ++ ssl_opts(url)

    case :httpc.request(:get, request, http_opts, body_format: :binary) do
      {:ok, {{_http, 200, _reason}, _headers, body}} -> {:ok, body}
      {:ok, {{_http, status, _reason}, _headers, _body}} -> {:error, {:status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp ssl_opts("https://" <> _rest) do
    [
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]
  end

  defp ssl_opts(_url), do: []
end
