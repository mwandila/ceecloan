defmodule Ceec.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :project_code, :string
    field :project_id, :string
    field :status, :string
    field :progress, :integer
    field :start_date, :date
    field :end_date, :date
    field :budget, :decimal
    field :description, :string
    field :project_type, :string
    field :country, :string
    
    has_many :loans, Ceec.Finance.Loan
    has_many :surveys, Ceec.Surveys.Survey

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :project_code, :project_id, :status, :progress, :start_date, :end_date, :budget, :description, :project_type, :country])
    |> validate_required([:name, :project_code, :status, :start_date, :budget, :description, :project_type, :country])
    |> unique_constraint(:project_code)
    |> unique_constraint(:project_id)
  end
end
