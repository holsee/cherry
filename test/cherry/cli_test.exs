defmodule Cherry.CLITest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Cherry.CLI

  describe "version" do
    test "prints the human line and exits 0" do
      {output, code} = run(["version"])

      assert code == 0
      assert String.starts_with?(output, "cherry #{Cherry.version()}")
    end

    # Both renderings, without depending on whether this particular build
    # was compiled from a checkout — `Cherry.revision/0` is a compile-time
    # constant, so branching on it here would be dead code in one world.
    test "the human line names the revision when the build has one" do
      assert render(%{version: "1.0.0", revision: "abc1234"}) == "cherry 1.0.0 (abc1234)"
      assert render(%{version: "1.0.0", revision: nil}) == "cherry 1.0.0"
    end

    test "--json emits the success envelope" do
      {output, code} = run(["version", "--json"])

      assert code == 0

      assert JSON.decode!(output) == %{
               "ok" => true,
               "command" => "version",
               "data" => %{"version" => Cherry.version(), "revision" => Cherry.revision()}
             }
    end
  end

  describe "usage errors" do
    test "unknown verb exits 2 and lists available verbs on stderr" do
      {stderr, code} = run_stderr(["frobnicate"])

      assert code == 2
      assert stderr =~ "unknown command \"frobnicate\""
      assert stderr =~ "version"
    end

    test "unknown verb with --json emits the error envelope on stdout" do
      {output, code} = run(["frobnicate", "--json"])

      assert code == 2

      assert %{"ok" => false, "command" => "frobnicate", "error" => error} =
               JSON.decode!(output)

      assert error["code"] == "usage"
      assert error["message"] =~ "unknown command"
    end

    test "invalid flag exits 2" do
      {stderr, code} = run_stderr(["version", "--bogus"])

      assert code == 2
      assert stderr =~ "invalid flags: --bogus"
    end

    test "help for an unknown verb exits 2" do
      {stderr, code} = run_stderr(["help", "frobnicate"])

      assert code == 2
      assert stderr =~ "unknown command \"frobnicate\""
    end
  end

  describe "help" do
    test "bare, `help`, and `--help` all print the base screen and exit 0" do
      for argv <- [[], ["help"], ["--help"], ["-h"]] do
        {output, code} = run(argv)

        assert code == 0
        assert output =~ "usage: cherry <command>"
        assert output =~ "--json"
      end
    end

    test "the base screen lists every registered verb with a summary" do
      {output, _code} = run(["help"])

      for verb <- Cherry.CLI.Registry.verbs() do
        assert output =~ verb
      end
    end

    test "`help <verb>` and `<verb> --help` print the command doc in binary form" do
      for argv <- [["help", "version"], ["version", "--help"], ["version", "-h"]] do
        {output, code} = run(argv)

        assert code == 0
        assert output =~ "Prints the Cherry version"
        assert output =~ "cherry version"
        refute output =~ "mix cherry."
      end
    end

    # Interception must happen before dispatch, or this test never returns.
    test "--help on a blocking verb prints instead of serving" do
      {output, code} = run(["serve", "--help"])

      assert code == 0
      assert output =~ "cherry serve"
    end

    test "every command's doc yields a non-empty summary line" do
      for verb <- Cherry.CLI.Registry.verbs() do
        {:ok, command} = Cherry.CLI.Registry.fetch(verb)
        [summary | _rest] = String.split(command.doc(), "\n")

        assert summary != "", "#{verb} has an empty first doc line"
      end
    end
  end

  describe "registry" do
    test "verbs/0 is sorted and includes version" do
      verbs = Cherry.CLI.Registry.verbs()

      assert "version" in verbs
      assert verbs == Enum.sort(verbs)
    end

    test "serve is the only blocking verb — both frontends hold the VM open for it" do
      assert Cherry.CLI.Registry.blocking?("serve")

      for verb <- Cherry.CLI.Registry.verbs(), verb != "serve" do
        refute Cherry.CLI.Registry.blocking?(verb), "#{verb} must not block"
      end
    end
  end

  defp run(argv) do
    {code, output} = with_io(fn -> CLI.run(argv) end)
    {output, code}
  end

  defp render(data), do: data |> Cherry.Commands.Version.human() |> IO.iodata_to_binary()

  defp run_stderr(argv) do
    code_holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(code_holder, {:code, CLI.run(argv)})
      end)

    assert_receive {:code, code}
    {stderr, code}
  end
end
