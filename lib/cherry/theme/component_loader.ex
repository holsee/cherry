defmodule Cherry.Theme.ComponentLoader do
  @moduledoc """
  Loads a theme's `components.exs`: an optional file at the theme root
  defining function-component modules (`use Phoenix.Component`) that
  every HEEx template in that theme can call as `<.name …>`.

  Compiled at runtime — the same escape-hatch mechanism as `theme.exs`
  and site extension scripts (ADR 0002), so binary-mode sites get the
  full feature. Compilation is cached on the file's content hash;
  `cherry serve` picks up edits because a changed file is a changed
  hash, and the stale modules are purged before the recompile.
  """

  @doc """
  The modules defined by this theme's `components.exs`, compiled and
  cached; `[]` when the theme has none.
  """
  @spec modules(Path.t()) :: {:ok, [module()]} | {:error, String.t()}
  def modules(theme_root) do
    path = Path.join(theme_root, "components.exs")

    if File.exists?(path) do
      compile(path, File.read!(path))
    else
      {:ok, []}
    end
  end

  defp compile(path, source) do
    key = {__MODULE__, path}
    hash = :crypto.hash(:sha256, source)

    case :persistent_term.get(key, nil) do
      {^hash, modules} ->
        {:ok, modules}

      stale ->
        purge(stale)

        try do
          modules = for {mod, _bin} <- Code.compile_string(source, path), do: mod
          :persistent_term.put(key, {hash, modules})
          {:ok, modules}
        rescue
          error -> {:error, "#{path}: #{Exception.message(error)}"}
        end
    end
  end

  defp purge({_hash, modules}) do
    for mod <- modules do
      :code.purge(mod)
      :code.delete(mod)
    end
  end

  defp purge(nil), do: :ok
end
