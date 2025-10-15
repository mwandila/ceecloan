defmodule CeecWeb.SurveyController do
  use CeecWeb, :controller

  alias Ceec.Surveys
  alias Ceec.Surveys.Survey

  def index(conn, _params) do
    surveys = Surveys.list_surveys()
    render(conn, :index, surveys: surveys)
  end

  def show(conn, %{"id" => id}) do
    survey = Surveys.get_survey!(id)
    stats = Surveys.get_survey_stats(id)
    responses = Surveys.list_survey_responses(id)
    render(conn, :show, survey: survey, stats: stats, responses: responses)
  end

  def new(conn, _params) do
    changeset = Surveys.change_survey(%Survey{})
    render(conn, :new, changeset: changeset)
  end
  
  def redirect_to_builder(conn, _params) do
    redirect(conn, to: ~p"/surveys/builder/new")
  end

  def create(conn, %{"survey" => survey_params}) do
    case Surveys.create_survey(survey_params) do
      {:ok, survey} ->
        conn
        |> put_flash(:info, "Survey created successfully.")
        |> redirect(to: ~p"/surveys/#{survey}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    survey = Surveys.get_survey!(id)
    changeset = Surveys.change_survey(survey)
    render(conn, :edit, survey: survey, changeset: changeset)
  end

  def update(conn, %{"id" => id, "survey" => survey_params}) do
    survey = Surveys.get_survey!(id)

    case Surveys.update_survey(survey, survey_params) do
      {:ok, survey} ->
        conn
        |> put_flash(:info, "Survey updated successfully.")
        |> redirect(to: ~p"/surveys/#{survey}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, survey: survey, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    survey = Surveys.get_survey!(id)
    {:ok, _survey} = Surveys.delete_survey(survey)

    conn
    |> put_flash(:info, "Survey deleted successfully.")
    |> redirect(to: ~p"/surveys")
  end
end