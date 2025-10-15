defmodule CeecWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use CeecWeb, :controller` and
  `use CeecWeb, :live_view`.
  """
  use CeecWeb, :html
  import CeecWeb.Components.Sidebar

  embed_templates "layouts/*"
end
