defmodule CeecWeb.LoanApplicationController do
  use CeecWeb, :controller
  
  alias Ceec.Finance

  def new(conn, _params) do
    # Get available loan types from existing loans in the system
    available_loan_types = Ceec.Finance.get_available_loan_types()
    
    # Get active projects that can accept loan applications
    available_projects = Ceec.Projects.list_active_projects()
    
    render(conn, :new, 
      available_loan_types: available_loan_types,
      available_projects: available_projects
    )
  end

  def create(conn, %{"loan_application" => loan_params}) do
    case Finance.create_loan(loan_params) do
      {:ok, loan} ->
        conn
        |> put_flash(:info, "Loan application submitted successfully! Your application ID is: #{loan.id}")
        |> redirect(to: ~p"/loans/status")
      
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Please check the form for errors")
        |> render(:new, changeset: changeset)
    end
  end

  def status(conn, _params) do
    render(conn, :status)
  end

  def check_status(conn, %{"loan_id" => loan_id}) when loan_id != "" do
    case Finance.get_loan(loan_id) do
      nil ->
        conn
        |> put_flash(:error, "Loan application not found")
        |> render(:status)
      
      loan ->
        render(conn, :status, loan: loan)
    end
  end

  def check_status(conn, _params) do
    conn
    |> put_flash(:error, "Please enter a loan application ID")
    |> render(:status)
  end
end