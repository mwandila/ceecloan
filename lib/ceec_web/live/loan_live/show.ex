defmodule CeecWeb.LoanLive.Show do
  use CeecWeb, :live_view

  alias Ceec.Finance

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:loan, Finance.get_loan!(id))}
  end

  defp page_title(:show), do: "Show Loan"
  defp page_title(:edit), do: "Edit Loan"
end
