defmodule CeecWeb.AdminLoanController do
  use CeecWeb, :controller

  alias Ceec.Finance

  def index(conn, params) do
    # Get filtering parameters
    status_filter = Map.get(params, "status", "all")
    search = Map.get(params, "search", "")
    
    # Get loans with filtering
    loans = case status_filter do
      "pending" -> Finance.list_loans_by_status("pending")
      "approved" -> Finance.list_loans_by_status("approved")
      "rejected" -> Finance.list_loans_by_status("rejected")
      "disbursed" -> Finance.list_loans_by_status("disbursed")
      _ -> Finance.list_loans()
    end
    
    # Filter by search if provided
    filtered_loans = if search != "" do
      loans |> Enum.filter(fn loan ->
        search_term = String.downcase(search)
        String.contains?(String.downcase(loan.applicant_name || ""), search_term) ||
        String.contains?(String.downcase(loan.business_name || ""), search_term) ||
        String.contains?(String.downcase(loan.first_name || ""), search_term) ||
        String.contains?(String.downcase(loan.last_name || ""), search_term) ||
        String.contains?(String.downcase(loan.created_by || ""), search_term) ||
        String.contains?(String.downcase(loan.project_name || ""), search_term) ||
        String.contains?(String.downcase(to_string(loan.id)), search_term)
      end)
    else
      loans
    end
    
    # Get summary statistics
    stats = %{
      total: length(loans),
      pending: length(Finance.list_loans_by_status("pending")),
      approved: length(Finance.list_loans_by_status("approved")),
      rejected: length(Finance.list_loans_by_status("rejected")),
      disbursed: length(Finance.list_loans_by_status("disbursed"))
    }
    
    render(conn, :index, 
      loans: filtered_loans, 
      stats: stats,
      status_filter: status_filter,
      search: search
    )
  end

  def show(conn, %{"id" => id}) do
    loan = Finance.get_loan!(id) |> Ceec.Repo.preload(:project)
    render(conn, :show, loan: loan)
  end

  def approve(conn, %{"id" => id}) do
    loan = Finance.get_loan!(id) |> Ceec.Repo.preload(:project)
    
    case Finance.update_loan(loan, %{status: "approved"}) do
      {:ok, _loan} ->
        conn
        |> put_flash(:info, "Loan application approved successfully!")
        |> redirect(to: ~p"/admin/loan-applications/#{id}")
      
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to approve loan application")
        |> redirect(to: ~p"/admin/loan-applications/#{id}")
    end
  end

  def reject(conn, %{"id" => id, "admin_loan" => %{"rejection_reason" => reason}}) do
    loan = Finance.get_loan!(id) |> Ceec.Repo.preload(:project)
    
    case Finance.update_loan(loan, %{status: "rejected", rejection_reason: reason}) do
      {:ok, _loan} ->
        conn
        |> put_flash(:info, "Loan application rejected.")
        |> redirect(to: ~p"/admin/loan-applications/#{id}")
      
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to reject loan application")
        |> redirect(to: ~p"/admin/loan-applications/#{id}")
    end
  end

  def reject(conn, %{"id" => id}) do
    # Handle rejection without reason (redirect back to show page)
    conn
    |> put_flash(:error, "Please provide a rejection reason")
    |> redirect(to: ~p"/admin/loan-applications/#{id}")
  end

  def disburse(conn, %{"id" => id}) do
    loan = Finance.get_loan!(id) |> Ceec.Repo.preload(:project)
    
    if loan.status == "approved" do
      case Finance.update_loan(loan, %{status: "disbursed", disbursed_at: DateTime.utc_now()}) do
        {:ok, _loan} ->
          conn
          |> put_flash(:info, "Loan funds marked as disbursed!")
          |> redirect(to: ~p"/admin/loan-applications/#{id}")
        
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Failed to mark loan as disbursed")
          |> redirect(to: ~p"/admin/loan-applications/#{id}")
      end
    else
      conn
      |> put_flash(:error, "Only approved loans can be disbursed")
      |> redirect(to: ~p"/admin/loan-applications/#{id}")
    end
  end

  def edit(conn, %{"id" => id}) do
    loan = Finance.get_loan!(id) |> Ceec.Repo.preload(:project)
    changeset = Finance.change_loan(loan)
    render(conn, :edit, loan: loan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "loan" => loan_params}) do
    loan = Finance.get_loan!(id) |> Ceec.Repo.preload(:project)

    case Finance.update_loan(loan, loan_params) do
      {:ok, loan} ->
        conn
        |> put_flash(:info, "Loan updated successfully.")
        |> redirect(to: ~p"/admin/loan-applications/#{loan.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, loan: loan, changeset: changeset)
    end
  end
end