defmodule CeecWeb.PageController do
  use CeecWeb, :controller
  
  alias Ceec.Projects
  alias Ceec.Surveys

  def dashboard(conn, _params) do
    # Get summary statistics efficiently from database
    stats = %{
      total_projects: Projects.get_total_projects_count(),
      active_projects: Projects.get_active_projects_count(),
      total_beneficiaries: Projects.get_total_beneficiaries_count(),
      total_surveys: Surveys.get_total_surveys_count()
    }
    
    # Get recent surveys/questionnaires to display
    recent_surveys = Surveys.list_active_surveys() |> Enum.take(6)
    
    # Get some active projects for display
    projects = Projects.list_active_projects() |> Enum.take(4)
    
    render(conn, :dashboard, stats: stats, recent_surveys: recent_surveys, projects: projects)
  end
  
  def index(conn, _params) do
    # Get the first available survey or create a default one
    case Surveys.list_surveys() do
      [first_survey | _] ->
        redirect(conn, to: ~p"/surveys/#{first_survey.id}/responses/new")
      [] ->
        # Create a default survey if none exist
        {:ok, survey} = Surveys.create_survey(%{
          title: "CEEC Data Collection Survey",
          description: "Primary data collection form for CEEC projects",
          status: "active",
          created_by: "system",
          start_date: Date.utc_today(),
          end_date: Date.add(Date.utc_today(), 365)
        })
        redirect(conn, to: ~p"/surveys/#{survey.id}/responses/new")
    end
  end
  
  def redirect_to_surveys(conn, _params) do
    redirect(conn, to: ~p"/surveys")
  end
  
  def redirect_to_login(conn, _params) do
    redirect(conn, to: ~p"/users/log_in")
  end
  
  def home(conn, _params) do
    if conn.assigns[:current_user] do
      # Authenticated users (CEEC staff) go to admin dashboard
      redirect(conn, to: ~p"/dashboard")
    else
      # Public users (loan applicants) go to public loan application
      # Get available loan programs for display
      available_loan_types = Ceec.Finance.get_available_loan_types()
      available_surveys = Surveys.list_active_surveys() |> Enum.take(1)
      
      render(conn, :public_home, 
        available_loan_types: available_loan_types,
        available_surveys: available_surveys
      )
    end
  end
  
  def public_home(conn, _params) do
    # Get available loan programs for display
    available_loan_types = Ceec.Finance.get_available_loan_types()
    available_surveys = Surveys.list_active_surveys() |> Enum.take(1)
    
    render(conn, :public_home, 
      available_loan_types: available_loan_types,
      available_surveys: available_surveys
    )
  end
end
