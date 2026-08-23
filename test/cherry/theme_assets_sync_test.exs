defmodule Cherry.ThemeAssetsSyncTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The client-side islands are compiled from assets/js/ into every official
  theme by `npm run build` (build.mjs discovers themes from priv/themes).
  All themes must carry byte-identical copies, so a rebuild that only
  lands in some themes cannot ship.
  """

  @islands ~w(theme-toggle.js copy-code.js video-embed.js)

  for island <- @islands do
    test "#{island} is byte-identical across official themes" do
      island = unquote(island)
      themes_dir = Path.join(:code.priv_dir(:cherry), "themes")

      [reference | rest] =
        for theme <- Cherry.Theme.builtin_names() do
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
