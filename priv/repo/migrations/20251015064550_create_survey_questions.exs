defmodule Ceec.Repo.Migrations.CreateSurveyQuestions do
  use Ecto.Migration

  def change do
    create table(:survey_questions) do
      add :survey_id, references(:surveys, on_delete: :delete_all), null: false
      add :question_text, :text, null: false
      add :question_type, :string, null: false # text, textarea, select, radio, checkbox, rating, yes_no
      add :options, :map # JSON array for multiple choice options
      add :required, :boolean, default: false
      add :order_index, :integer, null: false
      add :help_text, :text
      add :validation_rules, :map # JSON for validation rules (min/max length, etc.)
      add :category, :string # e.g., "loan_usage", "challenges", "impact", "satisfaction"
      
      timestamps(type: :utc_datetime)
    end

    create index(:survey_questions, [:survey_id])
    create index(:survey_questions, [:survey_id, :order_index])
    create index(:survey_questions, [:category])
  end
end
