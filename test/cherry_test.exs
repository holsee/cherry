defmodule CherryTest do
  use ExUnit.Case, async: true

  doctest Cherry

  test "version/0 reports the mix project version" do
    assert Cherry.version() == Mix.Project.config()[:version]
  end
end
