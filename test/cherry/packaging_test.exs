defmodule Cherry.PackagingTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `priv/` ships by explicit subdirectory so the local dialyzer PLT cache
  never lands in the package. That trade means a new `priv/` directory is
  silently absent from the released package until someone lists it — and
  the failure surfaces as a `File.read!` crash in a user's build, not
  here. This test closes that gap.
  """

  @plts "plts"

  test "every priv subdirectory ships in the hex package" do
    files = Mix.Project.config()[:package][:files]

    shipped =
      :cherry
      |> :code.priv_dir()
      |> File.ls!()
      |> Enum.filter(&File.dir?(Path.join(:code.priv_dir(:cherry), &1)))
      |> Enum.reject(&(&1 == @plts))

    for dir <- shipped do
      assert "priv/#{dir}" in files,
             "priv/#{dir} is not in mix.exs :files — it would be missing from the " <>
               "released package, and anything reading it would crash in a user's build"
    end
  end

  test "the consent gate the analytics module reads is one of them" do
    gate = :cherry |> :code.priv_dir() |> Path.join("consent/consent.js")

    assert File.regular?(gate)
    assert "priv/consent" in Mix.Project.config()[:package][:files]
  end
end
