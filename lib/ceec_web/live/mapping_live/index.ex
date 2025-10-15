defmodule CeecWeb.MappingLive.Index do
  use CeecWeb, :live_view

  alias Ceec.Finance
  alias Ceec.Projects

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:search, "")
      |> assign(:filter_status, "all")
      |> load_data()
    
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Loan-Project Mappings")
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    socket = 
      socket
      |> assign(:search, search)
      |> load_data()
    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    socket = 
      socket
      |> assign(:filter_status, status)
      |> load_data()
    {:noreply, socket}
  end

  @impl true
  def handle_event("map_loan", %{"loan_id" => loan_id, "project_id" => project_id}, socket) do
    loan = Finance.get_loan!(loan_id)
    project = Projects.get_project!(project_id)
    
    case Finance.update_loan(loan, %{project_id: project_id, project_name: project.name}) do
      {:ok, _updated_loan} ->
        socket = 
          socket
          |> put_flash(:info, "Loan #{loan.loan_id} successfully mapped to #{project.name}")
          |> assign(:mapping_loan, nil)
          |> load_data()
        {:noreply, socket}
      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to update loan mapping")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("unmap_loan", %{"loan_id" => loan_id}, socket) do
    loan = Finance.get_loan!(loan_id)
    
    case Finance.update_loan(loan, %{project_id: nil}) do
      {:ok, _updated_loan} ->
        socket = 
          socket
          |> put_flash(:info, "Loan #{loan.loan_id} unmapped successfully")
          |> load_data()
        {:noreply, socket}
      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to unmap loan")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_mapping_modal", %{"loan_id" => loan_id}, socket) do
    loan = Finance.get_loan!(loan_id)
    {:noreply, assign(socket, :mapping_loan, loan)}
  end

  @impl true
  def handle_event("hide_mapping_modal", _params, socket) do
    {:noreply, assign(socket, :mapping_loan, nil)}
  end


  defp load_data(socket) do
    loans = Finance.list_loans()
    projects = Projects.list_projects()
    
    # Apply filters
    filtered_loans = case socket.assigns.filter_status do
      "mapped" -> Enum.filter(loans, &(&1.project_id != nil))
      "unmapped" -> Enum.filter(loans, &(is_nil(&1.project_id)))
      _ -> loans
    end
    
    # Apply search
    filtered_loans = if socket.assigns.search != "" do
      search_term = String.downcase(socket.assigns.search)
      Enum.filter(filtered_loans, fn loan ->
        String.contains?(String.downcase(loan.loan_id), search_term) or
        String.contains?(String.downcase(loan.project_name || ""), search_term) or
        String.contains?(String.downcase(loan.loan_type || ""), search_term)
      end)
    else
      filtered_loans
    end
    
    # Get mapping statistics
    total_loans = length(loans)
    mapped_loans = Enum.count(loans, &(&1.project_id != nil))
    unmapped_loans = total_loans - mapped_loans
    
    socket
    |> assign(:loans, filtered_loans)
    |> assign(:projects, projects)
    |> assign(:active_projects, Enum.filter(projects, &(&1.status in ["In Progress", "active"])))
    |> assign(:mapping_loan, nil)
    |> assign(:stats, %{
      total: total_loans,
      mapped: mapped_loans,
      unmapped: unmapped_loans,
      mapping_rate: if(total_loans > 0, do: Float.round(mapped_loans / total_loans * 100, 1), else: 0)
    })
  end
  
  def get_project_options_for_loan(loan, projects) do
    if loan.loan_type do
      # Get projects that match the loan type
      matching_projects = Projects.list_projects_for_loan_type(loan.loan_type)
      # Also include other active projects as options
      active_projects = Enum.filter(projects, &(&1.status in ["In Progress", "active"]))
      
      # Combine and deduplicate
      (matching_projects ++ active_projects)
      |> Enum.uniq_by(& &1.id)
      |> Enum.sort_by(& &1.name)
    else
      # If no loan type, show all active projects
      Enum.filter(projects, &(&1.status in ["In Progress", "active"]))
      |> Enum.sort_by(& &1.name)
    end
  end
end