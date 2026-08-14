defmodule Cherry.CLITest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Cherry.CLI

  describe "version" do
    test "prints the human line and exits 0" do
      {output, code} = run(["version"])

      assert code == 0
      assert output == "cherry #{Cherry.version()}\n"
    end

    test "--json emits the success envelope" do
      {output, code} = run(["version", "--json"])

      assert code == 0

      assert JSON.decode!(output) == %{
               "ok" => true,
               "command" => "version",
               "data" => %{"version" => Cherry.version()}
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

    test "empty argv exits 2" do
      {stderr, code} = run_stderr([])

      assert code == 2
      assert stderr =~ "no command given"
    end
  end

  describe "registry" do
    test "verbs/0 is sorted and includes version" do
      verbs = Cherry.CLI.Registry.verbs()

      assert "version" in verbs
      assert verbs == Enum.sort(verbs)
    end
  end

  defp run(argv) do
    {code, output} = with_io(fn -> CLI.run(argv) end)
    {output, code}
  end

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
