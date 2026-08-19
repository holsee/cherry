defmodule Cherry.Theme.Renderer do
  @moduledoc """
  Renders theme templates: runtime-evaluated, so themes work identically
  in project mode and binary mode (ADR 0002/0004). The file extension
  picks the language — `.html.eex` is classic EEx, `.html.heex` is HEEx
  with HTML-aware escaping, function components, and `:for`/`:if`.

  HEEx templates render with `Cherry.Theme.Helpers`, `Phoenix.Component`,
  and `Phoenix.HTML` imported, plus every module the theme's optional
  `components.exs` defines — so `<.card title={@title}>` resolves the
  way a Phoenix developer expects.
  """

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.{ComponentLoader, RenderContext, Resolver}
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView.HTMLEngine
  alias Phoenix.LiveView.TagEngine

  @doc """
  Renders a named template through the lookup chain with the given assigns.
  """
  @spec render(Site.t(), Theme.t(), atom(), keyword()) ::
          {:ok, String.t()} | {:error, String.t()}
  def render(%Site{} = site, %Theme{} = theme, name, assigns) do
    with {:ok, {_level, path}} <- Resolver.resolve(site, theme, name) do
      case Path.extname(path) do
        ".heex" -> render_heex(theme, path, assigns)
        _eex -> {:ok, EEx.eval_file(path, assigns: assigns)}
      end
    end
  end

  # Runtime HEEx: compile the template string with the tag engine, then
  # evaluate against an env carrying the imports. ~0.5ms per render —
  # a 100-page site pays about 50ms for the safety of real escaping.
  defp render_heex(theme, path, assigns) do
    with {:ok, components} <- ComponentLoader.modules(theme.root) do
      env = imports_env(components)

      quoted =
        TagEngine.compile(File.read!(path),
          caller: env,
          file: path,
          tag_handler: HTMLEngine
        )

      {rendered, _binding} = Code.eval_quoted(quoted, [assigns: Map.new(assigns)], env)
      {:ok, rendered |> Safe.to_iodata() |> IO.iodata_to_binary()}
    end
  rescue
    # Tokenizer/compile errors carry file, line:column, and a caret —
    # hand the whole story to the caller instead of crashing the build.
    error -> {:error, Exception.message(error)}
  end

  defp imports_env(component_modules) do
    imports =
      for mod <- [Cherry.Theme.Helpers, Phoenix.Component, Phoenix.HTML] ++ component_modules do
        exports =
          mod.module_info(:exports)
          |> Enum.reject(fn {name, _arity} ->
            name in [:module_info, :__info__, :__components__] or
              String.starts_with?(Atom.to_string(name), "MACRO-")
          end)
          |> Enum.sort()

        {mod, exports}
      end

    env = env_stub()
    %{env | functions: imports ++ env.functions}
  end

  defp env_stub, do: __ENV__

  @doc """
  Renders a content template and wraps it in the theme's `layout`.

  The context carries the layout's own assigns: page title, the
  framework-owned SEO head block (`Cherry.SEO.Head`, interpolated
  verbatim inside `<head>`), and the navigation.
  """
  @spec render_in_layout(RenderContext.t(), atom(), keyword()) ::
          {:ok, String.t()} | {:error, String.t()}
  def render_in_layout(%RenderContext{site: site, theme: theme} = context, name, assigns) do
    with {:ok, inner} <- render(site, theme, name, assigns) do
      render(site, theme, :layout,
        site: site,
        inner: inner,
        page_title: context.page_title,
        head_extra: context.head_extra,
        nav: context.nav,
        search: context.search,
        page_class: context.page_class
      )
    end
  end
end
