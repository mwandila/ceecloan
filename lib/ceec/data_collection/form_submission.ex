defmodule Ceec.DataCollection.FormSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "form_submissions" do
    field :submission_id, :string  # Unique identifier for the submission
    field :data, :map              # The actual form data as JSON
    field :status, :string, default: "draft"
    field :submitted_at, :utc_datetime
    field :reviewed_at, :utc_datetime
    field :reviewed_by, :string
    
    # Location data
    field :gps_latitude, :decimal
    field :gps_longitude, :decimal
    field :gps_accuracy, :decimal
    field :location_address, :string
    
    # Data collector information
    field :collector_name, :string
    field :collector_id, :string
    field :device_id, :string
    
    # Quality control
    field :validation_errors, {:array, :string}
    field :quality_score, :integer  # 0-100
    field :notes, :string
    
    # Offline sync support
    field :created_offline, :boolean, default: false
    field :synced_at, :utc_datetime
    
    # Relationships
    belongs_to :form, Ceec.Forms.Form
    belongs_to :project, Ceec.Projects.Project
    belongs_to :beneficiary, Ceec.Projects.Beneficiary, on_replace: :nilify
    has_many :attachments, Ceec.DataCollection.Attachment

    timestamps()
  end

  @doc false
  def changeset(form_submission, attrs) do
    form_submission
    |> cast(attrs, [
      :submission_id, :data, :status, :submitted_at, :reviewed_at, :reviewed_by,
      :gps_latitude, :gps_longitude, :gps_accuracy, :location_address,
      :collector_name, :collector_id, :device_id, :validation_errors,
      :quality_score, :notes, :created_offline, :synced_at,
      :form_id, :project_id, :beneficiary_id
    ])
    |> validate_required([:submission_id, :data, :collector_name, :form_id, :project_id])
    |> validate_inclusion(:status, ["draft", "submitted", "approved", "rejected", "archived"])
    |> validate_number(:quality_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> validate_number(:gps_latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:gps_longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> validate_number(:gps_accuracy, greater_than_or_equal_to: 0)
    |> unique_constraint(:submission_id)
    |> foreign_key_constraint(:form_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:beneficiary_id)
    |> generate_submission_id()
    |> set_submitted_at()
  end

  defp generate_submission_id(changeset) do
    case get_field(changeset, :submission_id) do
      nil ->
        timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> Integer.to_string()
        random = :crypto.strong_rand_bytes(4) |> Base.encode16()
        submission_id = "SUB_" <> timestamp <> "_" <> random
        put_change(changeset, :submission_id, submission_id)
      _ -> changeset
    end
  end

  defp set_submitted_at(changeset) do
    case {get_field(changeset, :status), get_field(changeset, :submitted_at)} do
      {"submitted", nil} -> put_change(changeset, :submitted_at, DateTime.utc_now())
      _ -> changeset
    end
  end

  @doc """
  Validates form data against the form schema.
  """
  def validate_form_data(form_submission, form_schema) do
    data = form_submission.data || %{}
    errors = validate_data_against_schema(data, form_schema)
    
    %{form_submission | validation_errors: errors}
  end

  defp validate_data_against_schema(data, %{"sections" => sections}) do
    sections
    |> Enum.flat_map(fn section -> validate_section_data(data, section) end)
  end
  defp validate_data_against_schema(data, %{"fields" => fields}) do
    validate_fields_data(data, fields)
  end
  defp validate_data_against_schema(_data, _schema), do: []

  defp validate_section_data(data, %{"fields" => fields}) do
    validate_fields_data(data, fields)
  end
  defp validate_section_data(_data, _section), do: []

  defp validate_fields_data(data, fields) do
    Enum.flat_map(fields, fn field -> validate_field_data(data, field) end)
  end

  defp validate_field_data(data, %{"name" => name, "required" => true} = field) do
    case Map.get(data, name) do
      nil -> ["Field '#{field["label"] || name}' is required"]
      "" -> ["Field '#{field["label"] || name}' is required"]
      _ -> validate_field_type(data, field)
    end
  end
  defp validate_field_data(data, field) do
    validate_field_type(data, field)
  end

  defp validate_field_type(data, %{"name" => name, "type" => "number"} = field) do
    case Map.get(data, name) do
      nil -> []
      value when is_number(value) -> validate_number_constraints(value, field)
      value -> 
        case Float.parse(to_string(value)) do
          {number, _} -> validate_number_constraints(number, field)
          :error -> ["Field '#{field["label"] || name}' must be a number"]
        end
    end
  end
  defp validate_field_type(data, %{"name" => name, "type" => "date"} = field) do
    case Map.get(data, name) do
      nil -> []
      value ->
        case Date.from_iso8601(to_string(value)) do
          {:ok, _date} -> []
          {:error, _} -> ["Field '#{field["label"] || name}' must be a valid date"]
        end
    end
  end
  defp validate_field_type(_data, _field), do: []

  defp validate_number_constraints(number, field) do
    errors = []
    
    errors = case Map.get(field, "min") do
      nil -> errors
      min when number >= min -> errors
      min -> ["Field '#{field["label"] || field["name"]}' must be at least #{min}" | errors]
    end
    
    case Map.get(field, "max") do
      nil -> errors
      max when number <= max -> errors
      max -> ["Field '#{field["label"] || field["name"]}' must be at most #{max}" | errors]
    end
  end
end