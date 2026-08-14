defmodule Cherry.ThemeAssetsSyncTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The client-side islands are compiled from assets/js/ into every official
  theme by `npm run build`. Both themes must carry byte-identical copies,
  so a rebuild that only lands in one theme cannot ship.
  """

  @islands ~w(theme-toggle.js copy-code.js)

  for island <- @islands do
    test "#{island} is byte-identical across official themes" do
      island = unquote(island)
      themes_dir = Path.join(:code.priv_dir(:cherry), "themes")

      [reference | rest] =
        for theme <- ~w(default cherrybomb) do
          path = Path.join([themes_dir, theme, "assets", island])
          assert File.regular?(path), "#{theme} is missing assets/#{island}"
          {theme, File.read!(path)}
        end

      {ref_theme, ref_bytes} = reference

      for {theme, bytes} <- rest do
        assert bytes == ref_bytes,
               "assets/#{island} differs between #{ref_theme} and #{theme}; " <>
                 "run `npm run build` to recompile both from assets/js/"
      end
    end
  end
end
