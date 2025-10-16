defmodule CeecWeb.SurveyAccessLive do
  use CeecWeb, :live_view
  import Ecto.Query

  alias Ceec.Surveys
  alias Ceec.Finance

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:application_id, "")
      |> assign(:error_message, nil)
      |> assign(:available_surveys, [])
      |> assign(:loan, nil)
      |> assign(:page_title, "Access Survey")
    
    {:ok, socket}
  end

  @impl true
  def handle_event("check_access", %{"application_id" => application_id}, socket) do
    application_id = String.trim(application_id)
    
    if application_id == "" do
      socket = 
        socket
        |> assign(:error_message, "Please enter your application ID")
        |> assign(:available_surveys, [])
        |> assign(:loan, nil)
      
      {:noreply, socket}
    else
      case Finance.get_loan_by_application_id(application_id) do
        nil ->
          socket = 
            socket
            |> assign(:error_message, "Application ID not found. Please check and try again.")
            |> assign(:available_surveys, [])
            |> assign(:loan, nil)
          
          {:noreply, socket}
        
        loan ->
          if loan.status != "disbursed" do
            socket = 
              socket
              |> assign(:error_message, "Surveys are only available for disbursed loans. Your loan status: #{String.capitalize(loan.status)}")
              |> assign(:available_surveys, [])
              |> assign(:loan, nil)
            
            {:noreply, socket}
          else
            # Get available surveys for this loan's project
            available_surveys = get_available_surveys_for_loan(loan)
            
            if length(available_surveys) == 0 do
              socket = 
                socket
                |> assign(:error_message, "No surveys are currently available for your project.")
                |> assign(:available_surveys, [])
                |> assign(:loan, loan)
              
              {:noreply, socket}
            else
              socket = 
                socket
                |> assign(:error_message, nil)
                |> assign(:available_surveys, available_surveys)
                |> assign(:loan, loan)
                |> assign(:application_id, application_id)
              
              {:noreply, socket}
            end
          end
      end
    end
  end

  @impl true
  def handle_event("take_survey", %{"survey_id" => survey_id}, socket) do
    survey_id = String.to_integer(survey_id)
    loan = socket.assigns.loan
    
    # Redirect to survey taking interface
    {:noreply, push_navigate(socket, to: ~p"/survey/take/#{survey_id}?loan_id=#{loan.id}")}
  end

  defp get_available_surveys_for_loan(loan) do
    # Get surveys for this loan's project that are active
    if loan.project_id do
      project_id = loan.project_id
      from(s in Ceec.Surveys.Survey,
        where: s.project_id == ^project_id and s.status == "active",
        order_by: [desc: s.inserted_at]
      )
      |> Ceec.Repo.all()
    else
      []
    end
  end
end