defmodule CeecWeb.SurveyLive.Analytics do
  use CeecWeb, :live_view

  alias Ceec.Surveys

  @impl true
  def mount(%{"id" => survey_id}, _session, socket) do
    survey = Surveys.get_survey!(survey_id)
    analytics = Surveys.get_loan_assessment_analytics(survey_id)
    
    socket = 
      socket
      |> assign(:survey, survey)
      |> assign(:analytics, analytics)
      |> assign(:page_title, "Survey Analytics - #{survey.title}")

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp format_challenge({challenge, count}, total_responses) do
    %{
      name: challenge || "Other",
      count: count,
      percentage: if(total_responses > 0, 
        do: Float.round(count / total_responses * 100, 1), 
        else: 0)
    }
  end

  defp format_loan_usage(usage_map) do
    total = Enum.sum(Map.values(usage_map))
    
    usage_map
    |> Enum.map(fn {usage, count} ->
      %{
        name: usage || "Other",
        count: count,
        percentage: if(total > 0, do: Float.round(count / total * 100, 1), else: 0)
      }
    end)
    |> Enum.sort_by(& &1.count, :desc)
  end
end