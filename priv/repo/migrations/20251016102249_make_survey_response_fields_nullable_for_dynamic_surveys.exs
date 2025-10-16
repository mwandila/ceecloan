defmodule Ceec.Repo.Migrations.MakeSurveyResponseFieldsNullableForDynamicSurveys do
  use Ecto.Migration

  def change do
    # Make legacy required fields nullable to support dynamic survey responses
    # Based on the recreate migration 20251013064941, these are the fields that exist with null: false
    alter table(:survey_responses) do
      modify :survey_date, :date, null: true
      modify :surveyor_name, :string, null: true
      modify :project_name, :string, null: true
      modify :beneficiary_name, :string, null: true
      modify :beneficiary_gender, :string, null: true
      modify :beneficiary_age, :integer, null: true
      modify :income_before, :decimal, null: true
      modify :income_after, :decimal, null: true
      modify :employment_status, :string, null: true
      modify :health_improvement, :string, null: true
      modify :education_access, :string, null: true
      modify :sustainability_prospects, :string, null: true
      modify :challenges_faced, :text, null: true
      modify :overall_satisfaction, :integer, null: true
    end
  end
end
