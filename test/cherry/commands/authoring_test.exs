defmodule Cherry.Commands.AuthoringTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Cherry.Content.Slug

  @moduletag :tmp_dir

  doctest Cherry.Content.Slug

  setup %{tmp_dir: tmp} do
    File.write!(Path.join(tmp, "cherry.exs"), "[title: \"T\", url: \"https://t.example\"]")
    {:ok, site: tmp}
  end

  describe "gen.post" do
    test "creates a draft that builds with --drafts", %{site: site} do
      {code, output} =
        with_io(fn ->
          Cherry.CLI.run([
            "gen.post",
            "Hello, Agents!",
            "--source",
            site,
            "--today",
            "2026-08-14",
            "--json"
          ])
        end)

      assert code == 0
      assert %{"ok" => true, "data" => data} = JSON.decode!(output)
      assert data["path"] == "content/posts/2026-08-14-hello-agents.md"

      content = File.read!(Path.join(site, data["path"]))
      assert content =~ ~s(title: "Hello, Agents!")
      assert content =~ "draft: true"

      out = Path.join(site, "_site")
      assert {:ok, _} = Cherry.build(source: site, output: out, drafts: true)
      assert File.exists?(Path.join(out, "hello-agents/index.html"))

      # Without --drafts the draft stays out of the built site.
      out2 = Path.join(site, "_site2")
      assert {:ok, _} = Cherry.build(source: site, output: out2)
      refute File.exists?(Path.join(out2, "hello-agents/index.html"))
    end

    test "refuses to overwrite an existing draft", %{site: site} do
      args = ["gen.post", "Same Title", "--source", site, "--today", "2026-08-14"]
      {0, _} = with_io(fn -> Cherry.CLI.run(args) end)

      code_holder = self()

      stderr =
        capture_io(:stderr, fn -> send(code_holder, {:code, Cherry.CLI.run(args)}) end)

      assert_receive {:code, 1}
      assert stderr =~ "already exists"
    end
  end

  describe "publish" do
    test "re-dates the file and removes the draft flag", %{site: site} do
      {0, output} =
        with_io(fn ->
          Cherry.CLI.run([
            "gen.post",
            "Ship It",
            "--source",
            site,
            "--today",
            "2026-08-01",
            "--json"
          ])
        end)

      %{"data" => %{"path" => draft_path}} = JSON.decode!(output)

      {code, output} =
        with_io(fn ->
          Cherry.CLI.run([
            "publish",
            draft_path,
            "--source",
            site,
            "--today",
            "2026-08-14",
            "--json"
          ])
        end)

      assert code == 0
      assert %{"ok" => true, "data" => data} = JSON.decode!(output)
      assert data["to"] == "content/posts/2026-08-14-ship-it.md"

      refute File.exists?(Path.join(site, draft_path))
      published = File.read!(Path.join(site, data["to"]))
      refute published =~ "draft:"

      # The published post now builds without --drafts.
      out = Path.join(site, "_site")
      assert {:ok, _} = Cherry.build(source: site, output: out, today: ~D[2026-08-14])
      assert File.exists?(Path.join(out, "ship-it/index.html"))
    end

    test "rejects non-post filenames", %{site: site} do
      File.write!(Path.join(site, "notes.md"), "x")

      code_holder = self()

      stderr =
        capture_io(:stderr, fn ->
          send(code_holder, {:code, Cherry.CLI.run(["publish", "notes.md", "--source", site])})
        end)

      assert_receive {:code, 2}
      assert stderr =~ "YYYY-MM-DD-slug.md"
    end
  end

  test "slugify handles punctuation and unicode" do
    assert Slug.slugify("Café & Crème brûlée!") == "cafe-creme-brulee"
    assert Slug.slugify("100% Elixir") == "100-elixir"
  end
end
