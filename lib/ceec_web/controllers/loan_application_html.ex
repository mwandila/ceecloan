defmodule CeecWeb.LoanApplicationHTML do
  @moduledoc """
  This module contains pages rendered by LoanApplicationController.

  See the `loan_application_html` directory for all templates available.
  """
  use CeecWeb, :html

  embed_templates "loan_application_html/*"
end