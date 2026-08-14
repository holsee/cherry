defmodule Cherry.ThemeWorkflowTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Cherry.Theme.Provenance

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp} do
    File.write!(Path.join(tmp, "cherry.exs"), "[title: \"T\", url: \"https://t.example\"]")

    post = Path.join(tmp, "content/posts/2026-01-01-first.md")
    File.mkdir_p!(Path.dirname(post))
    File.write!(post, "---\ntitle: First\n---\nBody.\n")

    {:ok, site: tmp}
  end

  test "theme.eject writes provenance and the edited overlay wins the rebuild", %{site: site} do
    {code, _output} = with_io(fn -> Cherry.CLI.run(["theme.eject", "post", "--source", site]) end)
    assert code == 0

    overlay = Path.join(site, "themes/default/templates/post.html.eex")
    assert File.exists?(overlay)
    assert {:ok, provenance} = overlay |> File.read!() |> Provenance.read()
    assert provenance.theme == "default"

    # Edit the ejected template; the rebuild must pick the overlay up.
    File.write!(overlay, File.read!(overlay) <> "\n<p class=\"customized\">mine</p>\n")

    out = Path.join(site, "_site")
    assert {:ok, _} = Cherry.build(source: site, output: out)
    assert File.read!(Path.join(out, "first/index.html")) =~ ~s(class="customized")
  end

  test "theme.eject refuses to clobber without --force", %{site: site} do
    {0, _} = with_io(fn -> Cherry.CLI.run(["theme.eject", "post", "--source", site]) end)

    code_holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(
          code_holder,
          {:code, Cherry.CLI.run(["theme.eject", "post", "--source", site])}
        )
      end)

    assert_receive {:code, 1}
    assert stderr =~ "--force"
  end

  test "theme.which prints the chain and marks the winner", %{site: site} do
    {code, output} = with_io(fn -> Cherry.CLI.run(["theme.which", "post", "--source", site]) end)

    assert code == 0
    assert output =~ "site_overlay"
    assert output =~ "(missing)"
    assert output =~ "theme"
    assert output =~ "← renders"

    # After ejecting, the overlay wins.
    {0, _} = with_io(fn -> Cherry.CLI.run(["theme.eject", "post", "--source", site]) end)

    {0, after_eject} =
      with_io(fn -> Cherry.CLI.run(["theme.which", "post", "--source", site]) end)

    assert after_eject =~ ~r/site_overlay.*← renders/
  end

  test "theme.list --json reports inventory and overlay state", %{site: site} do
    {0, _} = with_io(fn -> Cherry.CLI.run(["theme.eject", "post", "--source", site]) end)

    {code, output} =
      with_io(fn -> Cherry.CLI.run(["theme.list", "--source", site, "--json"]) end)

    assert code == 0
    assert %{"ok" => true, "data" => data} = JSON.decode!(output)
    assert data["name"] == "default"
    assert data["contract"] =~ ~r/^1\./

    post = Enum.find(data["templates"], &(&1["name"] == "post"))
    assert post["resolves_from"] == "site_overlay"
    assert post["overlay"] == "fresh"

    layout = Enum.find(data["templates"], &(&1["name"] == "layout"))
    assert layout["resolves_from"] == "theme"
    assert layout["overlay"] == nil
  end
end
