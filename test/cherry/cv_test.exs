defmodule Cherry.CVTest do
  use ExUnit.Case, async: true

  alias Cherry.CV
  alias Cherry.CV.Skill
  alias Cherry.Portfolio
  alias Cherry.Portfolio.Position

  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  describe "CV.project/2" do
    @tag :tmp_dir
    test "curates via cv blocks and derives evidence-backed skills", %{tmp_dir: tmp} do
      {:ok, build} = Cherry.build(source: @folio, output: Path.join(tmp, "site"), today: @today)

      cv = build |> Portfolio.from_build() |> CV.project(@today)

      # Only cv-included entries; education included by default.
      assert [%Position{org: "Orchard Systems"}] = cv.positions
      assert [%{title: "Cider Press"}] = cv.projects
      assert cv.talks == []
      assert cv.oss == []
      assert [%{institution: "Orchard University"}] = cv.education

      # Skills merge overlapping calendar spans — no double counting:
      # position 2020-02→today and project 2023-06→today cover ~6.5 yrs.
      assert [%Skill{tag: "elixir", years: years}] = cv.skills
      assert_in_delta years, 6.5, 0.1
      assert Skill.format_years(%Skill{tag: "x", years: years, last_used: @today}) == "7 yrs"

      # Freshness from portfolio.yaml's explicit updated date.
      assert cv.updated == ~D[2026-08-01]
    end
  end

  describe "the CV pages" do
    @tag :tmp_dir
    test "public: page, cv.json, nav link, sitemap entry", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")
      {:ok, _build} = Cherry.build(source: @folio, output: out, today: @today)

      page = File.read!(Path.join(out, "cv/index.html"))
      assert page =~ "<h1>grower</h1>"
      assert page =~ "Updated August 2026"
      assert page =~ ~s(<a href="/cv/">CV</a>)
      assert page =~ ~s(<a href="/cv/timeline/">Timeline</a>)
      assert page =~ ~s(<div class="cv-columns">)
      assert page =~ ~s(Staff Engineer <span class="entry-org">· Orchard Systems</span>)
      assert page =~ ~s(<a href="/story/elixir/">elixir</a>)
      refute page =~ "noindex"
      refute page =~ "Hedgerow"

      resume = out |> Path.join("cv.json") |> File.read!() |> JSON.decode!()
      assert resume["basics"]["name"] == "grower"
      assert [work] = resume["work"]
      assert work["name"] == "Orchard Systems"
      assert work["highlights"] == ["Grew the platform from seed to fruit"]
      assert resume["skills"] == [%{"name" => "elixir"}]
      assert resume["meta"]["lastModified"] == "2026-08-01"

      assert File.read!(Path.join(out, "sitemap.xml")) =~ "https://folio.example/cv/"
    end

    @tag :tmp_dir
    test "unlisted: built with noindex, out of nav and sitemap", %{tmp_dir: tmp} do
      out = build_with_visibility(tmp, "unlisted")

      page = File.read!(Path.join(out, "cv/index.html"))
      assert page =~ ~s(<meta name="robots" content="noindex">)
      refute page =~ ~s(<a href="/cv/">CV</a>)

      assert File.exists?(Path.join(out, "cv.json"))
      # The timeline mode stays listed; only the CV page itself hides.
      sitemap = File.read!(Path.join(out, "sitemap.xml"))
      refute sitemap =~ "/cv/</loc>"
      assert sitemap =~ "/cv/timeline/</loc>"

      # An unlisted CV is never advertised from the timeline either.
      timeline = File.read!(Path.join(out, "cv/timeline/index.html"))
      refute timeline =~ ~s(<a href="/cv/">CV</a>)
    end

    @tag :tmp_dir
    test "off: the CV page vanishes, the timeline mode survives", %{tmp_dir: tmp} do
      out = build_with_visibility(tmp, "off")

      refute File.exists?(Path.join(out, "cv/index.html"))
      refute File.exists?(Path.join(out, "cv.json"))
      refute File.read!(Path.join(out, "index.html")) =~ ~s(>CV<)

      # The nav's profile entry falls back to the timeline, and the old
      # /portfolio/ URL redirects there instead of the hidden CV.
      assert File.exists?(Path.join(out, "cv/timeline/index.html"))
      assert File.read!(Path.join(out, "index.html")) =~ ~s(<a href="/cv/timeline/">Portfolio</a>)
      assert File.read!(Path.join(out, "portfolio/index.html")) =~ "url=/cv/timeline/"
    end
  end

  describe "Skill.derive/2" do
    test "merges overlapping spans and keeps disjoint ones apart" do
      overlapping = [
        position("a", ~D[2020-01-01], ~D[2022-01-01], ["elixir"]),
        position("b", ~D[2021-01-01], ~D[2023-01-01], ["elixir"]),
        position("c", ~D[2024-01-01], ~D[2025-01-01], ["elixir"])
      ]

      assert [%Skill{tag: "elixir", years: years, last_used: ~D[2025-01-01]}] =
               Skill.derive(overlapping, @today)

      # 2020→2023 merged (3 yrs) + 2024→2025 (1 yr) = 4, not the naive 5.
      assert_in_delta years, 4.0, 0.05
    end

    defp position(slug, started, ended, tags) do
      %Position{
        slug: slug,
        title: "T",
        org: "O",
        started: started,
        ended: ended,
        tags: tags
      }
    end
  end

  defp build_with_visibility(tmp, visibility) do
    source = Path.join(tmp, "src")
    out = Path.join(tmp, "out")
    File.cp_r!(@folio, source)
    File.rm_rf!(Path.join(source, "expected"))

    profile = File.read!(Path.join(source, "portfolio.yaml"))

    File.write!(
      Path.join(source, "portfolio.yaml"),
      profile <> "cv:\n  visibility: #{visibility}\n"
    )

    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
    out
  end
end
