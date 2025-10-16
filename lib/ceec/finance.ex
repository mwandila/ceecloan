defmodule Ceec.Finance do
  @moduledoc """
  The Finance context.
  """

  import Ecto.Query, warn: false
  alias Ceec.Repo

  alias Ceec.Finance.Loan

  @doc """
  Returns the list of loans.

  ## Examples

      iex> list_loans()
      [%Loan{}, ...]

  """
  def list_loans do
    Repo.all(Loan)
    |> Repo.preload([:project])
  end

  @doc """
  Gets a single loan.

  Raises `Ecto.NoResultsError` if the Loan does not exist.

  ## Examples

      iex> get_loan!(123)
      %Loan{}

      iex> get_loan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_loan!(id), do: Repo.get!(Loan, id)

  @doc """
  Gets a single loan.

  Returns `nil` if the Loan does not exist.

  ## Examples

      iex> get_loan(123)
      %Loan{}

      iex> get_loan(456)
      nil

  """
  def get_loan(id), do: Repo.get(Loan, id)

  @doc """
  Gets a single loan by application ID.

  Returns `nil` if the Loan does not exist.

  ## Examples

      iex> get_loan_by_application_id("CEEC-2024-001")
      %Loan{}

      iex> get_loan_by_application_id("INVALID-ID")
      nil

  """
  def get_loan_by_application_id(application_id) do
    # Convert application_id string to integer for database lookup
    case Integer.parse(application_id) do
      {id, ""} ->
        from(l in Loan,
          where: l.id == ^id,
          preload: [:borrower, :project]
        )
        |> Repo.one()
      _ ->
        nil
    end
  end

  @doc """
  Creates a loan.

  ## Examples

      iex> create_loan(%{field: value})
      {:ok, %Loan{}}

      iex> create_loan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_loan(attrs \\ %{}) do
    attrs_with_project = maybe_map_to_project(attrs)
    
    %Loan{}
    |> Loan.changeset(attrs_with_project)
    |> Repo.insert()
  end
  
  @doc """
  Creates a loan and automatically maps it to a project based on loan type.
  """
  def create_loan_with_project_mapping(attrs \\ %{}) do
    attrs_with_project = maybe_map_to_project(attrs)
    
    %Loan{}
    |> Loan.changeset(attrs_with_project)
    |> Repo.insert()
  end

  @doc """
  Updates a loan.

  ## Examples

      iex> update_loan(loan, %{field: new_value})
      {:ok, %Loan{}}

      iex> update_loan(loan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loan(%Loan{} = loan, attrs) do
    loan
    |> Loan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loan.

  ## Examples

      iex> delete_loan(loan)
      {:ok, %Loan{}}

      iex> delete_loan(loan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_loan(%Loan{} = loan) do
    Repo.delete(loan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loan changes.

  ## Examples

      iex> change_loan(loan)
      %Ecto.Changeset{data: %Loan{}}

  """
  def change_loan(%Loan{} = loan, attrs \\ %{}) do
    Loan.changeset(loan, attrs)
  end
  
  @doc """
  Updates loan status (for approval, rejection, disbursement)
  """
  def update_loan_status(%Loan{} = loan, attrs) do
    loan
    |> Loan.status_changeset(attrs)
    |> Repo.update()
  end
  
  @doc """
  Returns loans associated with a specific project.
  """
  def list_loans_for_project(project_id) do
    from(l in Loan, where: l.project_id == ^project_id)
    |> Repo.all()
    |> Repo.preload([:project])
  end
  
  @doc """
  Returns loans by loan type.
  """
  def list_loans_by_type(loan_type) do
    from(l in Loan, where: l.loan_type == ^loan_type)
    |> Repo.all()
    |> Repo.preload([:project])
  end
  
  @doc """
  Returns loans by status.
  """
  def list_loans_by_status(status) do
    from(l in Loan, where: l.status == ^status, order_by: [desc: l.inserted_at])
    |> Repo.all()
    |> Repo.preload([:project])
  end
  
  # Private helper function to automatically map loans to projects
  defp maybe_map_to_project(attrs) do
    case attrs[:loan_type] do
      loan_type when is_binary(loan_type) ->
        case find_matching_project(loan_type) do
          nil -> 
            attrs
          project -> 
            attrs
            |> Map.put(:project_id, project.id)
            |> Map.put(:project_name, project.name)
        end
      _ -> 
        attrs
    end
  end
  
  @doc """
  Gets available loan types from the system configuration and existing projects.
  """
  def get_available_loan_types do
    # Get loan types that have matching active projects
    project_types = from(p in Ceec.Projects.Project,
      where: p.status in ["active", "In Progress"],
      select: p.project_type,
      distinct: true
    )
    |> Repo.all()
    
    # Map project types to loan types
    project_type_to_loan_type = %{
      "Microfinance" => "Microfinance",
      "Agriculture" => "Agricultural", 
      "Housing" => "Housing",
      "Education" => "Education",
      "Health" => "Health",
      "Infrastructure" => "Infrastructure",
      "Energy" => "Energy"
    }
    
    # Return loan types that have matching projects
    project_types
    |> Enum.map(&Map.get(project_type_to_loan_type, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
  end
  
  # Find a project that matches the loan type
  defp find_matching_project(loan_type) do
    # Map loan types to project types
    project_type_mapping = %{
      "Microfinance" => "Microfinance",
      "Agricultural" => "Agriculture", 
      "Housing" => "Housing",
      "Education" => "Education",
      "Health" => "Health",
      "Infrastructure" => "Infrastructure",
      "Energy" => "Energy",
      "SME Loan" => "Microfinance" # SME loans often go to microfinance projects
    }
    
    project_type = Map.get(project_type_mapping, loan_type)
    
    if project_type do
      # Find an active project of matching type
      from(p in Ceec.Projects.Project, 
        where: p.project_type == ^project_type and p.status in ["In Progress", "active"],
        limit: 1
      )
      |> Repo.one()
    else
      nil
    end
  end
end
