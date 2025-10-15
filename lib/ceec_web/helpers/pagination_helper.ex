defmodule CeecWeb.Helpers.PaginationHelper do
  @moduledoc """
  Helper functions for pagination.
  """

  @doc """
  Generate a range of page numbers for pagination display.
  Shows up to 5 page numbers centered around the current page.
  """
  def pagination_range(%{page: current_page, total_pages: total_pages}) do
    start_page = max(1, current_page - 2)
    end_page = min(total_pages, current_page + 2)
    
    start_page..end_page |> Enum.to_list()
  end
end