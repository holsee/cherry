defmodule Cherry.GoldenAssertions do
  @moduledoc """
  Compares a built output tree against a committed golden tree.

  Failures are readable: missing and unexpected files are listed by relative
  path, and content mismatches fall through to ExUnit's string diff.
  """

  import ExUnit.Assertions

  @doc """
  Asserts `actual_root` contains exactly the files of `expected_root`,
  byte-for-byte.
  """
  @spec assert_trees_equal(Path.t(), Path.t()) :: :ok
  def assert_trees_equal(expected_root, actual_root) do
    expected = tree(expected_root)
    actual = tree(actual_root)

    missing = Map.keys(expected) -- Map.keys(actual)
    extra = Map.keys(actual) -- Map.keys(expected)

    assert missing == [], "files missing from output: #{Enum.join(missing, ", ")}"
    assert extra == [], "unexpected files in output: #{Enum.join(extra, ", ")}"

    expected
    |> Map.keys()
    |> Enum.sort()
    |> Enum.each(fn rel ->
      expected_content = File.read!(expected[rel])
      actual_content = File.read!(actual[rel])

      assert actual_content == expected_content,
             "#{rel} differs from golden:\n" <>
               "--- expected\n#{expected_content}\n--- actual\n#{actual_content}"
    end)

    :ok
  end

  defp tree(root) do
    root
    |> Path.join("**")
    |> Path.wildcard(match_dot: true)
    |> Enum.filter(&File.regular?/1)
    |> Map.new(&{Path.relative_to(&1, root), &1})
  end
end
