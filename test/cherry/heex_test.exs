defmodule Cherry.HeexTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The HEEx template lane: `.html.heex` files render through the same
  three-level lookup as EEx, win over the `.eex` twin at the same level,
  escape by default, and speak function components — including ones a
  theme defines at runtime in `components.exs` (ADR 0002: identical in
  project mode and the binary).
  """

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Commands.ThemeEject
  alias Cherry.Theme.{Drift, Resolver}

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  describe "resolution" do
    test "a .heex overlay wins over the theme's .eex template", %{tmp_dir: tmp} do
      source = fixture(tmp)

      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)

      File.write!(Path.join(overlay_dir, "post.html.heex"), """
      <article class="heex-wins">
      <h1>{@doc.meta.title}</h1>
      {Phoenix.HTML.raw(@doc.html)}
      </article>
      """)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")
      assert html =~ ~s(<article class="heex-wins">)
      assert html =~ "<h1>Hello, world</h1>"
    end

    test "a .heex overlay wins over a .eex overlay at the same level", %{tmp_dir: tmp} do
      source = fixture(tmp)
      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)
      File.write!(Path.join(overlay_dir, "post.html.eex"), "<p>eex overlay</p>")
      File.write!(Path.join(overlay_dir, "post.html.heex"), "<p>heex overlay</p>")

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      assert page(build, "hello-world/index.html") =~ "heex overlay"
    end

    test "theme.which shows both candidates per level", %{tmp_dir: tmp} do
      source = fixture(tmp)
      {:ok, site} = Cherry.Site.load(source)
      {:ok, theme} = Cherry.Theme.load_active(site)

      chain = Resolver.chain(site, theme, :post)
      paths = Enum.map(chain, fn {_level, path, _exists?} -> Path.extname(path) end)

      assert ".heex" in paths and ".eex" in paths

      heex_at =
        Enum.find_index(chain, fn {level, path, _} ->
          level == :theme and String.ends_with?(path, ".heex")
        end)

      eex_at =
        Enum.find_index(chain, fn {level, path, _} ->
          level == :theme and String.ends_with?(path, ".eex")
        end)

      assert heex_at < eex_at, ".heex must outrank .eex within a level"
    end
  end

  describe "the language" do
    test "interpolation escapes by default; raw/1 is the explicit door", %{tmp_dir: tmp} do
      source = fixture(tmp)
      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)

      File.write!(Path.join(overlay_dir, "post.html.heex"), """
      <p class="title">{@doc.meta.title}</p>
      <div class="body">{raw(@doc.html)}</div>
      """)

      post = Path.join(source, "content/posts/2026-01-15-hello-world.md")

      File.write!(post, """
      ---
      title: Tags <b>allowed?</b>
      tags: [elixir]
      description: Escaping proof.
      ---
      **bold** body
      """)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")
      assert html =~ "Tags &lt;b&gt;allowed?&lt;/b&gt;", "title must be escaped"
      assert html =~ "<strong>bold</strong>", "rendered markdown passes through raw/1"
    end

    test "helpers are imported; :for works", %{tmp_dir: tmp} do
      source = fixture(tmp)
      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)

      File.write!(Path.join(overlay_dir, "post_list.html.heex"), """
      <ul>
        <li :for={post <- @posts}>
          <time>{format_date(post.meta.date)}</time>
          <a href={post.url}>{post.meta.title}</a>
        </li>
      </ul>
      """)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "blog/index.html")
      assert html =~ "January 15, 2026"
      assert html =~ ~s(<a href="/hello-world/">Hello, world</a>)
    end

    test "a malformed template fails the build naming file, line, and column", %{tmp_dir: tmp} do
      source = fixture(tmp)
      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)
      File.write!(Path.join(overlay_dir, "post.html.heex"), "<div><span></div>")

      assert {:error, message} =
               Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      assert message =~ "post.html.heex:1:12"
      assert message =~ "unmatched closing tag"
    end
  end

  describe "theme components.exs" do
    test "function components defined by the theme render in its templates", %{tmp_dir: tmp} do
      source = fixture(tmp)

      # A site-local theme carrying components.exs — the full composition
      # story, runtime-compiled like every other .exs escape hatch.
      theme_dir = Path.join(source, "themes/orchard")
      File.mkdir_p!(Path.join(theme_dir, "templates"))

      File.cp_r!(
        Path.join(Cherry.Theme.default_root(), "templates"),
        Path.join(theme_dir, "templates")
      )

      File.mkdir_p!(Path.join(theme_dir, "assets"))
      File.cp_r!(Path.join(Cherry.Theme.default_root(), "assets"), Path.join(theme_dir, "assets"))

      manifest =
        Cherry.Theme.default_root()
        |> Path.join("theme.exs")
        |> File.read!()
        |> String.replace(~s(name: "default"), ~s(name: "orchard"))

      File.write!(Path.join(theme_dir, "theme.exs"), manifest)

      File.write!(Path.join(theme_dir, "components.exs"), """
      defmodule Orchard.Components do
        use Phoenix.Component

        attr :title, :string, required: true
        slot :inner_block

        def card(assigns) do
          ~H\"\"\"
          <section class="card"><h2>{@title}</h2>{render_slot(@inner_block)}</section>
          \"\"\"
        end
      end
      """)

      File.write!(Path.join(theme_dir, "templates/post.html.heex"), """
      <.card title={@doc.meta.title}>
        {raw(@doc.html)}
      </.card>
      """)

      config = ~s([title: "Orchard", url: "https://orchard.example", theme: "themes/orchard"])
      File.write!(Path.join(source, "cherry.exs"), config)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")
      assert html =~ ~s(<section class="card"><h2>Hello, world</h2>)
    end
  end

  describe "drift and eject" do
    test "a .heex overlay is :rewritten — owned, not drift", %{tmp_dir: tmp} do
      source = fixture(tmp)
      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)
      File.write!(Path.join(overlay_dir, "post.html.heex"), "<p>{@doc.meta.title}</p>")

      {:ok, site} = Cherry.Site.load(source)
      {:ok, theme} = Cherry.Theme.load_active(site)

      assert [%{template: :post, status: :rewritten}] = Drift.entries(site, theme)

      {:ok, _build, diagnostics} = Cherry.check(source: source, today: @today)
      refute Enum.any?(diagnostics, &(&1.rule in ["stale-overlay", "untracked-overlay"]))
    end

    test "eject refuses a template that is rewritten as HEEx", %{tmp_dir: tmp} do
      source = fixture(tmp)
      overlay_dir = Path.join(source, "themes/default/templates")
      File.mkdir_p!(overlay_dir)
      File.write!(Path.join(overlay_dir, "post.html.heex"), "<p>{@doc.meta.title}</p>")

      context = %Context{
        verb: "theme.eject",
        args: ["post"],
        opts: [source: source]
      }

      assert {:error, %Error{code: :overlay_rewritten, message: message}} =
               ThemeEject.run(context)

      assert message =~ "edit the .heex file"
    end
  end

  defp page(build, path) do
    Enum.find(build.pages, &(&1.path == path)).content
  end

  defp fixture(tmp) do
    source = Path.join(tmp, "src")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))
    source
  end
end
