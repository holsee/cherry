defmodule Cherry.CLI.Registry do
  @moduledoc """
  Maps CLI verbs to their `Cherry.CLI.Command` modules.

  Deliberately a compile-time map: the verb surface is part of Cherry's
  public API and changes to it belong in code review, not runtime plugins.
  """

  @commands %{
    "build" => Cherry.Commands.Build,
    "check" => Cherry.Commands.Check,
    "config" => Cherry.Commands.Config,
    "gen.action" => Cherry.Commands.GenAction,
    "gen.post" => Cherry.Commands.GenPost,
    "gen.project" => Cherry.Commands.GenProject,
    "gen.talk" => Cherry.Commands.GenTalk,
    "gen.theme" => Cherry.Commands.GenTheme,
    "new" => Cherry.Commands.New,
    "publish" => Cherry.Commands.Publish,
    "schema" => Cherry.Commands.Schema,
    "serve" => Cherry.Commands.Serve,
    "theme.diff" => Cherry.Commands.ThemeDiff,
    "theme.eject" => Cherry.Commands.ThemeEject,
    "theme.list" => Cherry.Commands.ThemeList,
    "theme.tokens" => Cherry.Commands.ThemeTokens,
    "theme.which" => Cherry.Commands.ThemeWhich,
    "upgrade" => Cherry.Commands.Upgrade,
    "version" => Cherry.Commands.Version
  }

  @doc "Looks up the command module for a verb."
  @spec fetch(String.t()) :: {:ok, module()} | :error
  def fetch(verb), do: Map.fetch(@commands, verb)

  @doc "All known verbs, sorted, for help and error output."
  @spec verbs() :: [String.t()]
  def verbs, do: @commands |> Map.keys() |> Enum.sort()

  @doc """
  Whether a verb stays resident after a successful run.

  Both frontends consult this — the mix task and the binary must agree
  on which commands hold the VM open, or `cherry serve` exits the moment
  the banner prints (the standalone binary shipped exactly that bug in
  0.1.0-rc.1).
  """
  @spec blocking?(String.t()) :: boolean()
  def blocking?("serve"), do: true
  def blocking?(_verb), do: false
end
