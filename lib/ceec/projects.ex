defmodule Ceec.Projects do
  @moduledoc """
  The Projects context for M&E system.
  Handles projects and beneficiaries management.
  """

  import Ecto.Query, warn: false
  alias Ceec.Repo

  alias Ceec.Projects.Project

  ## Projects

  @doc """
  Returns the list of projects.
  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Returns paginated list of projects.
  """
  def list_projects_paginated(page \\ 1, per_page \\ 10, filters \\ %{}) do
    offset = (page - 1) * per_page
    
    query = from(p in Project)
    
    # Apply filters
    query = if filters[:search] && filters[:search] != "" do
      search_term = "%#{filters[:search]}%"
      from(p in query, where: ilike(p.name, ^search_term) or ilike(p.project_id, ^search_term))
    else
      query
    end
    
    query = if filters[:status] && filters[:status] != "" && filters[:status] != "All" do
      from(p in query, where: p.status == ^filters[:status])
    else
      query
    end
    
    # Apply sorting
    query = case filters[:sort_by] do
      "Name" -> from(p in query, order_by: [asc: p.name])
      "Status" -> from(p in query, order_by: [asc: p.status, asc: p.name])
      "Progress" -> from(p in query, order_by: [desc: p.progress, asc: p.name])
      "Start Date" -> from(p in query, order_by: [desc: p.start_date, asc: p.name])
      _ -> from(p in query, order_by: [asc: p.name])
    end
    
    # Get total count for pagination
    total_count = Repo.aggregate(query, :count)
    total_pages = ceil(total_count / per_page)
    
    # Get paginated results
    projects = query
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
    
    %{
      projects: projects,
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      has_prev: page > 1,
      has_next: page < total_pages
    }
  end

  @doc """
  Returns the list of active projects.
  """
  def list_active_projects do
    from(p in Project, where: p.status in ["active", "planning"])
    |> Repo.all()
  end

  @doc """
  Gets the total count of projects.
  """
  def get_total_projects_count do
    from(p in Project, select: count(p.id))
    |> Repo.one()
  end

  @doc """
  Gets the count of active projects.
  """
  def get_active_projects_count do
    from(p in Project, where: p.status in ["active", "planning"], select: count(p.id))
    |> Repo.one()
  end

  @doc """
  Gets the total count of beneficiaries across all projects.
  """
  def get_total_beneficiaries_count do
    # Return 0 for now - can be implemented when beneficiary associations are added
    0
  end

  @doc """
  Gets a single project.
  """
  def get_project!(id) do
    Repo.get!(Project, id)
  end

  @doc """
  Gets a project by project code.
  """
  def get_project_by_code(code) do
    Repo.get_by(Project, project_code: code)
    |> case do
      nil -> {:error, :not_found}
      project -> {:ok, project}
    end
  end

  @doc """
  Creates a project.
  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.
  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.
  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.
  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Gets project statistics.
  """
  def get_project_stats(project_id) do
    project = get_project!(project_id)
    
    # Calculate project progress based on dates or use stored progress
    progress_percentage = project.progress || calculate_project_progress(project)
    
    %{
      progress_percentage: progress_percentage,
      days_remaining: days_until_end(project.end_date),
      status: project.status,
      budget: project.budget
    }
  end

  defp calculate_project_progress(%Project{start_date: start_date, end_date: end_date}) 
       when not is_nil(start_date) and not is_nil(end_date) do
    today = Date.utc_today()
    total_days = Date.diff(end_date, start_date)
    elapsed_days = Date.diff(today, start_date)
    
    cond do
      elapsed_days <= 0 -> 0
      elapsed_days >= total_days -> 100
      true -> Float.round(elapsed_days / total_days * 100, 1)
    end
  end
  defp calculate_project_progress(_), do: 0

  defp days_until_end(nil), do: nil
  defp days_until_end(end_date) do
    Date.diff(end_date, Date.utc_today())
  end
  
  @doc """
  Gets loans associated with a project.
  """
  def get_project_loans(project_id) do
    Ceec.Finance.list_loans_for_project(project_id)
  end
  
  @doc """
  Gets project with preloaded loans.
  """
  def get_project_with_loans!(id) do
    get_project!(id)
    |> Repo.preload([:loans])
  end
  
  @doc """
  Returns projects that can accept loans of a specific type.
  """
  def list_projects_for_loan_type(loan_type) do
    # Map loan types to project types
    project_type_mapping = %{
      "Microfinance" => "Microfinance",
      "Agricultural" => "Agriculture", 
      "Housing" => "Housing",
      "Education" => "Education",
      "Health" => "Health",
      "Infrastructure" => "Infrastructure",
      "Energy" => "Energy",
      "SME Loan" => "Microfinance"
    }
    
    project_type = Map.get(project_type_mapping, loan_type)
    
    if project_type do
      from(p in Project, 
        where: p.project_type == ^project_type and p.status in ["In Progress", "active"]
      )
      |> Repo.all()
    else
      []
    end
  end
end
