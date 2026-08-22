defmodule Cherry.ThemeTest do
  use ExUnit.Case, async: true

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.{Provenance, Resolver}

  describe "conformance" do
    test "the default theme passes its own contract check" do
      assert {:ok, theme} = Theme.load(Theme.default_root())
      assert theme.name == "default"
      assert theme.contract =~ ~r/^1\./

      declared = Enum.map(theme.templates, & &1.name)
      assert Theme.required_templates() -- declared == []
    end

    @tag :tmp_dir
    test "a manifest missing a required template fails loudly", %{tmp_dir: tmp} do
      write_manifest(tmp, templates: "[layout: [assigns: [:site]]]")

      assert {:error, message} = Theme.load(tmp)
      assert message =~ "does not declare required template"
      assert message =~ "post"
    end

    @tag :tmp_dir
    test "a declared template without a file fails loudly", %{tmp_dir: tmp} do
      write_manifest(tmp,
        templates: "[layout: [], page: [], post: [], post_list: [], tag: [], not_found: []]"
      )

      assert {:error, message} = Theme.load(tmp)
      assert message =~ "declares but does not ship"
    end

    @tag :tmp_dir
    test "inherit_templates lets a theme skip shipping declared templates", %{tmp_dir: tmp} do
      write_manifest(tmp,
        contract: "1.1",
        templates: "[layout: [], page: [], post: [], post_list: [], tag: [], not_found: []]",
        extra: "inherit_templates: true,"
      )

      assert {:ok, theme} = Theme.load(tmp)
      assert theme.inherit_templates

      # Unshipped templates resolve through the framework level.
      site = %Site{title: "t", url: "https://x", base_path: "", root: tmp, output: "_s"}
      assert {:ok, {:framework, path}} = Resolver.resolve(site, theme, :layout)
      assert path == Path.join([Theme.default_root(), "templates", "layout.html.eex"])
    end

    @tag :tmp_dir
    test "an inheriting theme still must declare the full inventory", %{tmp_dir: tmp} do
      write_manifest(tmp,
        contract: "1.1",
        templates: "[layout: []]",
        extra: "inherit_templates: true,"
      )

      assert {:error, message} = Theme.load(tmp)
      assert message =~ "does not declare required template"
    end

    @tag :tmp_dir
    test "the missing-file error points at inherit_templates", %{tmp_dir: tmp} do
      write_manifest(tmp,
        templates: "[layout: [], page: [], post: [], post_list: [], tag: [], not_found: []]"
      )

      assert {:error, message} = Theme.load(tmp)
      assert message =~ "inherit_templates: true"
    end

    @tag :tmp_dir
    test "a contract-2.x theme is rejected by this Cherry", %{tmp_dir: tmp} do
      write_manifest(tmp, contract: "2.0", templates: "[layout: []]")

      assert {:error, message} = Theme.load(tmp)
      assert message =~ "contract 2.0"
      assert message =~ "1.x"
    end
  end

  describe "provenance" do
    test "stamp then read round-trips" do
      stamped = Provenance.stamp("<p>hi</p>", "default", "0.1.0")

      assert {:ok, provenance} = Provenance.read(stamped)
      assert provenance.theme == "default"
      assert provenance.version == "0.1.0"
      assert provenance.sha256 == Provenance.hash("<p>hi</p>")
    end

    test "status is fresh, stale, or untracked" do
      stamped = Provenance.stamp("original", "default", "0.1.0")

      assert Provenance.status(stamped, "original") == :fresh
      assert Provenance.status(stamped, "upstream moved on") == :stale
      assert Provenance.status("no header here", "original") == :untracked
    end
  end

  defp write_manifest(tmp, opts) do
    contract = Keyword.get(opts, :contract, "1.0")
    templates = Keyword.fetch!(opts, :templates)
    extra = Keyword.get(opts, :extra, "")

    File.write!(Path.join(tmp, "theme.exs"), """
    [
      name: "broken",
      version: "0.0.1",
      cherry_contract: "#{contract}",
      #{extra}
      templates: #{templates}
    ]
    """)
  end
end
