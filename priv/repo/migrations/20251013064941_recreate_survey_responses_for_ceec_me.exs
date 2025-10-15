defmodule Ceec.Repo.Migrations.RecreateSurveyResponsesForCeecMe do
  use Ecto.Migration

  def change do
    # Drop and recreate the survey_responses table with CEEC M&E fields
    drop_if_exists table(:survey_responses)
    
    create table(:survey_responses) do
      # Basic respondent info
      add :respondent_name, :string, null: false
      add :respondent_contact, :string
      add :respondent_location, :string
      add :survey_date, :date, null: false
      add :surveyor_name, :string, null: false
      
      # Project Information
      add :project_name, :string, null: false
      add :implementing_organization, :string
      add :project_location, :string
      add :project_start_date, :date
      
      # Beneficiary Information
      add :beneficiary_name, :string, null: false
      add :beneficiary_gender, :string, null: false
      add :beneficiary_age, :integer, null: false
      add :household_size, :integer
      
      # Economic Impact
      add :income_before, :decimal, precision: 15, scale: 2, null: false
      add :income_after, :decimal, precision: 15, scale: 2, null: false
      add :employment_status, :string, null: false
      add :skills_acquired, :text
      add :economic_impact, :string
      add :income_change_description, :string
      
      # Social Impact
      add :health_improvement, :string, null: false
      add :education_access, :string, null: false
      add :community_participation, :text
      
      # Project Evaluation
      add :sustainability_prospects, :string, null: false
      add :challenges_faced, :text, null: false
      add :recommendations, :text
      add :additional_comments, :text
      add :overall_satisfaction, :integer, null: false
      add :would_recommend, :boolean
      add :project_impact_rating, :string
      add :employment_impact, :string
      add :other_challenges, :text
      add :support_needed, :text
      
      add :survey_id, references(:surveys, on_delete: :delete_all), null: false
      
      timestamps()
    end
    
    create index(:survey_responses, [:survey_id])
    create index(:survey_responses, [:survey_date])
    create index(:survey_responses, [:project_name])
  end
end
