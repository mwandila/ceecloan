defmodule Ceec.Repo.Migrations.UpdateSurveyResponsesForCeecMe do
  use Ecto.Migration

  def change do
    alter table(:survey_responses) do
      # Remove loan-specific fields
      remove_if_exists :loan_type, :string
      remove_if_exists :loan_amount, :decimal
      remove_if_exists :loan_duration_months, :integer
      remove_if_exists :loan_purpose, :string
      remove_if_exists :loan_source, :string
      remove_if_exists :interest_rate, :decimal
      remove_if_exists :actual_usage, :string
      remove_if_exists :usage_matches_purpose, :boolean
      remove_if_exists :usage_details, :string
      remove_if_exists :repayment_challenges, :string
      remove_if_exists :financial_difficulties, :string
      remove_if_exists :procedural_challenges, :string
      
      # Add CEEC M&E specific fields
      add_if_not_exists :project_name, :string
      add_if_not_exists :implementing_organization, :string
      add_if_not_exists :project_location, :string
      add_if_not_exists :project_start_date, :date
      
      add_if_not_exists :beneficiary_name, :string
      add_if_not_exists :beneficiary_gender, :string
      add_if_not_exists :beneficiary_age, :integer
      add_if_not_exists :household_size, :integer
      
      add_if_not_exists :income_before, :decimal
      add_if_not_exists :income_after, :decimal
      add_if_not_exists :employment_status, :string
      add_if_not_exists :skills_acquired, :text
      
      add_if_not_exists :health_improvement, :string
      add_if_not_exists :education_access, :string
      add_if_not_exists :community_participation, :text
      
      add_if_not_exists :sustainability_prospects, :string
      add_if_not_exists :challenges_faced, :text
      add_if_not_exists :overall_satisfaction, :integer
      
      # Rename some existing fields (need to handle separately)
      # Will be done in separate alter blocks below
    end
    
    # Handle field renaming in separate operations
    rename table(:survey_responses), :business_impact, to: :economic_impact
    rename table(:survey_responses), :income_change, to: :income_change_description
    rename table(:survey_responses), :business_growth, to: :project_impact_rating
  end
end
