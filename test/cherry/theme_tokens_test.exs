defmodule Cherry.ThemeTokensTest do
  use ExUnit.Case, async: true

  alias Cherry.Theme

  @color_literal ~r/#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\(|oklch\(/

  # Every official theme obeys the same token discipline; a new theme
  # joins the gate by existing under priv/themes/.
  for name <- Theme.builtin_names() do
    describe "the #{name} theme" do
      @root Theme.builtin_root(name)

      test "templates carry no hard-coded colors — tokens only (house rule)" do
        for template <- Path.wildcard(Path.join(@root, "templates/*.eex")) do
          content = File.read!(template)

          refute Regex.match?(@color_literal, content),
                 "#{Path.basename(template)} contains a color literal; use a token in site.css"
        end
      end

      test "site.css defines colors only as custom-property tokens" do
        css = File.read!(Path.join(@root, "assets/site.css"))

        offenders =
          css
          |> String.split("\n")
          |> Enum.with_index(1)
          |> Enum.filter(fn {line, _n} ->
            # The @supports feature probe names colors to ask a question,
            # not to paint anything.
            Regex.match?(@color_literal, line) and
              not String.match?(line, ~r/^\s*--[\w-]+:/) and
              not String.match?(line, ~r/^\s*@supports /)
          end)

        assert offenders == [],
               "color literals outside token definitions:\n" <>
                 Enum.map_join(offenders, "\n", fn {line, n} -> "  #{n}: #{String.trim(line)}" end)
      end

      test "every manifest token is defined in site.css for both renditions" do
        {:ok, theme} = Theme.load(@root)
        css = File.read!(Path.join(@root, "assets/site.css"))
        lines = String.split(css, "\n")

        for {token, spec} <- theme.tokens do
          token_name = Atom.to_string(token)
          definitions = Enum.count(lines, &(&1 =~ ~r/^\s*#{token_name}:/))

          # A paired token appears twice — the plain light fallback and its
          # light-dark() line — plus once more in print for the six tokens
          # the print rendition forces. Rendition-independent tokens once.
          print_overridden = ~w(
            --color-bg --color-fg --color-muted --color-border
            --color-accent --color-accent-strong
          )

          expected =
            cond do
              token_name in print_overridden -> 3
              spec[:dark] -> 2
              true -> 1
            end

          assert definitions == expected,
                 "#{token_name} defined #{definitions}x in site.css, expected #{expected}"
        end
      end

      test "the manifest's light-dark pairs are exactly what site.css declares" do
        {:ok, theme} = Theme.load(@root)
        css = File.read!(Path.join(@root, "assets/site.css"))

        for {token, spec} <- theme.tokens, dark = spec[:dark] do
          token_name = Atom.to_string(token)

          assert css =~ "#{token_name}: light-dark(#{spec[:default]}, #{dark})",
                 "#{token_name}: manifest pair (#{spec[:default]}, #{dark}) not found in site.css"

          assert css =~ ~r/^\s*#{token_name}: #{spec[:default]};$/m,
                 "#{token_name}: light fallback #{spec[:default]} not found in site.css"
        end
      end
    end
  end
end
