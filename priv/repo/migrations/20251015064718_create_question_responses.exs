defmodule Ceec.Repo.Migrations.CreateQuestionResponses do
  use Ecto.Migration

  def change do
    create table(:question_responses) do
      add :survey_response_id, references(:survey_responses, on_delete: :delete_all), null: false
      add :question_id, references(:survey_questions, on_delete: :delete_all), null: false
      add :response_value, :text # Stores the actual response (text, selected option, rating, etc.)
      add :response_data, :map # JSON for complex responses (multiple selections, etc.)
      
      timestamps(type: :utc_datetime)
    end

    create index(:question_responses, [:survey_response_id])
    create index(:question_responses, [:question_id])
    create unique_index(:question_responses, [:survey_response_id, :question_id])
  end
end
