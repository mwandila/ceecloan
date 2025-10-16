defmodule CeecWeb.SurveyLive.Take do
  use CeecWeb, :live_view

  import Ecto.Query, warn: false

  alias Ceec.Surveys
  alias Ceec.Finance
  alias Ceec.Surveys.{SurveyResponse, QuestionResponse}

  @impl true
  def mount(params, _session, socket) when is_map_key(params, "id") do
    survey_id = params["id"]
    loan_id = params["loan_id"]

    # If loan_id is provided (from direct link), mount the survey
    # Otherwise, show application ID verification screen
    if loan_id do
      mount_survey(survey_id, loan_id, socket)
    else
      mount_verification_screen(survey_id, socket)
    end
  end

  @impl true
  def mount(%{"loan_id" => loan_id}, _session, socket) do
    # Auto-find survey for loan (take_for_loan_auto action)
    case find_active_survey_for_loan(loan_id) do
      {:ok, survey} ->
        mount_survey(survey.id, loan_id, socket)

      {:error, :no_survey} ->
        {:ok,
         socket
         |> put_flash(:error, "No active survey found for this loan.")
         |> push_navigate(to: ~p"/loans/#{loan_id}")}
    end
  end

  defp mount_verification_screen(survey_id, socket) do
    try do
      survey = Surveys.get_survey!(survey_id)

      # Check if survey is available for taking
      cond do
        survey.status != "active" ->
          socket =
            socket
            |> put_flash(
              :error,
              "This survey is not currently available. Status: #{String.capitalize(survey.status)}"
            )
            |> redirect(to: "/")

          {:ok, socket}

        true ->
          socket =
            socket
            |> assign(:survey, survey)
            |> assign(:show_verification, true)
            |> assign(:application_id, "")
            |> assign(:verification_error, nil)
            |> assign(:submitting, false)
            |> assign(:page_title, survey.title)

          {:ok, socket}
      end
    rescue
      Ecto.NoResultsError ->
        socket =
          socket
          |> put_flash(:error, "Survey not found. Please check the survey link and try again.")
          |> redirect(to: "/")

        {:ok, socket}
    end
  end

  defp mount_survey(survey_id, loan_id, socket) do
    try do
      survey = Surveys.get_survey_with_questions!(survey_id)

      # Check if survey is available for taking
      cond do
        survey.status != "active" ->
          socket =
            socket
            |> put_flash(
              :error,
              "This survey is not currently available. Status: #{String.capitalize(survey.status)}"
            )
            |> redirect(to: "/")

          {:ok, socket}

        true ->
          do_mount_survey(survey, loan_id, socket)
      end
    rescue
      Ecto.NoResultsError ->
        socket =
          socket
          |> put_flash(:error, "Survey not found. Please check the survey link and try again.")
          |> redirect(to: "/")

        {:ok, socket}
    end
  end

  defp do_mount_survey(survey, loan_id, socket) do
    # Get or create survey response
    case get_or_create_response(survey, loan_id, socket) do
      {nil, _} ->
        # Survey response creation failed
        socket =
          socket
          |> put_flash(:error, "Unable to create survey response. Please try again later.")
          |> redirect(to: "/")
        {:ok, socket}
        
      {survey_response, is_new} ->
        # Load existing answers if resuming
        existing_answers =
          if is_new do
            %{}
          else
            load_existing_answers(survey_response.id)
          end

        # Calculate progress
        answered_questions = map_size(existing_answers)
        total_questions = length(survey.questions)

        progress =
          if total_questions > 0, do: round(answered_questions / total_questions * 100), else: 0

        socket =
          socket
          |> assign(:survey, survey)
          |> assign(:survey_response, survey_response)
          |> assign(:loan_id, loan_id)
          |> assign(:questions, survey.questions)
          |> assign(:current_question_index, 0)
          |> assign(:answers, existing_answers)
          |> assign(:progress, progress)
          |> assign(:is_completed, survey_response.completion_status == "completed")
          |> assign(:show_summary, false)
          |> assign(:validation_errors, %{})
          # Make sure verification is hidden
          |> assign(:show_verification, false)
          # Track submission state
          |> assign(:submitting, false)

        {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :take, _params) do
    socket |> assign(:page_title, "Complete Survey")
  end

  defp apply_action(socket, :take_for_loan, _params) do
    socket |> assign(:page_title, "Complete Survey")
  end

  defp apply_action(socket, :take_for_loan_auto, _params) do
    socket |> assign(:page_title, "Complete Survey")
  end

  defp apply_action(socket, :completed, _params) do
    socket |> assign(:page_title, "Survey Completed")
  end

  @impl true
  def handle_event("verify_application", %{"application_id" => application_id}, socket) do
    application_id = String.trim(application_id)

    if application_id == "" do
      socket =
        socket
        |> assign(:verification_error, "Please enter your application ID")

      {:noreply, socket}
    else
      case Finance.get_loan_by_application_id(application_id) do
        nil ->
          socket =
            socket
            |> assign(
              :verification_error,
              "Application ID not found. Please check and try again."
            )

          {:noreply, socket}

        loan ->
          if loan.status != "disbursed" do
            socket =
              socket
              |> assign(
                :verification_error,
                "Surveys are only available for disbursed loans. Your loan status: #{String.capitalize(loan.status)}"
              )

            {:noreply, socket}
          else
            # Check if survey is for this loan's project
            survey = socket.assigns.survey

            if survey.project_id && survey.project_id != loan.project_id do
              project_name = if loan.project, do: loan.project.name, else: "your project"

              socket =
                socket
                |> assign(
                  :verification_error,
                  "This survey is not available for #{project_name}. Please check with your loan officer."
                )

              {:noreply, socket}
            else
              # Verification successful - mount the survey
              {:ok, updated_socket} = mount_survey(survey.id, loan.id, socket)
              {:noreply, updated_socket}
            end
          end
      end
    end
  end

  @impl true
  def handle_event("answer_question", params, socket) do
    question_id = params["question_id"]
    
    # Extract answer from various sources
    answer = case params do
      %{"answer" => answer} -> answer  # From phx-value-answer (radio buttons, checkboxes)
      %{"value" => value} -> value     # From select dropdowns
      _ -> 
        # Handle form changes where the target field name is dynamic
        case params do
          %{"_target" => [target]} when is_binary(target) ->
            Map.get(params, target)
          _ ->
            # Look for radio button field (question_123 => "value") as fallback
            params
            |> Enum.find(fn {key, _value} -> String.starts_with?(key, "question_") end)
            |> case do
              {_key, value} -> value
              nil -> nil
            end
        end
    end
    
    if answer do
      handle_answer(socket, question_id, answer)
    else
      {:noreply, socket}
    end
  end

  defp handle_answer(socket, question_id, answer) do
    question_id = String.to_integer(question_id)
    question = Enum.find(socket.assigns.questions, &(&1.id == question_id))

    # Process answer based on question type
    {response_value, response_data} = process_answer(question, answer)

    # Save answer
    case Surveys.upsert_question_response(
           socket.assigns.survey_response.id,
           question_id,
           %{response_value: response_value, response_data: response_data}
         ) do
      {:ok, _} ->
        # Update local answers
        updated_answers = Map.put(socket.assigns.answers, question_id, answer)

        # Recalculate progress
        answered_questions = map_size(updated_answers)
        total_questions = length(socket.assigns.questions)

        progress =
          if total_questions > 0, do: round(answered_questions / total_questions * 100), else: 0

        socket =
          socket
          |> assign(:answers, updated_answers)
          |> assign(:progress, progress)
          |> clear_validation_error(question_id)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to save answer")}
    end
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    current_index = socket.assigns.current_question_index
    questions = socket.assigns.questions

    if current_index < length(questions) - 1 do
      {:noreply, assign(socket, :current_question_index, current_index + 1)}
    else
      # Last question - show summary
      {:noreply, assign(socket, :show_summary, true)}
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
  def handle_event("go_to_question", %{"index" => index}, socket) do
    index = String.to_integer(index)
    questions = socket.assigns.questions

    if index >= 0 and index < length(questions) do
      socket =
        socket
        |> assign(:current_question_index, index)
        |> assign(:show_summary, false)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_summary", _params, socket) do
    {:noreply, assign(socket, :show_summary, true)}
  end

  @impl true
  def handle_event("submit_survey", _params, socket) do
    # Prevent double submissions
    if socket.assigns.submitting do
      {:noreply, socket}
    else
      required_questions = Enum.filter(socket.assigns.questions, & &1.required)
      answers = socket.assigns.answers

      # Set submitting state
      socket = assign(socket, :submitting, true)

      # Validate required questions
      missing_answers =
        Enum.filter(required_questions, fn question ->
          not Map.has_key?(answers, question.id) or
            is_nil(Map.get(answers, question.id)) or
            Map.get(answers, question.id) == ""
        end)

      if Enum.empty?(missing_answers) do
        # All required questions answered - submit survey
        case Surveys.submit_survey_response(socket.assigns.survey_response) do
          {:ok, _} ->
            socket =
              socket
              |> put_flash(:info, "Thank you! Your survey has been submitted successfully.")
              |> assign(:is_completed, true)
              |> push_navigate(to: ~p"/surveys/#{socket.assigns.survey.id}/completed")

            {:noreply, socket}

          {:error, _} ->
            socket =
              socket
              # Reset submission state on error
              |> assign(:submitting, false)
              |> put_flash(:error, "Failed to submit survey. Please try again.")

            {:noreply, socket}
        end
      else
        # Mark missing required questions and reset submitting state
        validation_errors =
          missing_answers
          |> Enum.map(&{&1.id, "This question is required"})
          |> Enum.into(%{})

        socket =
          socket
          # Reset submission state for validation errors
          |> assign(:submitting, false)
          |> assign(:validation_errors, validation_errors)
          |> put_flash(:error, "Please answer all required questions before submitting.")

        {:noreply, socket}
      end
    end
  end

  defp get_or_create_response(survey, loan_id, socket) do
    user_id =
      case socket.assigns[:current_user] do
        %{id: id} -> id
        _ -> nil
      end

    # Try to find existing response
    existing =
      if loan_id do
        survey_id = survey.id

        SurveyResponse
        |> where([sr], sr.survey_id == ^survey_id and sr.loan_id == ^loan_id)
        |> limit(1)
        |> Ceec.Repo.one()
      else
        nil
      end

    case existing do
      nil ->
        # Create new response
        attrs = %{
          survey_id: survey.id,
          loan_id: loan_id,
          user_id: user_id,
          completion_status: "in_progress",
          ip_address: get_remote_ip(socket),
          user_agent: get_user_agent(socket)
        }

        case Surveys.create_minimal_survey_response(attrs) do
          {:ok, response} -> {response, true}
          {:error, changeset} -> 
            # Log the error and create a minimal response that can work
            require Logger
            Logger.error("Failed to create survey response: #{inspect(changeset)}")
            # Return nil to indicate failure - we'll handle this in do_mount_survey
            {nil, true}
        end

      response ->
        {response, false}
    end
  end

  defp load_existing_answers(survey_response_id) do
    from(qr in QuestionResponse,
      where: qr.survey_response_id == ^survey_response_id,
      preload: [:question]
    )
    |> Ceec.Repo.all()
    |> Enum.map(fn response ->
      answer =
        case response.question.question_type do
          "checkbox" ->
            if response.response_data && response.response_data["selections"] do
              response.response_data["selections"]
            else
              []
            end

          _ ->
            response.response_value
        end

      {response.question_id, answer}
    end)
    |> Enum.into(%{})
  end

  defp process_answer(question, answer) do
    case question.question_type do
      "checkbox" when is_list(answer) ->
        {nil, %{"selections" => answer}}

      "checkbox" ->
        {nil, %{"selections" => [answer]}}

      _ ->
        {to_string(answer), nil}
    end
  end

  defp clear_validation_error(socket, question_id) do
    validation_errors = Map.delete(socket.assigns.validation_errors, question_id)
    assign(socket, :validation_errors, validation_errors)
  end

  defp get_remote_ip(socket) do
    case get_connect_info(socket, :peer_data) do
      %{address: address} -> :inet.ntoa(address) |> to_string()
      _ -> nil
    end
  end

  defp get_user_agent(socket) do
    case get_connect_info(socket, :user_agent) do
      agent when is_binary(agent) -> agent
      _ -> nil
    end
  end

  defp current_question(%{questions: questions, current_question_index: index}) do
    Enum.at(questions, index)
  end

  defp question_answered?(%{answers: answers}, question) do
    Map.has_key?(answers, question.id) and
      not is_nil(Map.get(answers, question.id)) and
      Map.get(answers, question.id) != ""
  end

  defp get_answer(%{answers: answers}, question_id) do
    Map.get(answers, question_id, "")
  end

  defp get_question_choices(%{options: options}) when is_map(options) do
    # Handle survey builder format: %{"choices" => [...]}
    Map.get(options, "choices", [])
  end

  defp get_question_choices(%{options: options}) when is_list(options) do
    # Handle legacy format: ["option1", "option2"]
    options
  end

  defp get_question_choices(_) do
    # No options or invalid format
    []
  end

  defp find_active_survey_for_loan(loan_id) do
    # For now, find the first active survey 
    # In the future, this could be more sophisticated (loan-type specific surveys, etc.)
    case Surveys.list_surveys() |> Enum.find(&(&1.status == "active")) do
      nil -> {:error, :no_survey}
      survey -> {:ok, survey}
    end
  end
end
