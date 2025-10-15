defmodule CeecWeb.VisitController do
  use CeecWeb, :controller

  alias Ceec.MeData
  alias Ceec.MeData.Visit

  def index(conn, _params) do
    visits = MeData.list_visits()
    render(conn, :index, visits: visits)
  end

  def new(conn, _params) do
    changeset = MeData.change_visit(%Visit{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"visit" => visit_params}) do
    case MeData.create_visit(visit_params) do
      {:ok, visit} ->
        conn
        |> put_flash(:info, "Visit created successfully.")
        |> redirect(to: ~p"/visits/#{visit}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    visit = MeData.get_visit!(id)
    render(conn, :show, visit: visit)
  end

  def edit(conn, %{"id" => id}) do
    visit = MeData.get_visit!(id)
    changeset = MeData.change_visit(visit)
    render(conn, :edit, visit: visit, changeset: changeset)
  end

  def update(conn, %{"id" => id, "visit" => visit_params}) do
    visit = MeData.get_visit!(id)

    case MeData.update_visit(visit, visit_params) do
      {:ok, visit} ->
        conn
        |> put_flash(:info, "Visit updated successfully.")
        |> redirect(to: ~p"/visits/#{visit}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, visit: visit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    visit = MeData.get_visit!(id)
    {:ok, _visit} = MeData.delete_visit(visit)

    conn
    |> put_flash(:info, "Visit deleted successfully.")
    |> redirect(to: ~p"/visits")
  end
end
