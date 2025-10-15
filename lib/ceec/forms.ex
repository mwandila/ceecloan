defmodule Ceec.Forms do
  @moduledoc """
  The Forms context.
  """

  import Ecto.Query, warn: false
  alias Ceec.Repo

  alias Ceec.Forms.Form

  @doc """
  Returns the list of forms.

  ## Examples

      iex> list_forms()
      [%Form{}, ...]

  """
  def list_forms do
    Repo.all(Form)
    |> Repo.preload(:project)
  end

  @doc """
  Gets a single form.

  Raises `Ecto.NoResultsError` if the Form does not exist.

  ## Examples

      iex> get_form!(123)
      %Form{}

      iex> get_form!(456)
      ** (Ecto.NoResultsError)

  """
  def get_form!(id) do
    Repo.get!(Form, id)
    |> Repo.preload(:project)
  end

  @doc """
  Creates a form.

  ## Examples

      iex> create_form(%{field: value})
      {:ok, %Form{}}

      iex> create_form(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_form(attrs \\ %{}) do
    %Form{}
    |> Form.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a form.

  ## Examples

      iex> update_form(form, %{field: new_value})
      {:ok, %Form{}}

      iex> update_form(form, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_form(%Form{} = form, attrs) do
    form
    |> Form.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a form.

  ## Examples

      iex> delete_form(form)
      {:ok, %Form{}}

      iex> delete_form(form)
      {:error, %Ecto.Changeset{}}

  """
  def delete_form(%Form{} = form) do
    Repo.delete(form)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking form changes.

  ## Examples

      iex> change_form(form)
      %Ecto.Changeset{data: %Form{}}

  """
  def change_form(%Form{} = form, attrs \\ %{}) do
    Form.changeset(form, attrs)
  end

  @doc """
  Lists forms by project.
  """
  def list_forms_by_project(project_id) do
    from(f in Form, where: f.project_id == ^project_id)
    |> Repo.all()
    |> Repo.preload(:project)
  end

  @doc """
  Lists forms by form type.
  """
  def list_forms_by_type(form_type) do
    from(f in Form, where: f.form_type == ^form_type)
    |> Repo.all()
    |> Repo.preload(:project)
  end

  @doc """
  Lists published forms.
  """
  def list_published_forms do
    from(f in Form, where: f.status == "published")
    |> Repo.all()
    |> Repo.preload(:project)
  end

  @doc """
  Creates a form with default schema based on form type.
  """
  def create_form_with_default_schema(attrs) do
    form_type = Map.get(attrs, "form_type", "survey")
    default_schema = Form.default_schema(form_type)
    
    attrs_with_schema = Map.put(attrs, "form_schema", default_schema)
    
    create_form(attrs_with_schema)
  end
end