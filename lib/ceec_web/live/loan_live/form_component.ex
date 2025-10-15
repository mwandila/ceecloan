defmodule CeecWeb.LoanLive.FormComponent do
  use CeecWeb, :live_component

  alias Ceec.{Finance, Accounts}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage loan records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="loan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:loan_id]} type="text" label="Loan ID" />
        <.input field={@form[:loan_type]} type="select" label="Loan Type" prompt="Select loan type" options={[
          {"Microfinance", "Microfinance"},
          {"Agricultural", "Agricultural"},
          {"SME Loan", "SME Loan"},
          {"Housing", "Housing"},
          {"Education", "Education"},
          {"Health", "Health"},
          {"Infrastructure", "Infrastructure"},
          {"Energy", "Energy"}
        ]} />
        <.input field={@form[:project_name]} type="text" label="Project name" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:interest_rate]} type="number" label="Interest rate" step="any" />
        <.input field={@form[:maturity_date]} type="date" label="Maturity date" />
        <.input field={@form[:status]} type="select" label="Status" prompt="Select status" options={[
          {"Active", "Active"},
          {"Pending", "Pending"},
          {"Completed", "Completed"},
          {"Defaulted", "Defaulted"}
        ]} />
        <.input field={@form[:created_by]} type="text" label="Created by" />
        
        <div class="col-span-full">
          <label class="block text-sm font-medium text-gray-700">Borrower (Optional)</label>
          <.input field={@form[:borrower_id]} type="select" prompt="Select borrower (optional)" options={@borrower_options || []} />
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Loan</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{loan: loan} = assigns, socket) do
    borrower_options = list_borrower_options()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:borrower_options, borrower_options)
     |> assign_new(:form, fn ->
       to_form(Finance.change_loan(loan))
     end)}
  end

  defp list_borrower_options do
    # Fetch users to populate borrower select
    Ceec.Accounts.list_users()
    |> Enum.map(fn u -> {u.email, u.id} end)
  end

  @impl true
  def handle_event("validate", %{"loan" => loan_params}, socket) do
    changeset = Finance.change_loan(socket.assigns.loan, loan_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"loan" => loan_params}, socket) do
    save_loan(socket, socket.assigns.action, loan_params)
  end

  defp save_loan(socket, :edit, loan_params) do
    case Finance.update_loan(socket.assigns.loan, loan_params) do
      {:ok, loan} ->
        notify_parent({:saved, loan})

        {:noreply,
         socket
         |> put_flash(:info, "Loan updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_loan(socket, :new, loan_params) do
    case Finance.create_loan(loan_params) do
      {:ok, loan} ->
        notify_parent({:saved, loan})

        {:noreply,
         socket
         |> put_flash(:info, "Loan created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
