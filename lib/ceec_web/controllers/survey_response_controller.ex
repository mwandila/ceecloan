defmodule CeecWeb.SurveyResponseController do
  use CeecWeb, :controller

  alias Ceec.Surveys
  alias Ceec.Surveys.SurveyResponse

  def index(conn, params) do
    # Get filtering parameters
    search = Map.get(params, "search", "")
    status_filter = Map.get(params, "status", "all")
    date_from = Map.get(params, "date_from", "")
    date_to = Map.get(params, "date_to", "")
    
    # Get survey responses with filters
    survey_responses = Surveys.list_survey_responses_with_filters(%{
      search: search,
      status: status_filter,
      date_from: date_from,
      date_to: date_to
    })
    
    # Get some statistics
    stats = Surveys.get_survey_responses_stats()
    
    render(conn, :index, 
      survey_responses: survey_responses,
      stats: stats,
      search: search,
      status_filter: status_filter,
      date_from: date_from,
      date_to: date_to
    )
  end

  def new(conn, %{"survey_id" => survey_id}) do
    case Surveys.get_survey(survey_id) do
      nil ->
        conn
        |> put_flash(:error, "Survey not found.")
        |> redirect(to: ~p"/surveys")
      survey ->
        render(conn, :new, survey: survey)
    end
  end

  def create(conn, %{"survey_response" => survey_response_params, "survey_id" => survey_id}) do
    survey_response_params = Map.put(survey_response_params, "survey_id", survey_id)
    
    # Handle social_distribution array if present
    survey_response_params = case Map.get(survey_response_params, "social_distribution") do
      nil -> survey_response_params
      distribution when is_list(distribution) -> 
        Map.put(survey_response_params, "social_distribution", distribution)
      _ -> survey_response_params
    end
    
    case Surveys.create_survey_response(survey_response_params) do
      {:ok, _survey_response} ->
        conn
        |> put_flash(:info, "Data collection form submitted successfully. Thank you for your participation!")
        |> redirect(to: ~p"/surveys/#{survey_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        survey = Surveys.get_survey!(survey_id)
        render(conn, :new, survey: survey, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    survey_response = Surveys.get_survey_response!(id)
    survey = Surveys.get_survey!(survey_response.survey_id)
    render(conn, :show, survey_response: survey_response, survey: survey)
  end

  def edit(conn, %{"id" => id}) do
    survey_response = Surveys.get_survey_response!(id)
    survey = Surveys.get_survey!(survey_response.survey_id)
    changeset = Surveys.change_survey_response(survey_response)
    render(conn, :edit, survey_response: survey_response, survey: survey, changeset: changeset)
  end

  def update(conn, %{"id" => id, "survey_response" => survey_response_params}) do
    survey_response = Surveys.get_survey_response!(id)

    case Surveys.update_survey_response(survey_response, survey_response_params) do
      {:ok, survey_response} ->
        conn
        |> put_flash(:info, "Survey response updated successfully.")
        |> redirect(to: ~p"/surveys/#{survey_response.survey_id}/responses/#{survey_response}")

      {:error, %Ecto.Changeset{} = changeset} ->
        survey = Surveys.get_survey!(survey_response.survey_id)
        render(conn, :edit, survey_response: survey_response, survey: survey, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    survey_response = Surveys.get_survey_response!(id)
    survey_id = survey_response.survey_id
    {:ok, _survey_response} = Surveys.delete_survey_response(survey_response)

    conn
    |> put_flash(:info, "Survey response deleted successfully.")
    |> redirect(to: ~p"/surveys/#{survey_id}")
  end
end