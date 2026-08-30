defmodule Cherry.Analytics do
  @moduledoc """
  Optional visitor analytics: one line of `cherry.exs`, rendered into the
  framework-owned head so every theme carries it and none has to cooperate.

      analytics: [cloudflare: "your-beacon-token"]

  Providers are classified by what they put on the visitor's device,
  because that — not the word "analytics" — is what the ePrivacy
  Directive's Article 5(3) turns on:

    * `:cloudflare`, `:plausible` and `:goatcounter` set no cookies, touch
      no storage and do not fingerprint, so their beacon renders directly
      and no consent banner is ever shown. A banner for these would be
      theatre, and it teaches people to dismiss the banners that matter.
    * `:google` sets `_ga` cookies, so it is consent-gated: the tag is not
      in the document at all until the visitor accepts. See
      `assets/js/consent.ts` — a banner that appears after the tag has
      already fired is decoration, not compliance.

  Plausible and GoatCounter can be run on your own machines, so both take
  a `host:` override naming the origin that serves them:

      analytics: [plausible: [id: "example.com", host: "https://stats.example.com"]]
      analytics: [goatcounter: [host: "https://stats.example.com"]]

  Cloudflare and GA have no self-hosted edition, so `host:` is refused for
  them rather than quietly ignored. GoatCounter needs no `id:` alongside a
  `host:` — a self-hosted instance *is* the site — while Plausible always
  needs one, because `data-domain` is how it tells your sites apart.

  Cherry ships no analytics by default; omit the key and nothing is
  emitted — not a beacon, not a banner, not a byte.
  """

  # The three facts config needs about a vendor: whether it stores
  # something (so a gate ships), whether it can be self-hosted (so `host:`
  # is accepted), and whether an id is meaningful once a host is named.
  @providers [
    cloudflare: %{consent: :not_required, self_hostable: false, id: :always},
    goatcounter: %{consent: :not_required, self_hostable: true, id: :unless_host},
    google: %{consent: :required, self_hostable: false, id: :always},
    plausible: %{consent: :not_required, self_hostable: true, id: :always}
  ]

  @enforce_keys [:provider]
  defstruct [:provider, :id, :host]

  @type provider :: :cloudflare | :goatcounter | :google | :plausible
  @type t :: %__MODULE__{
          provider: provider(),
          id: String.t() | nil,
          host: String.t() | nil
        }

  @doc "The supported providers, sorted."
  @spec providers() :: [provider()]
  def providers, do: Keyword.keys(@providers)

  @doc """
  Whether this provider needs consent before it may load.

  True only when the provider stores something on the device; the
  cookieless beacons answer false and ship no banner.
  """
  @spec consent_required?(t() | nil) :: boolean()
  def consent_required?(nil), do: false
  def consent_required?(%__MODULE__{provider: provider}), do: consent(provider) == :required

  @doc """
  The head block for a site's analytics — `""` when none is configured.

  Framework-owned like the SEO head and the font preloads: interpolated
  verbatim inside `<head>` by `Cherry.Theme.Renderer`, so it reaches every
  page in every theme, including the 404 that carries no SEO head.
  """
  @spec head(t() | nil) :: String.t()
  def head(nil), do: ""
  def head(%__MODULE__{} = analytics), do: tag(analytics)

  @doc false
  # NimbleOptions custom validator: exactly one `provider: id_or_opts`
  # pair. One provider, not a list — two analytics scripts on a page is a
  # mistake every time, and saying so here beats debugging double counts.
  @spec validate(term()) :: {:ok, t()} | {:error, String.t()}
  def validate(value) do
    with {:ok, {provider, spec}} <- single_pair(value),
         :ok <- known_provider(provider),
         {:ok, id, host} <- parts(provider, spec),
         :ok <- usable_host(provider, host),
         :ok <- usable_id(provider, id, host) do
      {:ok, %__MODULE__{provider: provider, id: trim(id), host: trim_host(host)}}
    end
  end

  defp consent(provider), do: @providers[provider].consent

  defp single_pair(value) when is_list(value) do
    if Keyword.keyword?(value) do
      case value do
        [pair] -> {:ok, pair}
        [] -> {:error, example()}
        _many -> {:error, "expected one provider, got #{length(value)} — pick one"}
      end
    else
      {:error, example()}
    end
  end

  defp single_pair(_value), do: {:error, example()}

  defp example, do: ~s(expected one provider, e.g. [cloudflare: "beacon-token"])

  defp known_provider(provider) do
    if Keyword.has_key?(@providers, provider) do
      :ok
    else
      known = Enum.map_join(providers(), ", ", &inspect/1)
      {:error, "#{inspect(provider)} is not a known provider — one of #{known}"}
    end
  end

  # A bare string is the id and the vendor's own host; the keyword form is
  # the escape hatch for a self-hosted instance.
  defp parts(_provider, spec) when is_binary(spec), do: {:ok, spec, nil}

  defp parts(provider, spec) when is_list(spec) do
    if Keyword.keyword?(spec) do
      case Keyword.keys(spec) -- [:id, :host] do
        [] -> {:ok, spec[:id], spec[:host]}
        unknown -> {:error, "#{provider}: unknown #{keys(unknown)} — only id: and host:"}
      end
    else
      {:error, id_shape(provider)}
    end
  end

  defp parts(provider, _spec), do: {:error, id_shape(provider)}

  defp id_shape(provider) do
    ~s(#{provider} expects "an-id", or [id: "an-id", host: "https://your.instance"])
  end

  defp keys([one]), do: "key #{inspect(one)}"
  defp keys(many), do: "keys #{Enum.map_join(many, ", ", &inspect/1)}"

  defp usable_host(_provider, nil), do: :ok

  defp usable_host(provider, host) do
    cond do
      not @providers[provider].self_hostable ->
        hostable = @providers |> Enum.filter(&elem(&1, 1).self_hostable) |> Keyword.keys()

        {:error,
         "#{provider} has no self-hosted edition, so host: does not apply — " <>
           "only #{Enum.map_join(hostable, " and ", &to_string/1)} take it"}

      not is_binary(host) ->
        {:error, "#{provider} host: needs a string, got #{inspect(host)}"}

      true ->
        absolute_url(provider, String.trim(host))
    end
  end

  # An origin, not a path: the script and endpoint URLs are built from it,
  # so a relative or scheme-less value would emit a broken src.
  defp absolute_url(provider, host) do
    case URI.new(host) do
      {:ok, %URI{scheme: scheme, host: name}} when scheme in ["http", "https"] and name != nil ->
        :ok

      _otherwise ->
        {:error,
         "#{provider} host: #{inspect(host)} is not an absolute URL — " <>
           ~s(it needs a scheme, like "https://stats.example.com")}
    end
  end

  # Universal Analytics stopped processing in July 2023, and a UA- id in
  # a GA4 slot fails silently — worth naming rather than emitting.
  defp usable_id(:google, "UA-" <> _rest, _host) do
    {:error, "Universal Analytics (UA-…) was switched off in 2023 — use a GA4 id (G-…)"}
  end

  # A self-hosted GoatCounter instance is the site; there is no code to
  # name, so an id is optional exactly there.
  defp usable_id(provider, nil, host) do
    if host && @providers[provider].id == :unless_host do
      :ok
    else
      {:error, "#{provider} needs an id — #{id_shape(provider)}"}
    end
  end

  defp usable_id(provider, id, _host) when is_binary(id) do
    trimmed = String.trim(id)

    cond do
      trimmed == "" ->
        {:error, "#{provider} needs a non-empty id"}

      # Ids reach an HTML attribute by interpolation; every provider's id
      # is alphanumeric-with-dots, so anything else is a typo, not a value
      # to escape.
      String.match?(trimmed, ~r/[<>"'&\s]/) ->
        {:error, "#{provider} id #{inspect(id)} carries characters no id has: <>\"'& or spaces"}

      true ->
        :ok
    end
  end

  defp usable_id(provider, id, _host) do
    {:error, "#{provider} needs a string id, got #{inspect(id)}"}
  end

  defp trim(nil), do: nil
  defp trim(id), do: String.trim(id)

  defp trim_host(nil), do: nil
  defp trim_host(host), do: host |> String.trim() |> String.trim_trailing("/")

  defp tag(%__MODULE__{provider: :cloudflare, id: token}) do
    ~s(<script defer src="https://static.cloudflareinsights.com/beacon.min.js" ) <>
      ~s(data-cf-beacon='{"token":"#{token}"}'></script>\n)
  end

  defp tag(%__MODULE__{provider: :plausible, id: domain, host: host}) do
    origin = host || "https://plausible.io"

    ~s(<script defer data-domain="#{domain}" src="#{origin}/js/script.js"></script>\n)
  end

  # Hosted GoatCounter splits the two: the count endpoint is the site's own
  # subdomain, the script comes from a shared CDN. Your own instance serves
  # both, so a host: collapses them.
  defp tag(%__MODULE__{provider: :goatcounter, id: code, host: nil}) do
    goatcounter("https://#{code}.goatcounter.com/count", "https://gc.zgo.at/count.js")
  end

  defp tag(%__MODULE__{provider: :goatcounter, host: host}) do
    goatcounter("#{host}/count", "#{host}/count.js")
  end

  # No src, no tag, no cookies: only the gate ships. It loads GA itself,
  # and only once the visitor has said yes.
  defp tag(%__MODULE__{provider: :google, id: id}) do
    ~s(<script data-cherry-consent-id="#{id}">#{consent_gate()}</script>\n)
  end

  defp goatcounter(endpoint, script) do
    ~s(<script async data-goatcounter="#{endpoint}" src="#{script}"></script>\n)
  end

  defp consent_gate do
    :cherry
    |> :code.priv_dir()
    |> Path.join("consent/consent.js")
    |> File.read!()
    |> String.trim()
  end
end
