defmodule Cherry.CheckTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The verifier (DESIGN.md §6): rule-level tests against hand-built build
  tokens, plus end-to-end runs of `Cherry.check/1` and the `check` CLI
  command over the blog fixture — the agent loop this exists for.
  """

  import ExUnit.CaptureIO

  alias Cherry.Build
  alias Cherry.Check
  alias Cherry.Check.Diagnostic
  alias Cherry.CLI
  alias Cherry.Content.{Asset, Document, Page}
  alias Cherry.Site

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  describe "broken-link" do
    test "a href to a path the build does not emit is an error" do
      build = build_token(pages: [html_page("about/index.html", ~s(<a href="/nope/">gone</a>))])

      assert [%Diagnostic{rule: "broken-link", severity: :error} = diagnostic] =
               errors(Check.run(build))

      assert diagnostic.message =~ "/nope/"
    end

    test "links to emitted pages, assets, anchors, and external URLs all pass" do
      build =
        build_token(
          pages: [
            html_page("index.html", """
            <a href="/about/">about</a>
            <a href="/">home</a>
            <a href="/about/?utm=x#team">tracked anchor</a>
            <a href="https://elsewhere.example/">external</a>
            <a href="#local">fragment</a>
            <img src="/css/site.css">
            """),
            html_page("about/index.html", "<p>about</p>")
          ],
          assets: [%Asset{source: "s", path: "css/site.css"}]
        )

      assert errors(Check.run(build)) == []
    end

    test "respects a project-pages base path" do
      site = site(base_path: "/repo/")

      build =
        build_token(
          site: site,
          pages: [
            html_page(
              "index.html",
              ~s(<a href="/repo/about/">ok</a> <a href="/repo/gone/">bad</a>)
            ),
            html_page("about/index.html", "<p>about</p>")
          ]
        )

      assert [%Diagnostic{rule: "broken-link", message: message}] = errors(Check.run(build))
      assert message =~ "/repo/gone/"
    end
  end

  describe "missing-description" do
    test "posts and pages without description: warn; other collections stay silent" do
      build =
        build_token(
          documents: [
            document("posts", "posts/a.md", %{title: "A"}),
            document("pages", "pages/b.md", %{title: "B", description: ""}),
            document("projects", "portfolio/projects/c.md", %{title: "C"})
          ]
        )

      diagnostics = rule(Check.run(build), "missing-description")

      assert Enum.map(diagnostics, & &1.file) == ["pages/b.md", "posts/a.md"]
      assert Enum.all?(diagnostics, &(&1.severity == :warning))
    end
  end

  describe "missing-alt" do
    test "an <img> without alt warns; alt text (even empty) passes" do
      build =
        build_token(
          documents: [
            document(
              "posts",
              "posts/bare.md",
              %{title: "Bare", description: "d"},
              ~s(<img src="/a.png">)
            ),
            document(
              "posts",
              "posts/alted.md",
              %{title: "Alted", description: "d"},
              ~s(<img src="/b.png" alt="a basket of cherries">)
            )
          ]
        )

      assert [%Diagnostic{file: "posts/bare.md", severity: :warning}] =
               rule(Check.run(build), "missing-alt")
    end
  end

  describe "duplicate-title" do
    test "every document sharing a title warns and names the others" do
      build =
        build_token(
          documents: [
            document("posts", "posts/one.md", %{title: "Same", description: "d"}),
            document("pages", "pages/two.md", %{title: "Same", description: "d"}),
            document("posts", "posts/three.md", %{title: "Unique", description: "d"})
          ]
        )

      assert [first, second] = rule(Check.run(build), "duplicate-title")
      assert first.file == "pages/two.md"
      assert first.message =~ "posts/one.md"
      assert second.file == "posts/one.md"
      assert second.message =~ "pages/two.md"
    end
  end

  describe "feed sanity" do
    test "a build with no feed.xml is an error" do
      assert [%Diagnostic{rule: "feed-missing", severity: :error}] =
               build_token(feed: false) |> Check.run() |> rule("feed-missing")
    end

    test "a feed missing required Atom elements is an error per element" do
      build =
        build_token(
          feed: false,
          pages: [%Page{source: "feed", path: "feed.xml", content: "<feed></feed>"}]
        )

      diagnostics = rule(Check.run(build), "feed-invalid")

      assert length(diagnostics) == 2
      assert Enum.all?(diagnostics, &(&1.severity == :error))
    end
  end

  describe "ordering" do
    test "errors come before warnings" do
      build =
        build_token(
          pages: [html_page("index.html", ~s(<a href="/gone/">bad</a>))],
          documents: [document("posts", "posts/a.md", %{title: "A"})]
        )

      severities = build |> Check.run() |> Enum.map(& &1.severity)
      assert severities == Enum.sort_by(severities, &(&1 != :error))
    end
  end

  describe "Cherry.check/1 on the blog fixture" do
    @tag :tmp_dir
    test "reports only missing-description warnings and writes nothing", %{tmp_dir: tmp} do
      source = copy_fixture(tmp)

      assert {:ok, build, diagnostics} = Cherry.check(source: source, today: @today)

      assert build.pages != []
      assert Enum.all?(diagnostics, &(&1.rule == "missing-description"))
      assert Enum.all?(diagnostics, &(&1.severity == :warning))
      refute File.exists?(Path.join(source, "_site"))
    end

    @tag :tmp_dir
    test "a described site comes back with zero diagnostics", %{tmp_dir: tmp} do
      source = tmp |> copy_fixture() |> describe_everything()

      assert {:ok, _build, []} = Cherry.check(source: source, today: @today)
    end

    @tag :tmp_dir
    test "finds a broken internal link", %{tmp_dir: tmp} do
      source = tmp |> copy_fixture() |> describe_everything()
      append(source, "content/pages/about.md", "\n[gone](/orchard-nowhere/)\n")

      assert {:ok, _build, [diagnostic]} = Cherry.check(source: source, today: @today)
      assert diagnostic.rule == "broken-link"
      assert diagnostic.severity == :error
      assert diagnostic.message =~ "/orchard-nowhere/"
    end
  end

  describe "the check command" do
    @tag :tmp_dir
    test "all clear exits 0", %{tmp_dir: tmp} do
      source = tmp |> copy_fixture() |> describe_everything()

      {output, code} = run(["check", "--source", source])

      assert code == 0
      assert output =~ "all clear"
    end

    @tag :tmp_dir
    test "warnings alone exit 0 but are listed", %{tmp_dir: tmp} do
      source = copy_fixture(tmp)

      {output, code} = run(["check", "--source", source])

      assert code == 0
      assert output =~ "missing-description"
      assert output =~ "[warning]"
    end

    @tag :tmp_dir
    test "--strict promotes warnings to a failing exit", %{tmp_dir: tmp} do
      source = copy_fixture(tmp)

      {stderr, code} = run_stderr(["check", "--source", source, "--strict"])

      assert code == 1
      assert stderr =~ "missing-description"
    end

    @tag :tmp_dir
    test "a broken link exits 1 with the diagnostic on stderr", %{tmp_dir: tmp} do
      source = tmp |> copy_fixture() |> describe_everything()
      append(source, "content/pages/about.md", "\n[gone](/orchard-nowhere/)\n")

      {stderr, code} = run_stderr(["check", "--source", source])

      assert code == 1
      assert stderr =~ "broken-link"
      assert stderr =~ "/orchard-nowhere/"
    end

    @tag :tmp_dir
    test "--json emits structured diagnostics for the agent loop", %{tmp_dir: tmp} do
      source = copy_fixture(tmp)

      {output, code} = run(["check", "--source", source, "--json"])

      assert code == 0
      assert %{"ok" => true, "command" => "check", "data" => data} = JSON.decode!(output)
      assert data["errors"] == 0
      assert data["warnings"] == length(data["diagnostics"])

      assert Enum.all?(
               data["diagnostics"],
               &match?(%{"file" => _, "rule" => _, "message" => _, "severity" => "warning"}, &1)
             )
    end
  end

  # --- helpers ------------------------------------------------------------

  defp site(overrides) do
    struct!(
      %Site{
        title: "Orchard",
        url: "https://orchard.example",
        base_path: "/",
        author: "Orchard",
        root: ".",
        output: "_site"
      },
      overrides
    )
  end

  # A minimal build token; includes a valid feed page unless `feed: false`
  # so unrelated rules are not drowned out by feed-missing.
  defp build_token(overrides) do
    {feed?, overrides} = Keyword.pop(overrides, :feed, true)
    site = Keyword.get(overrides, :site, site([]))

    feed_pages =
      if feed?,
        do: [
          %Page{
            source: "feed",
            path: "feed.xml",
            content: "<feed><id>x</id><updated>y</updated></feed>"
          }
        ],
        else: []

    %Build{
      site: site,
      options: Build.Options.new(today: @today),
      documents: Keyword.get(overrides, :documents, []),
      pages: Keyword.get(overrides, :pages, []) ++ feed_pages,
      assets: Keyword.get(overrides, :assets, [])
    }
  end

  defp html_page(path, content) do
    %Page{source: path, path: path, content: content}
  end

  defp document(collection, source, meta, html \\ "<p>body</p>") do
    %Document{collection: collection, source: source, meta: meta, html: html}
  end

  defp errors(diagnostics), do: Enum.filter(diagnostics, &(&1.severity == :error))

  defp rule(diagnostics, name), do: Enum.filter(diagnostics, &(&1.rule == name))

  defp copy_fixture(tmp) do
    source = Path.join(tmp, "src")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))
    source
  end

  # Gives every markdown document a description so the fixture checks clean.
  defp describe_everything(source) do
    source
    |> String.replace("\\", "/")
    |> Path.join("content/**/*.md")
    |> Path.wildcard()
    |> Enum.each(fn file ->
      content = file |> File.read!() |> String.replace("\r\n", "\n")

      unless content =~ "description:" do
        File.write!(
          file,
          String.replace(content, "---\ntitle:", "---\ndescription: filled in\ntitle:",
            global: false
          )
        )
      end
    end)

    source
  end

  defp append(source, rel, text) do
    file = Path.join(source, rel)
    File.write!(file, File.read!(file) <> text)
  end

  defp run(argv) do
    {code, output} = with_io(fn -> CLI.run(argv) end)
    {output, code}
  end

  defp run_stderr(argv) do
    code_holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(code_holder, {:code, CLI.run(argv)})
      end)

    assert_receive {:code, code}
    {stderr, code}
  end
end
