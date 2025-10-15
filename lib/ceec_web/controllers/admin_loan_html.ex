defmodule CeecWeb.AdminLoanHTML do
  @moduledoc """
  This module contains pages rendered by AdminLoanController.

  See the `admin_loan_html` directory for all templates available.
  """
  use CeecWeb, :html

  embed_templates "admin_loan_html/*"
end