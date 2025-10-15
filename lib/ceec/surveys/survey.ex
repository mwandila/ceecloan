defmodule Ceec.Surveys.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "surveys" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "draft"
    field :created_by, :string
    field :start_date, :date
    field :end_date, :date

    belongs_to :project, Ceec.Projects.Project
    has_many :survey_responses, Ceec.Surveys.SurveyResponse
    has_many :questions, Ceec.Surveys.SurveyQuestion

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:title, :description, :status, :created_by, :start_date, :end_date, :project_id])
    |> validate_required([:title, :description, :created_by, :project_id])
    |> validate_inclusion(:status, ["draft", "active", "completed", "archived"])
    |> foreign_key_constraint(:project_id)
  end
end