defmodule Cherry.ExampleTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The dogfood gate: `example/` (the cherrybomb.dev site) must always
  build with the public API — the framework can never drift from its own
  instructions.
  """

  @example Path.expand("../../example", __DIR__)

  @tag :tmp_dir
  test "the example site builds with feed, sitemap, and styled pages", %{tmp_dir: tmp} do
    out = Path.join(tmp, "site")

    assert {:ok, build} = Cherry.build(source: @example, output: out)
    assert build.pages != []

    for file <- [
          "index.html",
          "about/index.html",
          "blog/index.html",
          "guides/index.html",
          "guides/quick-start/index.html",
          "guides/elixir/index.html",
          "404.html",
          "feed.xml",
          "sitemap.xml",
          "robots.txt",
          "assets/site.css",
          "assets/copy-code.js",
          # The brand surface: icons by convention, social card, hero art,
          # and the theme-shipped nav mark.
          "favicon.ico",
          "apple-touch-icon.png",
          "og-card.png",
          "brand/cherrybomb-mark.webp",
          "assets/cherrybomb-mark.png",
          # Reserved installer paths (ADR 0007) — cherrybomb.dev serves these.
          "install.sh",
          "install.ps1"
        ] do
      assert File.exists?(Path.join(out, file)), "missing #{file}"
    end

    index = File.read!(Path.join(out, "index.html"))
    assert index =~ ~s(<link rel="canonical" href="https://cherrybomb.dev/">)
    assert index =~ ~s(<link rel="icon" href="/favicon.ico" sizes="32x32">)
    assert index =~ ~s(<meta property="og:image" content="https://cherrybomb.dev/og-card.png">)
    assert index =~ ~s(<meta name="twitter:card" content="summary_large_image">)
    assert index =~ ~s(<body class="page-home">)
    assert index =~ ~s(>Guides</a>)

    # Guides leads the nav (position: :start), before the Blog built-in.
    guides_at = :binary.match(index, ~s(>Guides</a>)) |> elem(0)
    blog_at = :binary.match(index, ~s(>Blog</a>)) |> elem(0)
    assert guides_at < blog_at

    # The landing pitch: the top-ten checklist and the portfolio/CV story.
    assert index =~ ~s(class="checks")
    assert index =~ "AI-agent-friendly CLI"
    assert index =~ "JSON Resume"

    # The real installers (ADR 0007): resolve latest stable with a
    # prerelease fallback (releases/latest 404s until a stable release
    # exists), verify checksums.
    install = File.read!(Path.join(out, "install.sh"))
    assert install =~ "releases/latest"
    assert install =~ "releases?per_page=1"
    assert install =~ "SHA256SUMS"
    assert install =~ "checksum mismatch"

    ps1 = File.read!(Path.join(out, "install.ps1"))
    assert ps1 =~ "releases/latest"
    assert ps1 =~ "releases?per_page=1"
    assert ps1 =~ "Get-FileHash"
    assert ps1 =~ "SHA256SUMS"
  end
end
