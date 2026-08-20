defmodule Cherry.BasePathTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The base-path matrix: the same fixture built at the
  root and under a project-pages subpath, asserting every emitted URL —
  hrefs, srcs, canonicals, feed and sitemap locations — respects
  `base_path`. No template or stage may concatenate URL strings itself.
  """

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  describe "base_path: \"/\" (the root build)" do
    @tag :tmp_dir
    test "no emitted URL carries a subpath", %{tmp_dir: tmp} do
      out = build_with_base_path(tmp, nil)

      html = File.read!(Path.join(out, "hello-world/index.html"))
      assert html =~ ~s(<link rel="stylesheet" href="/assets/site.css">)
      assert html =~ ~s(<link rel="canonical" href="https://orchard.example/hello-world/">)
    end
  end

  describe "base_path: \"repo\" (GitHub project pages)" do
    @tag :tmp_dir
    test "every internal href and src starts with /repo/", %{tmp_dir: tmp} do
      out = build_with_base_path(tmp, "repo")

      for page <- html_pages(out) do
        for url <- internal_urls(File.read!(page)) do
          assert String.starts_with?(url, "/repo/"),
                 "#{Path.relative_to(page, out)} links outside the base path: #{url}"
        end
      end
    end

    @tag :tmp_dir
    test "canonical, feed, sitemap, and robots URLs include the base path", %{tmp_dir: tmp} do
      out = build_with_base_path(tmp, "repo")

      post = File.read!(Path.join(out, "hello-world/index.html"))
      assert post =~ ~s(<link rel="canonical" href="https://orchard.example/repo/hello-world/">)

      assert post =~
               ~s(<meta property="og:url" content="https://orchard.example/repo/hello-world/">)

      feed = File.read!(Path.join(out, "feed.xml"))
      assert feed =~ ~s(<link rel="self" href="https://orchard.example/repo/feed.xml"/>)
      assert feed =~ ~s(<id>https://orchard.example/repo/hello-world/</id>)

      sitemap = File.read!(Path.join(out, "sitemap.xml"))

      sitemap
      |> locs()
      |> Enum.each(fn loc ->
        assert String.starts_with?(loc, "https://orchard.example/repo/"),
               "sitemap loc outside the base path: #{loc}"
      end)

      robots = File.read!(Path.join(out, "robots.txt"))
      assert robots =~ "Sitemap: https://orchard.example/repo/sitemap.xml"
    end

    @tag :tmp_dir
    test "the sitemap covers every page except 404.html", %{tmp_dir: tmp} do
      out = build_with_base_path(tmp, "repo")

      locs = out |> Path.join("sitemap.xml") |> File.read!() |> locs()

      assert "https://orchard.example/repo/hello-world/" in locs
      assert "https://orchard.example/repo/blog/" in locs
      refute Enum.any?(locs, &String.contains?(&1, "404"))
    end
  end

  defp build_with_base_path(tmp, base_path) do
    source = Path.join(tmp, "src")
    out = Path.join(tmp, "out")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))

    config = [title: "Orchard", url: "https://orchard.example"]
    config = if base_path, do: config ++ [base_path: base_path], else: config
    File.write!(Path.join(source, "cherry.exs"), inspect(config))

    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
    out
  end

  defp html_pages(out) do
    out
    |> String.replace("\\", "/")
    |> Path.join("**/*.html")
    |> Path.wildcard()
  end

  # Root-relative href/src values: external URLs and anchors are exempt.
  defp internal_urls(html) do
    ~r/(?:href|src)="(\/[^"]*)"/
    |> Regex.scan(html, capture: :all_but_first)
    |> List.flatten()
  end

  defp locs(sitemap) do
    ~r/<loc>([^<]+)<\/loc>/
    |> Regex.scan(sitemap, capture: :all_but_first)
    |> List.flatten()
  end
end
