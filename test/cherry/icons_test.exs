defmodule Cherry.IconsTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Favicon by convention (`Cherry.Site.Icons`): reserved names in
  `static/` become icon `<link>`s in every page's head, base_path-aware,
  in every theme — and stay absent when the files are absent.
  """

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  # The blog fixture ships favicon.ico + apple-touch-icon.png in static/.
  test "reserved static icons get head links on content and synthetic pages", %{tmp_dir: tmp} do
    source = fixture(tmp)

    {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

    post = page(build, "hello-world/index.html")
    assert post =~ ~s(<link rel="icon" href="/favicon.ico" sizes="32x32">)
    assert post =~ ~s(<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">)
    refute post =~ ~s(image/svg+xml)

    blog_index = page(build, "blog/index.html")
    assert blog_index =~ ~s(<link rel="icon" href="/favicon.ico" sizes="32x32">)
  end

  test "an svg icon is linked when present", %{tmp_dir: tmp} do
    source = fixture(tmp)

    File.write!(
      Path.join(source, "static/favicon.svg"),
      "<svg xmlns='http://www.w3.org/2000/svg'/>"
    )

    {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

    assert page(build, "hello-world/index.html") =~
             ~s(<link rel="icon" type="image/svg+xml" href="/favicon.svg">)
  end

  test "no icon files, no icon links", %{tmp_dir: tmp} do
    source = fixture(tmp)
    File.rm!(Path.join(source, "static/favicon.ico"))
    File.rm!(Path.join(source, "static/apple-touch-icon.png"))

    {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

    refute page(build, "hello-world/index.html") =~ ~s(rel="icon")
    refute page(build, "hello-world/index.html") =~ ~s(apple-touch-icon)
  end

  test "icon hrefs respect base_path", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s(, base_path: "/repo"))

    {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

    assert page(build, "hello-world/index.html") =~
             ~s(<link rel="icon" href="/repo/favicon.ico" sizes="32x32">)
  end

  defp page(build, path) do
    Enum.find(build.pages, &(&1.path == path)).content
  end

  defp fixture(tmp, extra \\ "") do
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
