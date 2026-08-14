defmodule Cherry.PortfolioTest do
  use ExUnit.Case, async: true

  alias Cherry.Portfolio
  alias Cherry.Portfolio.{CV, Link, OpenSource, Position, Profile}

  @today ~D[2026-08-14]

  describe "portfolio collections" do
    @tag :tmp_dir
    test "entries load as data-only documents: no pages of their own", %{tmp_dir: tmp} do
      write_portfolio_site(tmp)
      out = Path.join(tmp, "_site")

      assert {:ok, build} = Cherry.build(source: tmp, output: out, today: @today)

      entries = Enum.filter(build.documents, &(&1.collection =~ "portfolio/"))
      assert length(entries) == 5
      assert Enum.all?(entries, &is_nil(&1.path))
      assert Enum.all?(entries, &is_nil(&1.url))

      # Views render them later; the output tree contains no entry pages.
      refute File.exists?(Path.join(out, "acme/index.html"))

      portfolio = Portfolio.from_build(build)
      assert Portfolio.present?(portfolio)

      assert [%Position{} = position] = portfolio.positions
      assert position.title == "Staff Engineer"
      assert position.org == "Acme"
      assert position.started == ~D[2020-01-01]
      assert Position.current?(position)
      assert position.cv == %CV{include: true, weight: 10, highlights: ["Led the platform"]}
      assert position.slug == "acme"
      assert position.html =~ "Acme years"

      assert [project] = portfolio.projects
      assert project.links == [%Link{label: "Source", url: "https://github.com/x/y"}]
      assert project.status == "active"

      assert [%OpenSource{role: "author"}] = portfolio.oss
      assert [talk] = portfolio.talks
      assert talk.event == "ElixirConfEU"
      assert [education] = portfolio.education
      assert education.institution == "Queen's University Belfast"
    end

    @tag :tmp_dir
    test "draft entries are filtered unless --drafts", %{tmp_dir: tmp} do
      write_portfolio_site(tmp)

      write_file(tmp, "content/portfolio/projects/secret.md", """
      ---
      title: Secret
      draft: true
      ---
      """)

      {:ok, build} = Cherry.build(source: tmp, output: Path.join(tmp, "one"), today: @today)
      refute Enum.any?(build.documents, &(&1.meta[:title] == "Secret"))

      {:ok, with_drafts} =
        Cherry.build(source: tmp, output: Path.join(tmp, "two"), today: @today, drafts: true)

      assert Enum.any?(with_drafts.documents, &(&1.meta[:title] == "Secret"))
    end

    @tag :tmp_dir
    test "schema violations name the file and the field", %{tmp_dir: tmp} do
      write_site(tmp)

      write_file(tmp, "content/portfolio/oss/broken.md", """
      ---
      title: Broken
      repo: https://github.com/x/y
      role: owner
      ---
      """)

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "content/portfolio/oss/broken.md"
      assert message =~ ":role"
    end

    @tag :tmp_dir
    test "a bad cv block is rejected with the offending key", %{tmp_dir: tmp} do
      write_site(tmp)

      write_file(tmp, "content/portfolio/talks/bad.md", """
      ---
      title: Bad
      event: ConfConf
      date: 2024-05-01
      cv:
        includes: yes
      ---
      """)

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "content/portfolio/talks/bad.md"
      assert message =~ ~s("includes")
    end
  end

  describe "Profile.load/1" do
    @tag :tmp_dir
    test "absent portfolio.yaml is not an error", %{tmp_dir: tmp} do
      assert {:ok, nil} = Profile.load(tmp)
    end

    @tag :tmp_dir
    test "a valid profile loads into the struct", %{tmp_dir: tmp} do
      write_file(tmp, "portfolio.yaml", """
      name: holsee
      headline: Software engineer
      links:
        - label: GitHub
          url: https://github.com/holsee
      updated: 2026-08-01
      """)

      assert {:ok, %Profile{} = profile} = Profile.load(tmp)
      assert profile.name == "holsee"
      assert profile.links == [%Link{label: "GitHub", url: "https://github.com/holsee"}]
      assert profile.updated == ~D[2026-08-01]
      assert profile.email == nil
    end

    @tag :tmp_dir
    test "a broken profile fails the build naming the file", %{tmp_dir: tmp} do
      write_site(tmp)
      write_file(tmp, "portfolio.yaml", "headline: No name\n")

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "portfolio.yaml"
      assert message =~ ":name"
    end
  end

  test "cherry schema lists and introspects portfolio collections" do
    import ExUnit.CaptureIO

    {code, output} =
      with_io(fn -> Cherry.CLI.run(["schema", "portfolio/positions", "--json"]) end)

    assert code == 0
    assert %{"ok" => true, "data" => data} = JSON.decode!(output)

    fields = Map.new(data["fields"], &{&1["name"], &1})
    assert fields["org"]["required"] == true
    assert fields["start"]["type"] == "date"
    assert fields["cv"]["type"] == "cv block"
  end

  defp write_portfolio_site(tmp) do
    write_site(tmp)

    write_file(tmp, "content/portfolio/positions/acme.md", """
    ---
    title: Staff Engineer
    org: Acme
    start: 2020-01-01
    tags: [elixir]
    highlights:
      - Led the platform
    cv:
      include: true
      weight: 10
      highlights:
        - Led the platform
    ---
    Long-form story of the Acme years.
    """)

    write_file(tmp, "content/portfolio/projects/widget.md", """
    ---
    title: Widget
    start: 2022-03-01
    links:
      - label: Source
        url: https://github.com/x/y
    tags: [elixir]
    ---
    """)

    write_file(tmp, "content/portfolio/talks/conf.md", """
    ---
    title: Processes in 3D
    event: ElixirConfEU
    date: 2015-04-28
    video: https://example.com/video
    tags: [elixir]
    ---
    """)

    write_file(tmp, "content/portfolio/oss/cherry.md", """
    ---
    title: Cherry
    repo: https://github.com/holsee/cherry
    role: author
    tags: [elixir]
    ---
    """)

    write_file(tmp, "content/portfolio/education/qub.md", """
    ---
    title: BSc Computer Science
    institution: Queen's University Belfast
    start: 2005-09-01
    end: 2009-06-01
    ---
    """)
  end

  defp write_site(tmp) do
    write_file(tmp, "cherry.exs", ~s|[title: "T", url: "https://t.example"]|)
  end

  defp write_file(tmp, rel, content) do
    path = Path.join(tmp, rel)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
  end
end
