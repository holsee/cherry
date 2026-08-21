defmodule Cherry.ThemeDiffTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Managed drift (DESIGN.md): provenance turns theme upgrades into a
  mechanical three-way comparison — and `cherry check` warns whenever a
  shadowed template needs attention.
  """

  import ExUnit.CaptureIO

  alias Cherry.Theme
  alias Cherry.Theme.{Drift, Provenance, Resolver}

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp} do
    File.write!(Path.join(tmp, "cherry.exs"), "[title: \"T\", url: \"https://t.example\"]")

    post = Path.join(tmp, "content/posts/2026-01-01-first.md")
    File.mkdir_p!(Path.dirname(post))
    File.write!(post, "---\ntitle: First\ndescription: d\n---\nBody.\n")

    {:ok, site} = Cherry.Site.load(tmp)
    {:ok, theme} = Theme.load_active(site)
    {:ok, site: site, theme: theme, root: tmp}
  end

  describe "Drift.entries/2" do
    test "a fresh eject is current, and local edits stay current", %{root: root} = ctx do
      {_, 0} = run(["theme.eject", "post", "--source", root])

      assert [%Drift.Entry{template: :post, status: :current}] =
               Drift.entries(ctx.site, ctx.theme)

      # Local edits with an unchanged upstream are yours to keep — no nag.
      overlay = overlay_path(root)
      File.write!(overlay, File.read!(overlay) <> "\n<p>mine</p>\n")

      assert [%Drift.Entry{status: :current}] = Drift.entries(ctx.site, ctx.theme)
    end

    test "upstream moved + untouched copy = auto_updatable", ctx do
      craft_auto_updatable(ctx)

      assert [%Drift.Entry{template: :post, status: :auto_updatable}] =
               Drift.entries(ctx.site, ctx.theme)
    end

    test "both moved = conflict; no header = untracked", ctx do
      craft_conflict(ctx)
      assert [%Drift.Entry{status: :conflict}] = Drift.entries(ctx.site, ctx.theme)

      File.write!(overlay_path(ctx.root), "<article>hand copy</article>\n")
      assert [%Drift.Entry{status: :untracked}] = Drift.entries(ctx.site, ctx.theme)
    end

    test "update/2 re-ejects only the auto-updatable", ctx do
      craft_auto_updatable(ctx)
      [entry] = Drift.entries(ctx.site, ctx.theme)

      assert :ok = Drift.update(entry, ctx.theme)
      assert [%Drift.Entry{status: :current}] = Drift.entries(ctx.site, ctx.theme)

      upstream = ctx.theme |> Theme.template_path(:post) |> File.read!()
      assert File.read!(entry.overlay) == Provenance.stamp(upstream, "default", ctx.theme.version)

      craft_conflict(ctx)
      [conflicted] = Drift.entries(ctx.site, ctx.theme)
      assert {:error, message} = Drift.update(conflicted, ctx.theme)
      assert message =~ "conflict"
    end
  end

  describe "the theme.diff command" do
    test "reports every overlay's status", %{root: root} = ctx do
      craft_auto_updatable(ctx)

      {output, 0} = run(["theme.diff", "--source", root])

      assert output =~ "post"
      assert output =~ "auto_updatable"
      assert output =~ "--apply"
    end

    test "--apply re-ejects and reports what it touched", %{root: root} = ctx do
      craft_auto_updatable(ctx)

      {output, 0} = run(["theme.diff", "--source", root, "--apply", "--json"])

      assert %{"ok" => true, "data" => data} = JSON.decode!(output)
      assert data["applied"] == ["post"]
      assert [%{"template" => "post", "status" => "current"}] = data["entries"]

      assert [%Drift.Entry{status: :current}] = Drift.entries(ctx.site, ctx.theme)
    end

    test "--apply never touches a conflict", %{root: root} = ctx do
      craft_conflict(ctx)
      before = File.read!(overlay_path(root))

      {output, 0} = run(["theme.diff", "--source", root, "--apply", "--json"])

      assert %{"data" => %{"applied" => [], "entries" => [entry]}} = JSON.decode!(output)
      assert entry["status"] == "conflict"
      assert File.read!(overlay_path(root)) == before
    end

    test "naming a template without an overlay is a usage error", %{root: root} do
      {stderr, code} = run_stderr(["theme.diff", "cv", "--source", root])

      assert code == 2
      assert stderr =~ "no overlay"
    end
  end

  describe "cherry check integration" do
    test "stale and untracked overlays warn", %{root: root} = ctx do
      craft_auto_updatable(ctx)

      assert {:ok, _build, diagnostics} = Cherry.check(source: root)

      assert [stale] = Enum.filter(diagnostics, &(&1.rule == "stale-overlay"))
      assert stale.severity == :warning
      assert stale.file == "themes/default/templates/post.html.eex"
      assert stale.message =~ "--apply"
    end
  end

  defp overlay_path(root), do: Path.join(root, "themes/default/templates/post.html.eex")

  # Upstream moved since eject, local copy untouched: the recorded hash
  # matches the body but no longer matches the installed template.
  defp craft_auto_updatable(ctx) do
    old_body = upstream(ctx) <> "<!-- the previous theme version -->\n"
    write_overlay(ctx.root, Provenance.stamp(old_body, "default", "0.0.9"))
  end

  # Both moved: the recorded hash matches neither the body nor upstream.
  defp craft_conflict(ctx) do
    base = upstream(ctx) <> "<!-- base -->\n"
    [header | _body] = ctx.root |> stamp_lines(base)
    write_overlay(ctx.root, header <> "\n" <> upstream(ctx) <> "<p>mine</p>\n")
  end

  defp stamp_lines(_root, base) do
    String.split(Provenance.stamp(base, "default", "0.0.9"), "\n", parts: 2)
  end

  describe "site-local themes" do
    @tag :tmp_dir
    test "gen.theme produces a theme that check --strict accepts", %{root: root} do
      # The exact path a site owner follows to make the theme their own.
      index = Path.join(root, "content/pages/index.md")
      File.mkdir_p!(Path.dirname(index))
      File.write!(index, "---\ntitle: Home\ndescription: d\n---\nHome.\n")

      {_, 0} = run(["gen.theme", "mine", "--source", root])

      File.write!(
        Path.join(root, "cherry.exs"),
        "[title: \"T\", url: \"https://t.example\", theme: \"themes/mine\"]"
      )

      {:ok, site} = Cherry.Site.load(root)
      {:ok, theme} = Theme.load_active(site)

      # A theme living inside the site owns its templates: they are not
      # overlays of themselves, so there is no drift to report.
      assert Resolver.site_local?(site, theme)
      assert Resolver.overlay_path(site, theme, :post) == nil
      assert Drift.entries(site, theme) == []

      {output, code} = run(["check", "--strict", "--source", root, "--json"])
      assert code == 0, output
      assert %{"ok" => true} = JSON.decode!(output)
    end

    test "theme.eject refuses a site-local theme instead of writing onto it", %{root: root} do
      {_, 0} = run(["gen.theme", "mine", "--source", root])

      File.write!(
        Path.join(root, "cherry.exs"),
        "[title: \"T\", url: \"https://t.example\", theme: \"themes/mine\"]"
      )

      {stderr, code} = run_stderr(["theme.eject", "post", "--source", root])

      assert code == 2
      assert stderr =~ "already lives in this site"
    end

    test "an installed theme still gets overlays", %{site: site, theme: theme} do
      refute Resolver.site_local?(site, theme)
      assert Resolver.overlay_path(site, theme, :post) =~ "themes/default/templates/post.html.eex"
    end

    test "a builtin theme under the site root is not site-local (hex-dep case)" do
      # When cherry is a dependency, its priv/ — official themes included —
      # lives inside the site's own _build, so the ancestry check alone
      # would classify the theme as site-local and disable overlays for
      # every hex-dep site.
      builtin = Theme.builtin_root("cherrybomb")
      {:ok, theme} = Theme.load(builtin)

      root =
        builtin |> Path.split() |> Enum.take_while(&(&1 != "_build")) |> Path.join()

      assert String.starts_with?(Path.expand(builtin), Path.expand(root))

      site = %Cherry.Site{
        title: "T",
        url: "https://t.example",
        base_path: "/",
        root: root,
        output: Path.join(root, "_site")
      }

      refute Resolver.site_local?(site, theme)

      assert Resolver.overlay_path(site, theme, :layout) =~
               "themes/cherrybomb/templates/layout.html.eex"
    end
  end

  defp upstream(ctx), do: ctx.theme |> Theme.template_path(:post) |> File.read!()

  defp write_overlay(root, content) do
    path = overlay_path(root)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
  end

  defp run(argv) do
    {code, output} = with_io(fn -> Cherry.CLI.run(argv) end)
    {output, code}
  end

  defp run_stderr(argv) do
    code_holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(code_holder, {:code, Cherry.CLI.run(argv)})
      end)

    assert_receive {:code, code}
    {stderr, code}
  end
end
