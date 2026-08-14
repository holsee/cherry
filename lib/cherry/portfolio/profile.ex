defmodule Cherry.Portfolio.Profile do
  @moduledoc """
  The person behind the portfolio: `portfolio.yaml` at the site root.

  Holds identity for the timeline, CV, and `Person` JSON-LD — name (or
  handle), headline, location, links, avatar. Contact email is off by
  default (spam harvesting on public static pages is real); adding
  `email:` is the opt-in. No `portfolio.yaml` → no portfolio views.
  """

  alias Cherry.Collections.{Schema, Types}

  @file_name "portfolio.yaml"

  @schema [
    name: [type: :string, required: true, doc: "Display name or handle."],
    headline: [type: :string, doc: "One-line professional summary."],
    location: [type: :string, doc: "City / country / remote — free text."],
    links: [
      type: {:custom, Types, :validate_links, []},
      default: [],
      doc: "Profile links as `- {label: GitHub, url: https://…}`."
    ],
    avatar: [type: :string, doc: "Site-relative avatar path, e.g. `images/avatar.png`."],
    email: [type: :string, doc: "Contact email — published only when present (opt-in)."],
    updated: [
      type: {:custom, Types, :validate_date, []},
      doc: "Explicit freshness date; defaults to the newest portfolio entry."
    ],
    cv: [
      type: {:custom, Cherry.CV.Settings, :validate, []},
      doc: "CV publication settings: `{visibility: public | unlisted | off}`."
    ]
  ]

  @enforce_keys [:name]
  defstruct [
    :name,
    :headline,
    :location,
    :avatar,
    :email,
    :updated,
    links: [],
    cv: %Cherry.CV.Settings{}
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          headline: String.t() | nil,
          location: String.t() | nil,
          links: [Cherry.Portfolio.Link.t()],
          avatar: String.t() | nil,
          email: String.t() | nil,
          updated: Date.t() | nil,
          cv: Cherry.CV.Settings.t()
        }

  @doc "The profile schema, for introspection and docs."
  @spec schema() :: keyword()
  def schema, do: @schema

  @doc """
  Loads `portfolio.yaml` from the site root.

  Returns `{:ok, nil}` when the file does not exist — the portfolio is
  simply absent, which is not an error.
  """
  @spec load(Path.t()) :: {:ok, t() | nil} | {:error, String.t()}
  def load(root) do
    path = Path.join(root, @file_name)

    if File.exists?(path) do
      parse(File.read!(path))
    else
      {:ok, nil}
    end
  end

  defp parse(content) do
    case YamlElixir.read_from_string(content) do
      {:ok, map} when is_map(map) ->
        with {:ok, meta} <- Schema.validate(map, @schema, @file_name) do
          {:ok, struct!(__MODULE__, meta)}
        end

      {:ok, _other} ->
        {:error, "#{@file_name} must be a YAML mapping"}

      {:error, error} ->
        {:error, "#{@file_name}: #{Exception.message(error)}"}
    end
  end
end
