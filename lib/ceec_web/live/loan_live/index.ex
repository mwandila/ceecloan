defmodule CeecWeb.LoanLive.Index do
  use CeecWeb, :live_view

  alias Ceec.Finance
  alias Ceec.Finance.Loan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :loans, Finance.list_loans())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Loan")
    |> assign(:loan, Finance.get_loan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Loan")
    |> assign(:loan, %Loan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Loans")
    |> assign(:loan, nil)
  end

  @impl true
  def handle_info({CeecWeb.LoanLive.FormComponent, {:saved, loan}}, socket) do
    {:noreply, stream_insert(socket, :loans, loan)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    loan = Finance.get_loan!(id)
    {:ok, _} = Finance.delete_loan(loan)

    {:noreply, stream_delete(socket, :loans, loan)}
  end
end
