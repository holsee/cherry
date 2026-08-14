defmodule Cherry.CV.Settings do
  @moduledoc """
  CV publication settings from `portfolio.yaml` (DESIGN.md §4).

  Visibility is the static-site take on discretion: `:public` is linked
  everywhere; `:unlisted` builds the page but keeps it out of nav and
  sitemap with `noindex` — share the URL without announcing a job hunt;
  `:off` emits nothing.
  """

  defstruct visibility: :public

  @type visibility :: :public | :unlisted | :off
  @type t :: %__MODULE__{visibility: visibility()}

  @doc "Validates the `cv:` block of portfolio.yaml."
  @spec validate(term()) :: {:ok, t()} | {:error, String.t()}
  def validate(%{} = value) do
    Enum.reduce_while(value, {:ok, %__MODULE__{}}, fn
      {"visibility", visibility}, {:ok, %__MODULE__{} = acc} ->
        case visibility do
          "public" ->
            {:cont, {:ok, %__MODULE__{acc | visibility: :public}}}

          "unlisted" ->
            {:cont, {:ok, %__MODULE__{acc | visibility: :unlisted}}}

          "off" ->
            {:cont, {:ok, %__MODULE__{acc | visibility: :off}}}

          other ->
            {:halt,
             {:error, "cv.visibility must be public | unlisted | off, got: #{inspect(other)}"}}
        end

      {key, _value}, {:ok, _acc} ->
        {:halt, {:error, "unknown cv key #{inspect(key)} (visibility)"}}
    end)
  end

  def validate(value), do: {:error, "expected a cv map, got: #{inspect(value)}"}
end
