defmodule Cherry.CollectionsTest do
  use ExUnit.Case, async: true

  import Cherry.GoldenAssertions

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @golden Path.join(@fixture, "expected")
  @today ~D[2026-08-14]

  describe "the blog fixture" do
    @tag :tmp_dir
    test "builds to match its golden tree (drafts + future excluded)", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")

      assert {:ok, build} = Cherry.build(source: @fixture, output: out, today: @today)

      # 2 pages + 2 published posts + blog index + 2 tag pages + 404
      # + feed/sitemap/robots; the draft and the 2099 post are filtered.
      assert length(build.pages) == 11
      assert_trees_equal(@golden, out)
    end

    @tag :tmp_dir
    test "is deterministic across repeat builds", %{tmp_dir: tmp} do
      one = Path.join(tmp, "one")
      two = Path.join(tmp, "two")

      assert {:ok, _} = Cherry.build(source: @fixture, output: one, today: @today)
      assert {:ok, _} = Cherry.build(source: @fixture, output: two, today: @today)

      assert_trees_equal(one, two)
    end

    @tag :tmp_dir
    test "--drafts and --future include the filtered posts", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")

      assert {:ok, _} =
               Cherry.build(
                 source: @fixture,
                 output: out,
                 today: @today,
                 drafts: true,
                 future: true
               )

      assert File.exists?(Path.join(out, "secret-draft/index.html"))
      assert File.exists?(Path.join(out, "from-the-future/index.html"))
    end
  end

  describe "frontmatter validation" do
    @tag :tmp_dir
    test "a missing required field fails naming the file and field", %{tmp_dir: tmp} do
      write_site(tmp, "content/posts/2026-01-01-untitled.md", """
      ---
      tags:
        - oops
      ---
      No title here.
      """)

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "content/posts/2026-01-01-untitled.md"
      assert message =~ ":title"
    end

    @tag :tmp_dir
    test "an unknown field fails naming the file and field", %{tmp_dir: tmp} do
      write_site(tmp, "content/posts/2026-01-01-typo.md", """
      ---
      title: Typo
      taggs: [oops]
      ---
      Body.
      """)

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "content/posts/2026-01-01-typo.md"
      assert message =~ ~s("taggs")
    end

    @tag :tmp_dir
    test "a bad filename fails naming the file", %{tmp_dir: tmp} do
      write_site(tmp, "content/posts/not-dated.md", """
      ---
      title: Undated
      ---
      Body.
      """)

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "content/posts/not-dated.md"
      assert message =~ "YYYY-MM-DD-slug.md"
    end

    @tag :tmp_dir
    test "all broken files are reported together", %{tmp_dir: tmp} do
      write_site(tmp, "content/posts/2026-01-01-one.md", "---\ntags: [a]\n---\nx\n")
      write_file(tmp, "content/posts/2026-01-02-two.md", "---\ntags: [b]\n---\nx\n")

      assert {:error, message} = Cherry.build(source: tmp, today: @today)
      assert message =~ "2026-01-01-one.md"
      assert message =~ "2026-01-02-two.md"
    end
  end

  defp write_site(tmp, rel, content) do
    File.write!(Path.join(tmp, "cherry.exs"), "[title: \"T\", url: \"https://t.example\"]")
    write_file(tmp, rel, content)
  end

  defp write_file(tmp, rel, content) do
    path = Path.join(tmp, rel)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
  end
end
