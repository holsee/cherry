defmodule Cherry.AnalyticsTest do
  use ExUnit.Case, async: true

  alias Cherry.Analytics

  @moduledoc """
  The `analytics:` config key: one provider, rendered into the
  framework-owned head so it reaches every page of every theme — and
  classified by what it stores, so the consent gate ships only for the
  provider that needs it and cookieless sites carry no banner at all.
  """

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  describe "cookieless providers" do
    test "the beacon renders on every page, including the 404", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, analytics: [cloudflare: "beacon-token"]|)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      beacon =
        ~s(<script defer src="https://static.cloudflareinsights.com/beacon.min.js" ) <>
          ~s(data-cf-beacon='{"token":"beacon-token"}'></script>)

      assert page(build, "hello-world/index.html") =~ beacon
      assert page(build, "blog/index.html") =~ beacon
      # The 404 carries no SEO head at all, so it is the page a
      # head-riding feature is most likely to miss.
      assert page(build, "404.html") =~ beacon
    end

    test "a theme with no layout of its own still carries it", %{tmp_dir: tmp} do
      source =
        fixture(tmp, ~s|, theme: "teletype", analytics: [plausible: "orchard.example"]|)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      assert page(build, "hello-world/index.html") =~
               ~s(<script defer data-domain="orchard.example" ) <>
                 ~s(src="https://plausible.io/js/script.js"></script>)
    end

    test "no consent gate ships — not a banner, not a byte", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, analytics: [goatcounter: "orchard"]|)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")
      assert html =~ ~s(data-goatcounter="https://orchard.goatcounter.com/count")
      refute html =~ "cherry-consent"
    end
  end

  describe "the host: override for self-hosted instances" do
    test "plausible keeps its domain and moves only the script origin", %{tmp_dir: tmp} do
      source =
        fixture(
          tmp,
          ~s|, analytics: [plausible: [id: "orchard.example", | <>
            ~s|host: "https://stats.orchard.example"]]|
        )

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      assert page(build, "hello-world/index.html") =~
               ~s(<script defer data-domain="orchard.example" ) <>
                 ~s(src="https://stats.orchard.example/js/script.js"></script>)
    end

    test "a self-hosted goatcounter serves both the endpoint and the script" do
      assert {:ok, analytics} = Analytics.validate(goatcounter: [host: "https://stats.example"])

      assert Analytics.head(analytics) =~
               ~s(<script async data-goatcounter="https://stats.example/count" ) <>
                 ~s(src="https://stats.example/count.js"></script>)
    end

    test "hosted goatcounter still splits the endpoint from the shared CDN" do
      assert {:ok, analytics} = Analytics.validate(goatcounter: "orchard")
      head = Analytics.head(analytics)

      assert head =~ ~s(data-goatcounter="https://orchard.goatcounter.com/count")
      assert head =~ ~s(src="https://gc.zgo.at/count.js")
    end

    test "a trailing slash on the host does not double up in the URL" do
      assert {:ok, analytics} =
               Analytics.validate(plausible: [id: "a.example", host: "https://s.example/"])

      assert Analytics.head(analytics) =~ ~s(src="https://s.example/js/script.js")
    end

    test "providers with no self-hosted edition refuse host: rather than ignore it" do
      for provider <- [:cloudflare, :google] do
        assert {:error, message} =
                 Analytics.validate([{provider, [id: "G-ABC123", host: "https://s.example"]}])

        assert message =~ "no self-hosted edition"
        assert message =~ "goatcounter and plausible"
      end
    end

    test "a host without a scheme is rejected — it would emit a broken src" do
      assert {:error, message} = Analytics.validate(goatcounter: [host: "stats.example.com"])
      assert message =~ "not an absolute URL"
    end

    test "plausible still needs an id, because data-domain identifies the site" do
      assert {:error, message} = Analytics.validate(plausible: [host: "https://s.example"])
      assert message =~ "needs an id"
    end

    test "a misspelled option names the two that exist" do
      assert {:error, message} = Analytics.validate(plausible: [id: "a.example", hst: "x"])
      assert message =~ "unknown key :hst"
      assert message =~ "only id: and host:"
    end
  end

  describe "google, the consent-gated provider" do
    test "the tag is not in the document — only the gate is", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, analytics: [google: "G-ABC123"]|)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")

      # The whole point: nothing loads GA until the visitor accepts, so no
      # script element anywhere on the page points at it. The gate builds
      # that URL at runtime, which is why this matches tags, not text.
      refute html =~ ~r/<script[^>]*\ssrc="https:\/\/www\.googletagmanager\./

      assert html =~ ~s(<script data-cherry-consent-id="G-ABC123">)
      assert [gate] = Regex.run(~r/<script data-cherry-consent-id="[^"]*"[^>]*>/, html)
      refute gate =~ "src="

      # The bar is built by the gate at runtime, so it is not in the HTML.
      refute html =~ ~s(<div class="cherry-consent")
    end

    test "consent_required? splits the providers by what they store" do
      assert {:ok, google} = Analytics.validate(google: "G-ABC123")
      assert Analytics.consent_required?(google)

      for provider <- [:cloudflare, :plausible, :goatcounter] do
        assert {:ok, analytics} = Analytics.validate([{provider, "id"}])
        refute Analytics.consent_required?(analytics)
      end

      refute Analytics.consent_required?(nil)
    end
  end

  describe "validation" do
    test "no analytics key emits nothing", %{tmp_dir: tmp} do
      source = fixture(tmp, "")

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")
      refute html =~ "cherry-consent"
      refute html =~ "cloudflareinsights"
      assert Analytics.head(nil) == ""
    end

    test "an unknown provider names the ones that exist" do
      assert {:error, message} = Analytics.validate(bing: "x")
      assert message =~ ":bing is not a known provider"
      assert message =~ ":cloudflare"
    end

    test "two providers is a mistake, not a merge" do
      assert {:error, message} = Analytics.validate(cloudflare: "a", plausible: "b")
      assert message =~ "pick one"
    end

    test "a Universal Analytics id is named rather than emitted" do
      assert {:error, message} = Analytics.validate(google: "UA-12345-1")
      assert message =~ "switched off"
    end

    test "an id carrying HTML characters is rejected, not escaped" do
      assert {:error, message} = Analytics.validate(cloudflare: ~s(a" onload="alert(1))
      assert message =~ "characters no id has"
    end

    test "an empty or non-string id is rejected" do
      assert {:error, message} = Analytics.validate(cloudflare: "  ")
      assert message =~ "non-empty"

      assert {:error, message} = Analytics.validate(cloudflare: :token)
      assert message =~ ~s(cloudflare expects "an-id")
      assert message =~ "host:"
    end

    test "a bad provider fails config validation naming analytics", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, analytics: [bing: "x"]|)

      assert {:error, message} = Cherry.Site.load(source)
      assert message =~ "analytics"
    end
  end

  defp page(build, path) do
    Enum.find(build.pages, &(&1.path == path)).content
  end

  defp fixture(tmp, extra) do
    source = Path.join(tmp, "src")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Orchard", url: "https://orchard.example"#{extra}])
    )

    source
  end
end
