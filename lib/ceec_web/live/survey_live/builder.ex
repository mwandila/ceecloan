defmodule CeecWeb.SurveyLive.Builder do
  use CeecWeb, :live_view

  alias Ceec.Surveys
  alias Ceec.Surveys.{Survey, SurveyQuestion}

  @impl true
  def mount(params, _session, socket) do
    survey_id = params["id"]
    
    {survey, questions} = if survey_id do
      survey = Surveys.get_survey!(survey_id)
      questions = Surveys.get_survey_questions(survey_id)
      {survey, questions}
    else
      # Create a temporary survey for new surveys
      survey = %Survey{
        id: nil,
        title: "",
        description: "",
        status: "draft",
        created_by: get_user_name_from_session(socket)
      }
      {survey, []}
    end
    
    # Load available projects
    projects = Ceec.Projects.list_projects()
    
    # Determine if we need to show project selection
    show_project_selection = is_nil(survey.project_id) && survey_id == nil
    
    socket = 
      socket
      |> assign(:survey, survey)
      |> assign(:questions, questions)
      |> assign(:projects, projects)
      |> assign(:show_project_selection, show_project_selection)
      |> assign(:selected_question, nil)
      |> assign(:show_question_modal, false)
      |> assign(:show_preview_modal, false)
      |> assign(:preview_answers, %{})
      |> assign(:question_changeset, SurveyQuestion.changeset(%SurveyQuestion{}, %{}))
      |> assign(:page_title, if(survey_id, do: "Edit Survey", else: "Create Survey"))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Survey")
    |> assign(:survey, Surveys.get_survey!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create Survey")
    |> assign(:survey, %Survey{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Survey Builder")
  end

  @impl true
  def handle_event("create_loan_assessment", _params, socket) do
    case Surveys.create_loan_assessment_survey(%{
      "created_by" => get_user_name(socket)
    }) do
      {:ok, survey} ->
        questions = Surveys.get_survey_questions(survey.id)
        
        socket = 
          socket
          |> put_flash(:info, "Loan assessment survey template created successfully!")
          |> assign(:survey, survey)
          |> assign(:questions, questions)
          
        {:noreply, push_navigate(socket, to: ~p"/surveys/#{survey.id}/builder")}
        
      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create survey template")}
    end
  end

  # Handle adding questions with type
  @impl true
  def handle_event("add_question", %{"type" => question_type}, socket) do
    # Ensure survey exists first
    survey = ensure_survey_exists(socket)
    
    new_question = %{
      survey_id: survey.id,
      question_text: "New #{format_question_type(question_type)} Question",
      question_type: question_type,
      options: if(question_type in ["select", "radio", "checkbox"], do: [], else: nil),
      required: false,
      order_index: length(socket.assigns.questions)
    }
    
    # Add question to the local list immediately for better UX
    updated_questions = socket.assigns.questions ++ [struct(SurveyQuestion, new_question)]
    
    socket = 
      socket
      |> assign(:survey, survey)
      |> assign(:questions, updated_questions)
    
    {:noreply, socket}
  end
  
  # Fallback for add_question without type
  @impl true
  def handle_event("add_question", _params, socket) do
    # Default to text question
    send(self(), {"add_question", %{"type" => "text"}})
    {:noreply, socket}
  end
  
  # Handle survey field updates
  @impl true
  def handle_event("update_survey", params, socket) do
    field = params["field"]
    value = case params do
      %{"value" => val} -> val
      %{^field => val} -> val
      _ -> params["target"] && params["target"]["value"]
    end
    
    if field && value do
      survey = Map.put(socket.assigns.survey, String.to_atom(field), value)
      {:noreply, assign(socket, :survey, survey)}
    else
      {:noreply, socket}
    end
  end
  
  # Handle question updates
  @impl true
  def handle_event("update_question", params, socket) do
    index = String.to_integer(params["index"])
    field = params["field"]
    
    # Extract value from different possible sources
    value = case {params["value"], field} do
      {"on", "required"} -> true  # checkbox on
      {nil, "required"} -> false # checkbox off
      {val, "options"} when is_binary(val) -> String.split(val, "\n", trim: true)
      {val, _} -> val
      _ -> 
        # Try to get value from target (form input)
        case params["target"] do
          %{"value" => val} when field == "options" -> String.split(val, "\n", trim: true)
          %{"value" => val} -> val
          _ -> nil
        end
    end
    
    questions = socket.assigns.questions
    question = Enum.at(questions, index)
    
    if question && value != nil do
      updated_question = Map.put(question, String.to_atom(field), value)
      updated_questions = List.replace_at(questions, index, updated_question)
      {:noreply, assign(socket, :questions, updated_questions)}
    else
      {:noreply, socket}
    end
  end
  
  # Handle question deletion by index
  @impl true
  def handle_event("delete_question", %{"index" => index}, socket) do
    index = String.to_integer(index)
    questions = List.delete_at(socket.assigns.questions, index)
    {:noreply, assign(socket, :questions, questions)}
  end
  
  # Handle question movement
  @impl true
  def handle_event("move_question", %{"index" => index, "direction" => direction}, socket) do
    index = String.to_integer(index)
    questions = socket.assigns.questions
    
    new_index = case direction do
      "up" -> max(0, index - 1)
      "down" -> min(length(questions) - 1, index + 1)
      _ -> index
    end
    
    if index != new_index do
      question = Enum.at(questions, index)
      questions_without_question = List.delete_at(questions, index)
      updated_questions = List.insert_at(questions_without_question, new_index, question)
      {:noreply, assign(socket, :questions, updated_questions)}
    else
      {:noreply, socket}
    end
  end
  
  # Handle clearing all questions
  @impl true
  def handle_event("clear_all_questions", _params, socket) do
    {:noreply, assign(socket, :questions, [])}
  end
  
  # Handle saving survey
  @impl true
  def handle_event("save_survey", _params, socket) do
    survey = socket.assigns.survey
    
    case save_survey_and_questions(survey, socket.assigns.questions) do
      {:ok, saved_survey} ->
        socket = 
          socket
          |> put_flash(:info, "Survey saved successfully!")
          |> assign(:survey, saved_survey)
        
        {:noreply, socket}
      
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to save survey")}
    end
  end
  
  # Handle preview
  @impl true
  def handle_event("preview_survey", _params, socket) do
    {:noreply, assign(socket, :show_preview_modal, true)}
  end
  
  # Handle closing preview modal
  @impl true
  def handle_event("close_preview", _params, socket) do
    socket = 
      socket
      |> assign(:show_preview_modal, false)
      |> assign(:preview_answers, %{})
    {:noreply, socket}
  end
  
  # Handle preview answer updates
  @impl true
  def handle_event("update_preview_answer", params, socket) do
    question_index = String.to_integer(params["question"])
    answer = params["answer"]
    
    updated_answers = Map.put(socket.assigns.preview_answers, question_index, answer)
    {:noreply, assign(socket, :preview_answers, updated_answers)}
  end
  
  # Handle project selection
  @impl true
  def handle_event("select_project", %{"project_id" => project_id}, socket) do
    project_id = String.to_integer(project_id)
    project = Enum.find(socket.assigns.projects, &(&1.id == project_id))
    
    # Create survey with selected project
    survey_attrs = %{
      title: "Survey for #{project.name}",
      description: "Assessment survey for #{project.name} project",
      status: "draft",
      project_id: project_id,
      created_by: get_user_name_from_session(socket)
    }
    
    case Surveys.create_survey(survey_attrs) do
      {:ok, survey} ->
        socket = 
          socket
          |> assign(:survey, survey)
          |> assign(:show_project_selection, false)
          |> put_flash(:info, "Survey created for #{project.name}. Now you can add questions.")
        
        {:noreply, socket}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create survey. Please try again.")}
    end
  end

  @impl true 
  def handle_event("edit_question", %{"id" => id}, socket) do
    question = Enum.find(socket.assigns.questions, &(&1.id == String.to_integer(id)))
    changeset = SurveyQuestion.changeset(question, %{})
    
    socket = 
      socket
      |> assign(:selected_question, question)
      |> assign(:question_changeset, changeset)
      |> assign(:show_question_modal, true)
      
    {:noreply, socket}
  end

  @impl true
  def handle_event("close_question_modal", _params, socket) do
    {:noreply, assign(socket, :show_question_modal, false)}
  end

  @impl true
  def handle_event("save_question", %{"survey_question" => question_params}, socket) do
    case socket.assigns.selected_question do
      nil ->
        # Creating new question
        case Surveys.create_survey_question(question_params) do
          {:ok, _question} ->
            questions = Surveys.get_survey_questions(socket.assigns.survey.id)
            
            socket = 
              socket
              |> put_flash(:info, "Question added successfully!")
              |> assign(:questions, questions)
              |> assign(:show_question_modal, false)
              
            {:noreply, socket}
            
          {:error, changeset} ->
            {:noreply, assign(socket, :question_changeset, changeset)}
        end
        
      existing_question ->
        # Updating existing question
        case Surveys.update_survey_question(existing_question, question_params) do
          {:ok, _question} ->
            questions = Surveys.get_survey_questions(socket.assigns.survey.id)
            
            socket = 
              socket
              |> put_flash(:info, "Question updated successfully!")
              |> assign(:questions, questions)
              |> assign(:show_question_modal, false)
              
            {:noreply, socket}
            
          {:error, changeset} ->
            {:noreply, assign(socket, :question_changeset, changeset)}
        end
    end
  end

  @impl true
  def handle_event("delete_question", %{"id" => id}, socket) do
    question = Enum.find(socket.assigns.questions, &(&1.id == String.to_integer(id)))
    
    case Surveys.delete_survey_question(question) do
      {:ok, _} ->
        questions = Surveys.get_survey_questions(socket.assigns.survey.id)
        
        socket = 
          socket
          |> put_flash(:info, "Question deleted successfully!")
          |> assign(:questions, questions)
          
        {:noreply, socket}
        
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete question")}
    end
  end

  @impl true
  def handle_event("reorder_question", %{"old_index" => old_index, "new_index" => new_index}, socket) do
    old_idx = String.to_integer(old_index)
    new_idx = String.to_integer(new_index)
    
    if old_idx != new_idx and old_idx < length(socket.assigns.questions) and new_idx < length(socket.assigns.questions) do
      questions = socket.assigns.questions
      question_to_move = Enum.at(questions, old_idx)
      
      # Update the order_index of the moved question
      case Surveys.update_survey_question(question_to_move, %{order_index: new_idx}) do
        {:ok, _} ->
          # Refresh questions list
          updated_questions = Surveys.get_survey_questions(socket.assigns.survey.id)
          {:noreply, assign(socket, :questions, updated_questions)}
          
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to reorder question")}
      end
    else
      {:noreply, socket}
    end
  end

  defp get_user_name(socket) do
    case socket.assigns[:current_user] do
      %{email: email} -> email
      _ -> "Anonymous"
    end
  end
  
  defp get_user_name_from_session(socket) do
    case socket.assigns[:current_user] do
      %{email: email} -> email
      _ -> "Anonymous"
    end
  end
  
  # Ensure survey exists in database before adding questions
  defp ensure_survey_exists(socket) do
    survey = socket.assigns.survey
    
    if survey.id do
      survey
    else
      # Create the survey first
      case Surveys.create_survey(%{
        title: if(survey.title != "", do: survey.title, else: "New Survey"),
        description: survey.description || "",
        status: survey.status || "draft",
        created_by: survey.created_by || "Anonymous"
      }) do
        {:ok, created_survey} -> created_survey
        {:error, _} -> survey  # Return original if creation fails
      end
    end
  end
  
  # Save survey and all questions
  defp save_survey_and_questions(survey, questions) do
    # First ensure survey exists
    case save_or_update_survey(survey) do
      {:ok, saved_survey} ->
        # Then save/update all questions
        save_questions(saved_survey.id, questions)
        {:ok, saved_survey}
      
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  defp save_or_update_survey(survey) do
    if survey.id do
      Surveys.update_survey(survey, %{
        title: survey.title,
        description: survey.description,
        status: survey.status
      })
    else
      Surveys.create_survey(%{
        title: survey.title || "New Survey",
        description: survey.description || "",
        status: survey.status || "draft",
        created_by: survey.created_by || "Anonymous"
      })
    end
  end
  
  defp save_questions(survey_id, questions) do
    # For now, we'll just create new questions
    # In a full implementation, you'd want to update existing ones
    Enum.each(questions, fn question ->
      if is_nil(question.id) do
        Surveys.create_survey_question(%{
          survey_id: survey_id,
          question_text: question.question_text,
          question_type: question.question_type,
          options: question.options,
          required: question.required || false,
          order_index: question.order_index || 0
        })
      end
    end)
  end
  
  defp format_question_type(type) do
    case type do
      "text" -> "Short Text"
      "textarea" -> "Long Text"
      "select" -> "Dropdown"
      "radio" -> "Multiple Choice"
      "checkbox" -> "Checkboxes"
      "rating" -> "Rating Scale"
      "yes_no" -> "Yes/No"
      "number" -> "Number"
      "email" -> "Email"
      "phone" -> "Phone"
      _ -> String.capitalize(type)
    end
  end
end