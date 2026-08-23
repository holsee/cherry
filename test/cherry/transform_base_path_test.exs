defmodule Cherry.TransformBasePathTest do
  use ExUnit.Case, async: true

  alias Cherry.Build
  alias Cherry.Content.Document
  alias Cherry.Pipeline.Stages.Transform
  alias Cherry.Site

  @body """
  [blog](/blog/) and [home](/) and <a href="/cv/">cv</a>
  ![x](/images/x.png) [external](https://x.example/) [proto](//cdn.example/a)
  <a href="/repo/already/">already</a>
  """

  defp render(base_path) do
    doc = %Document{
      source: "x.md",
      collection: :pages,
      body: @body,
      path: "x/index.html",
      raw?: false,
      meta: %{}
    }

    site = %Site{title: "t", url: "https://x", base_path: base_path, root: ".", output: "_site"}
    {:ok, out} = Transform.run(%Build{options: [], site: site, documents: [doc]})
    hd(out.documents).html
  end

  test "root-absolute markdown links and sources move under the base path" do
    html = render("/repo/")

    assert html =~ ~s(href="/repo/blog/")
    assert html =~ ~s(href="/repo/")
    assert html =~ ~s(href="/repo/cv/")
    assert html =~ ~s(src="/repo/images/x.png")
    assert html =~ ~s(href="https://x.example/")
    assert html =~ ~s(href="//cdn.example/a")
    assert html =~ ~s(href="/repo/already/")
    refute html =~ ~s(/repo/repo/)
  end

  test "the root build leaves every link as written" do
    html = render("/")

    assert html =~ ~s(href="/blog/")
    assert html =~ ~s(src="/images/x.png")
  end
end
