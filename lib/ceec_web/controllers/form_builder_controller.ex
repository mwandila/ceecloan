defmodule CeecWeb.FormBuilderController do
  use CeecWeb, :controller

  alias Ceec.Forms
  alias Ceec.Forms.Form
  alias Ceec.Projects

  def index(conn, _params) do
    forms = Forms.list_forms()
    render(conn, :index, forms: forms)
  end

  def show(conn, %{"id" => id}) do
    form = Forms.get_form!(id)
    render(conn, :show, form: form)
  end

  def new(conn, _params) do
    changeset = Forms.change_form(%Form{})
    projects = Projects.list_projects()
    render(conn, :new, changeset: changeset, projects: projects)
  end

  def create(conn, %{"form" => form_params}) do
    case Forms.create_form_with_default_schema(form_params) do
      {:ok, form} ->
        conn
        |> put_flash(:info, "Form created successfully.")
        |> redirect(to: ~p"/form-builder/#{form}")

      {:error, %Ecto.Changeset{} = changeset} ->
        projects = Projects.list_projects()
        render(conn, :new, changeset: changeset, projects: projects)
    end
  end

  def edit(conn, %{"id" => id}) do
    form = Forms.get_form!(id)
    changeset = Forms.change_form(form)
    projects = Projects.list_projects()
    render(conn, :edit, form: form, changeset: changeset, projects: projects)
  end

  def update(conn, %{"id" => id, "form" => form_params}) do
    form = Forms.get_form!(id)

    case Forms.update_form(form, form_params) do
      {:ok, form} ->
        conn
        |> put_flash(:info, "Form updated successfully.")
        |> redirect(to: ~p"/form-builder/#{form}")

      {:error, %Ecto.Changeset{} = changeset} ->
        projects = Projects.list_projects()
        render(conn, :edit, form: form, changeset: changeset, projects: projects)
    end
  end

  def delete(conn, %{"id" => id}) do
    form = Forms.get_form!(id)
    {:ok, _form} = Forms.delete_form(form)

    conn
    |> put_flash(:info, "Form deleted successfully.")
    |> redirect(to: ~p"/form-builder")
  end

  def builder(conn, %{"id" => id}) do
    form = Forms.get_form!(id)
    render(conn, :builder, form: form)
  end

  def update_schema(conn, %{"id" => id, "form_schema" => schema_params}) do
    form = Forms.get_form!(id)

    case Forms.update_form(form, %{"form_schema" => schema_params}) do
      {:ok, _updated_form} ->
        conn
        |> put_flash(:info, "Form schema updated successfully.")
        |> json(%{success: true, message: "Form saved successfully"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, errors: changeset.errors})
    end
  end

  def preview(conn, %{"id" => id}) do
    form = Forms.get_form!(id)
    render(conn, :preview, form: form)
  end
end