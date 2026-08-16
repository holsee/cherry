defmodule Mix.Tasks.Cherry.VersionTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "mix cherry.version prints the version through the seam" do
    output = capture_io(fn -> Mix.Tasks.Cherry.Version.run([]) end)

    assert String.starts_with?(output, "cherry #{Cherry.version()}")
  end

  test "moduledoc is single-sourced from the command module" do
    {:docs_v1, _, :elixir, _, %{"en" => task_doc}, _, _} =
      Code.fetch_docs(Mix.Tasks.Cherry.Version)

    assert task_doc == Cherry.Commands.Version.doc()
  end
end
