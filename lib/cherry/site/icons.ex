defmodule Cherry.Site.Icons do
  @moduledoc """
  The site's icon set, detected by convention from `static/` — no config
  key to fall out of sync with the files on disk.

  Reserved names at the static root:

    * `favicon.ico` — classic multi-size icon (`rel="icon"`)
    * `favicon.svg` — scalable icon (`rel="icon" type="image/svg+xml"`)
    * `apple-touch-icon.png` — 180×180 home-screen icon

  Whatever exists gets a `<link>` in every page's head via
  `Cherry.SEO.Head`, base-path aware, in every theme.
  """

  defstruct favicon: nil, svg: nil, apple_touch: nil

  @type t :: %__MODULE__{
          favicon: String.t() | nil,
          svg: String.t() | nil,
          apple_touch: String.t() | nil
        }

  @doc "Detects reserved icon files under `root/static`."
  @spec detect(Path.t()) :: t()
  def detect(root) do
    %__MODULE__{
      favicon: present(root, "favicon.ico"),
      svg: present(root, "favicon.svg"),
      apple_touch: present(root, "apple-touch-icon.png")
    }
  end

  defp present(root, name) do
    if File.regular?(Path.join([root, "static", name])), do: name
  end
end
