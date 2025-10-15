defmodule Ceec.Repo.Migrations.CreateSurveyResponses do
  use Ecto.Migration

  def change do
    create table(:survey_responses) do
      add :respondent_name, :string, null: false
      add :respondent_contact, :string
      add :respondent_location, :string
      
      # Loan Information
      add :loan_type, :string, null: false
      add :loan_amount, :decimal, precision: 15, scale: 2, null: false
      add :loan_duration_months, :integer
      add :loan_purpose, :string, null: false
      add :loan_source, :string
      add :interest_rate, :decimal, precision: 5, scale: 2
      
      # Usage Assessment
      add :actual_usage, :string, null: false
      add :usage_matches_purpose, :boolean
      add :usage_details, :string
      add :business_impact, :string
      add :income_change, :string
      
      # Challenges Faced
      add :repayment_challenges, :string
      add :financial_difficulties, :string
      add :procedural_challenges, :string
      add :other_challenges, :string
      add :support_needed, :string
      
      # Impact Evaluation
      add :overall_satisfaction, :integer
      add :would_recommend, :boolean
      add :business_growth, :string
      add :employment_impact, :string
      
      # Recommendations and Additional Info
      add :recommendations, :string
      add :additional_comments, :string
      add :survey_date, :date, null: false
      add :surveyor_name, :string, null: false
      
      add :survey_id, references(:surveys, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:survey_responses, [:survey_id])
    create index(:survey_responses, [:survey_date])
    create index(:survey_responses, [:respondent_name])
  end
end
