defmodule CeecWeb.SurveyResponseLive do
  use CeecWeb, :live_view

  alias Ceec.Surveys
  alias Ceec.Surveys.{SurveyResponse, QuestionResponse}

  @impl true
  def mount(%{"id" => survey_id} = params, _session, socket) do
    survey = Surveys.get_survey!(survey_id)
    questions = Surveys.get_survey_questions(survey_id)
    
    # Get loan information if provided
    loan = case params["loan_id"] do
      nil -> nil
      loan_id -> Ceec.Finance.get_loan(loan_id)
    end
    
    # Check if response already exists for this loan
    existing_response = case loan do
      nil -> nil
      loan -> check_existing_response_for_loan(survey_id, loan.id)
    end
    
    socket = 
      socket
      |> assign(:survey, survey)
      |> assign(:questions, questions)
      |> assign(:loan, loan)
      |> assign(:current_question_index, 0)
      |> assign(:answers, existing_response || %{})
      |> assign(:completed, not is_nil(existing_response))
      |> assign(:page_title, survey.title)
    
    {:ok, socket}
  end

  @impl true
  def handle_event("answer_question", %{"question_index" => index, "answer" => answer}, socket) do
    index = String.to_integer(index)
    updated_answers = Map.put(socket.assigns.answers, index, answer)
    
    {:noreply, assign(socket, :answers, updated_answers)}
  end

  @impl true
  def handle_event("answer_multiple", %{"question_index" => index} = params, socket) do
    index = String.to_integer(index)
    
    # Extract selected options from checkbox form data
    selected_options = 
      params
      |> Enum.filter(fn {k, v} -> String.starts_with?(k, "option_") and v == "on" end)
      |> Enum.map(fn {k, _} -> String.replace(k, "option_", "") end)
    
    updated_answers = Map.put(socket.assigns.answers, index, selected_options)
    
    {:noreply, assign(socket, :answers, updated_answers)}
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    current_index = socket.assigns.current_question_index
    max_index = length(socket.assigns.questions) - 1
    
    if current_index < max_index do
      {:noreply, assign(socket, :current_question_index, current_index + 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev_question", _params, socket) do
    current_index = socket.assigns.current_question_index
    
    if current_index > 0 do
      {:noreply, assign(socket, :current_question_index, current_index - 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("submit_survey", _params, socket) do
    survey = socket.assigns.survey
    questions = socket.assigns.questions
    answers = socket.assigns.answers
    loan = socket.assigns.loan
    
    # Create survey response
    response_attrs = case loan do
      nil -> %{
        survey_id: survey.id,
        completion_status: "completed",
        submitted_at: DateTime.utc_now()
      }
      loan -> %{
        survey_id: survey.id,
        respondent_name: loan.user.name || "#{loan.user.first_name} #{loan.user.last_name}",
        respondent_email: loan.user.email,
        respondent_phone: loan.user.phone,
        completion_status: "completed",
        submitted_at: DateTime.utc_now()
      }
    end
    
    case Surveys.create_survey_response(response_attrs) do
      {:ok, survey_response} ->
        # Save individual question responses
        Enum.each(questions, fn question ->
          question_index = Enum.find_index(questions, &(&1.id == question.id))
          answer = Map.get(answers, question_index)
          
          if answer do
            response_data = case {question.question_type, answer} do
              {"checkbox", selections} when is_list(selections) ->
                %{"selections" => selections}
              {_, single_answer} ->
                %{}
            end
            
            response_value = case answer do
              list when is_list(list) -> Enum.join(list, ", ")
              value -> to_string(value)
            end
            
            Surveys.upsert_question_response(
              survey_response.id,
              question.id,
              %{
                response_value: response_value,
                response_data: response_data
              }
            )
          end
        end)
        
        # No invitation tracking needed for direct access
        
        socket = 
          socket
          |> put_flash(:info, "Thank you for completing the survey!")
          |> assign(:completed, true)
        
        {:noreply, socket}
        
      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to submit survey. Please try again.")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("go_to_question", %{"index" => index}, socket) do
    index = String.to_integer(index)
    max_index = length(socket.assigns.questions) - 1
    
    if index >= 0 and index <= max_index do
      {:noreply, assign(socket, :current_question_index, index)}
    else
      {:noreply, socket}
    end
  end

  defp check_existing_response_for_loan(survey_id, loan_id) do
    # Check if there's already a response for this loan and survey
    # This is a simple implementation - in practice you'd want more sophisticated tracking
    nil
  end

  defp get_current_question(questions, index) do
    Enum.at(questions, index)
  end

  defp progress_percentage(current_index, total_questions) do
    if total_questions > 0 do
      Float.round((current_index + 1) / total_questions * 100, 1)
    else
      0.0
    end
  end

  defp question_completed?(answers, index) do
    case Map.get(answers, index) do
      nil -> false
      "" -> false
      [] -> false
      _ -> true
    end
  end
end