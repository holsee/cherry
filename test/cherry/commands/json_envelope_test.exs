defmodule Cherry.Commands.JsonEnvelopeTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The `--json` contract, audited across every verb in the registry: each
  command's success envelope decodes to `{ok, command, data}` and each
  failure to `{ok: false, command, error: {code, message, details}}`.

  A completeness gate fails this suite whenever a new verb lands without
  envelope coverage — the machine surface is Cherry's agent API and may
  not drift silently.
  """

  import ExUnit.CaptureIO

  alias Cherry.CLI
  alias Cherry.CLI.Registry

  @moduletag :tmp_dir

  @fixture Path.expand("../../fixtures/sites/blog", __DIR__)
  @today "2026-08-14"

  # Verbs proven below; the completeness gate keeps this list honest.
  @covered ~w(build check gen.action gen.post gen.project gen.talk gen.theme
              publish schema theme.diff theme.eject theme.list theme.which version)

  # serve runs until interrupted — its envelope cannot round-trip in a test.
  @excluded ~w(serve)

  test "every registry verb has envelope coverage or an explicit exclusion" do
    assert Enum.sort(Registry.verbs()) == Enum.sort(@covered ++ @excluded)
  end

  describe "success envelopes decode with data" do
    test "version" do
      assert %{"version" => _} = data(["version"])
    end

    test "schema" do
      assert %{"collection" => "posts", "fields" => _} = data(["schema", "posts"])
    end

    test "build", %{tmp_dir: tmp} do
      src = fixture(tmp)

      assert %{"pages" => pages, "assets" => _, "output" => _} =
               data(["build", "--source", src, "--out", Path.join(tmp, "out")])

      assert is_integer(pages)
    end

    test "check", %{tmp_dir: tmp} do
      src = fixture(tmp)

      assert %{"pages" => _, "errors" => 0, "warnings" => _, "diagnostics" => diagnostics} =
               data(["check", "--source", src])

      assert Enum.all?(
               diagnostics,
               &match?(%{"file" => _, "rule" => _, "message" => _, "severity" => _}, &1)
             )
    end

    test "gen.post and publish", %{tmp_dir: tmp} do
      src = stub_site(tmp)

      assert %{"path" => draft, "slug" => _, "date" => @today} =
               data(["gen.post", "Hello", "--source", src, "--today", @today])

      assert %{"from" => _, "to" => _, "date" => @today} =
               data(["publish", draft, "--source", src, "--today", @today])
    end

    test "gen.project", %{tmp_dir: tmp} do
      assert %{"path" => _, "slug" => _} =
               data(["gen.project", "Cider Press", "--source", stub_site(tmp)])
    end

    test "gen.talk", %{tmp_dir: tmp} do
      assert %{"path" => _, "slug" => _} =
               data([
                 "gen.talk",
                 "Growing the BEAM",
                 "--source",
                 stub_site(tmp),
                 "--today",
                 @today
               ])
    end

    test "gen.theme", %{tmp_dir: tmp} do
      assert %{"path" => _, "name" => "neon", "from" => _} =
               data(["gen.theme", "neon", "--source", stub_site(tmp)])
    end

    test "gen.action", %{tmp_dir: tmp} do
      assert %{"path" => _, "branch" => _} = data(["gen.action", "--source", stub_site(tmp)])
    end

    test "theme.list", %{tmp_dir: tmp} do
      assert %{"name" => _, "templates" => _, "tokens" => _} =
               data(["theme.list", "--source", fixture(tmp)])
    end

    test "theme.which", %{tmp_dir: tmp} do
      assert %{"template" => "post", "winner" => _, "chain" => _} =
               data(["theme.which", "post", "--source", fixture(tmp)])
    end

    test "theme.diff", %{tmp_dir: tmp} do
      assert %{"theme" => _, "version" => _, "entries" => [], "applied" => []} =
               data(["theme.diff", "--source", fixture(tmp)])
    end

    test "theme.eject", %{tmp_dir: tmp} do
      assert %{"ejected" => [%{"template" => "post", "path" => _}]} =
               data(["theme.eject", "post", "--source", fixture(tmp)])
    end
  end

  describe "error envelopes decode with code, message, and details" do
    test "check --strict carries the diagnostics structurally", %{tmp_dir: tmp} do
      src = fixture(tmp)

      {output, code} = run(["check", "--source", src, "--strict", "--json"])

      assert code == 1
      assert %{"ok" => false, "command" => "check", "error" => error} = JSON.decode!(output)
      assert error["code"] == "check_failed"
      assert %{"errors" => errors, "diagnostics" => [_ | _]} = error["details"]
      assert errors > 0
    end

    test "a usage error carries empty details" do
      {output, code} = run(["schema", "--bogus", "--json"])

      assert code == 2
      assert %{"ok" => false, "error" => error} = JSON.decode!(output)
      assert error["code"] == "usage"
      assert error["details"] == %{}
    end

    test "a command failure keeps the envelope shape", %{tmp_dir: tmp} do
      {output, code} = run(["build", "--source", Path.join(tmp, "empty"), "--json"])

      assert code == 1
      assert %{"ok" => false, "command" => "build", "error" => error} = JSON.decode!(output)
      assert is_binary(error["message"])
      assert Map.has_key?(error, "details")
    end
  end

  # --- helpers ------------------------------------------------------------

  defp data(argv) do
    {output, code} = run(argv ++ ["--json"])

    assert code == 0, "#{Enum.join(argv, " ")} exited #{code}: #{output}"

    assert %{"ok" => true, "command" => command, "data" => data} = JSON.decode!(output)
    assert command == hd(argv)
    data
  end

  defp run(argv) do
    {code, output} = with_io(fn -> CLI.run(argv) end)
    {output, code}
  end

  defp fixture(tmp) do
    src = Path.join(tmp, "src")
    File.cp_r!(@fixture, src)
    File.rm_rf!(Path.join(src, "expected"))
    src
  end

  defp stub_site(tmp) do
    File.write!(Path.join(tmp, "cherry.exs"), ~s([title: "T", url: "https://t.example"]))
    tmp
  end
end
