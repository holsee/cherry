defmodule Cherry.StylingLadderTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The customization ladder's middle rungs (DESIGN.md): `tokens:` overrides
  and `assets/custom.css`, both riding the framework-owned head so every
  theme honors them, both unlayered over the theme's `@layer theme` CSS.
  """

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  describe "tokens: config (rung 2)" do
    test "overrides land in every page head as an unlayered style block", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, tokens: ["--color-accent": "#7c3aed", "--measure": "46rem"]|)

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      for path <- ["hello-world/index.html", "blog/index.html", "404.html"] do
        html = page(build, path)
        assert html =~ ~s(<style id="cherry-tokens">)
        assert html =~ "--color-accent: #7c3aed;"
        assert html =~ "--measure: 46rem;"
      end
    end

    test "an unknown token fails the build, naming the nearest real one", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, tokens: ["--color-acent": "#7c3aed"]|)

      assert {:error, message} = Cherry.build(source: source, output: Path.join(tmp, "out"))
      assert message =~ "--color-acent"
      assert message =~ "did you mean --color-accent?"
      assert message =~ "theme.tokens"
    end

    test "a value carrying CSS structure characters is rejected at load", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, tokens: ["--color-accent": "red;}body{display:none"]|)

      assert {:error, message} = Cherry.Site.load(source)
      assert message =~ "--color-accent"
    end

    test "a non-token key is rejected at load", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, tokens: [accent: "#7c3aed"]|)

      assert {:error, message} = Cherry.Site.load(source)
      assert message =~ "start with `--`"
    end
  end

  describe "assets/custom.css (rung 3)" do
    test "ships as an asset and links after the tokens block", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, tokens: ["--color-accent": "#7c3aed"]|)
      File.mkdir_p!(Path.join(source, "assets"))
      File.write!(Path.join(source, "assets/custom.css"), "h1 { letter-spacing: -0.02em; }\n")

      out = Path.join(tmp, "out")
      {:ok, build} = Cherry.build(source: source, output: out, today: @today)

      assert File.read!(Path.join(out, "assets/custom.css")) =~ "letter-spacing"

      html = page(build, "hello-world/index.html")
      assert html =~ ~s(<link rel="stylesheet" href="/assets/custom.css">)

      tokens_at = :binary.match(html, "cherry-tokens") |> elem(0)
      custom_at = :binary.match(html, "custom.css") |> elem(0)
      assert tokens_at < custom_at, "custom.css must load after the tokens block"
    end

    test "the link respects base_path", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s|, base_path: "/repo"|)
      File.mkdir_p!(Path.join(source, "assets"))
      File.write!(Path.join(source, "assets/custom.css"), "h1 { color: var(--color-fg); }\n")

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      assert page(build, "hello-world/index.html") =~
               ~s(<link rel="stylesheet" href="/repo/assets/custom.css">)
    end
  end

  describe "the quiet default" do
    test "no tokens and no custom.css leaves the head alone", %{tmp_dir: tmp} do
      source = fixture(tmp, "")

      {:ok, build} = Cherry.build(source: source, output: Path.join(tmp, "out"), today: @today)

      html = page(build, "hello-world/index.html")
      refute html =~ "cherry-tokens"
      refute html =~ "custom.css"
    end
  end

  describe "@layer theme (what makes the ladder win)" do
    test "both official themes ship their CSS inside the theme layer" do
      for name <- ["default", "cherrybomb"] do
        css =
          Cherry.Theme.builtin_root(name)
          |> Path.join("assets/site.css")
          |> File.read!()

        assert css =~ "@layer theme {", "#{name}/assets/site.css is not layered"
      end
    end
  end

  describe "Theme.validate_overrides/2" do
    test "accepts declared tokens and rejects strangers with a suggestion" do
      {:ok, theme} = Cherry.Theme.load(Cherry.Theme.default_root())

      assert :ok = Cherry.Theme.validate_overrides(theme, [{"--color-accent", "#7c3aed"}])
      assert :ok = Cherry.Theme.validate_overrides(theme, [])

      assert {:error, message} =
               Cherry.Theme.validate_overrides(theme, [{"--color-acent", "#7c3aed"}])

      assert message =~ "did you mean --color-accent?"

      assert {:error, message} = Cherry.Theme.validate_overrides(theme, [{"--zzz", "x"}])
      refute message =~ "did you mean"
    end
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
