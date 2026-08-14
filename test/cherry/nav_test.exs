defmodule Cherry.NavTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The `nav:` config key: extra entries after the built-ins, site-relative
  hrefs through `base_path`, absolute hrefs verbatim — and nav links are
  first-class citizens of the broken-link check.
  """

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  test "configured entries render after the built-ins on every page", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s|, nav: [[label: "Guides", href: "guides/"]]|)

    {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

    html = page(build, "hello-world/index.html")
    assert html =~ ~s(<a href="/guides/">Guides</a>)

    blog_at = :binary.match(html, ~s(<a href="/blog/">Blog</a>)) |> elem(0)
    guides_at = :binary.match(html, ~s(<a href="/guides/">Guides</a>)) |> elem(0)
    assert blog_at < guides_at

    assert page(build, "blog/index.html") =~ "Guides"
  end

  test "site-relative hrefs pick up base_path; absolute pass verbatim", %{tmp_dir: tmp} do
    source =
      fixture(
        tmp,
        ~s|, base_path: "/repo", nav: [[label: "Guides", href: "/guides/"], | <>
          ~s|[label: "Source", href: "https://github.com/holsee/cherry"]]|
      )

    {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

    html = page(build, "hello-world/index.html")
    assert html =~ ~s(<a href="/repo/guides/">Guides</a>)
    assert html =~ ~s(<a href="https://github.com/holsee/cherry">Source</a>)
  end

  test "an invalid nav entry fails config validation naming nav", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s|, nav: [[label: "Guides"]]|)

    assert {:error, message} = Cherry.Site.load(source)
    assert message =~ "nav"
  end

  test "nav hrefs are covered by the broken-link check", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s|, nav: [[label: "Ghost", href: "nowhere/"]]|)

    {:ok, _build, diagnostics} = Cherry.check(source: source, today: @today)

    assert Enum.any?(diagnostics, fn diagnostic ->
             diagnostic.rule == "broken-link" and diagnostic.message =~ "nowhere"
           end)
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
