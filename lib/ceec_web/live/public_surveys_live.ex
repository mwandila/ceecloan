defmodule CeecWeb.PublicSurveysLive do
  use CeecWeb, :live_view
  import Ecto.Query

  alias Ceec.Surveys

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:surveys, [])
      |> assign(:application_id, "")
      |> assign(:error_message, nil)
      |> assign(:loan, nil)
      |> assign(:show_verification, true)
      |> assign(:page_title, "Available Surveys")

    {:ok, socket}
  end

  @impl true
  def handle_event("verify_application", %{"application_id" => application_id}, socket) do
    application_id = String.trim(application_id)
    
    if application_id == "" do
      socket = 
        socket
        |> assign(:error_message, "Please enter your application ID")
      
      {:noreply, socket}
    else
      case Ceec.Finance.get_loan_by_application_id(application_id) do
        nil ->
          socket = 
            socket
            |> assign(:error_message, "Application ID not found. Please check and try again.")
          
          {:noreply, socket}
        
        loan ->
          if loan.status != "disbursed" do
            socket = 
              socket
              |> assign(:error_message, "Surveys are only available for disbursed loans. Your loan status: #{String.capitalize(loan.status)}")
            
            {:noreply, socket}
          else
            # Get surveys for this loan's project
            available_surveys = get_surveys_for_loan(loan)
            
            socket = 
              socket
              |> assign(:error_message, nil)
              |> assign(:surveys, available_surveys)
              |> assign(:loan, loan)
              |> assign(:application_id, application_id)
              |> assign(:show_verification, false)
            
            {:noreply, socket}
          end
      end
    end
  end
  
  @impl true
  def handle_event("take_survey", %{"survey_id" => survey_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/loans/#{socket.assigns.loan.id}/survey/#{survey_id}")}
  end
  
  @impl true
  def handle_event("check_different_id", _params, socket) do
    socket = 
      socket
      |> assign(:surveys, [])
      |> assign(:application_id, "")
      |> assign(:error_message, nil)
      |> assign(:loan, nil)
      |> assign(:show_verification, true)
    
    {:noreply, socket}
  end
  
  defp get_surveys_for_loan(loan) do
    if loan.project_id do
      from(s in Ceec.Surveys.Survey,
        where: s.status == "active" and s.project_id == ^loan.project_id,
        preload: [:project],
        order_by: [desc: s.inserted_at]
      )
      |> Ceec.Repo.all()
    else
      # If loan has no project, show all active surveys
      from(s in Ceec.Surveys.Survey,
        where: s.status == "active",
        preload: [:project],
        order_by: [desc: s.inserted_at]
      )
      |> Ceec.Repo.all()
    end
  end
end