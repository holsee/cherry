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
          "404.html",
          "feed.xml",
          "sitemap.xml",
          "robots.txt",
          "assets/site.css",
          # Reserved installer paths (ADR 0007) — cherrybomb.dev serves these.
          "install.sh",
          "install.ps1"
        ] do
      assert File.exists?(Path.join(out, file)), "missing #{file}"
    end

    index = File.read!(Path.join(out, "index.html"))
    assert index =~ ~s(<link rel="canonical" href="https://cherrybomb.dev/">)
  end
end
