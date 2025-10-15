defmodule Ceec.Forms.Form do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forms" do
    field :name, :string
    field :description, :string
    field :form_type, :string  # baseline, monitoring, evaluation, endline
    field :version, :string, default: "1.0"
    field :status, :string, default: "draft"
    field :language, :string, default: "en"
    
    # Form configuration stored as JSON
    field :form_schema, :map  # JSON structure defining the form fields
    field :settings, :map     # Additional form settings
    
    # Metadata
    field :created_by, :string
    field :tags, {:array, :string}
    
    # Relationships
    belongs_to :project, Ceec.Projects.Project
    has_many :form_submissions, Ceec.DataCollection.FormSubmission

    timestamps()
  end

  @doc false
  def changeset(form, attrs) do
    form
    |> cast(attrs, [
      :name, :description, :form_type, :version, :status, :language,
      :form_schema, :settings, :created_by, :tags, :project_id
    ])
    |> validate_required([:name, :form_type, :created_by, :project_id])
    |> validate_inclusion(:form_type, [
      "baseline", "monitoring", "evaluation", "endline", "survey", "interview", "other"
    ])
    |> validate_inclusion(:status, ["draft", "published", "archived"])
    |> validate_format(:version, ~r/^\d+\.\d+$/, message: "must be in format X.Y")
    |> foreign_key_constraint(:project_id)
    |> validate_form_schema()
  end

  defp validate_form_schema(changeset) do
    case get_field(changeset, :form_schema) do
      nil -> changeset
      schema when is_map(schema) ->
        if valid_form_schema?(schema) do
          changeset
        else
          add_error(changeset, :form_schema, "invalid form schema structure")
        end
      _ ->
        add_error(changeset, :form_schema, "must be a valid JSON object")
    end
  end

  # Basic validation of form schema structure
  defp valid_form_schema?(%{"sections" => sections}) when is_list(sections) do
    Enum.all?(sections, &valid_section?/1)
  end
  defp valid_form_schema?(%{"fields" => fields}) when is_list(fields) do
    Enum.all?(fields, &valid_field?/1)
  end
  defp valid_form_schema?(_), do: false

  defp valid_section?(%{"name" => name, "fields" => fields}) 
       when is_binary(name) and is_list(fields) do
    Enum.all?(fields, &valid_field?/1)
  end
  defp valid_section?(_), do: false

  defp valid_field?(%{"name" => name, "type" => type}) 
       when is_binary(name) and is_binary(type) do
    type in ["text", "number", "date", "select", "multiselect", "textarea", 
             "file", "photo", "gps", "signature", "checkbox", "radio"]
  end
  defp valid_field?(_), do: false

  @doc """
  Returns the default form schema template for different form types.
  """
  def default_schema(form_type) do
    case form_type do
      "baseline" -> baseline_form_schema()
      "monitoring" -> monitoring_form_schema()
      "evaluation" -> evaluation_form_schema()
      "survey" -> survey_form_schema()
      _ -> basic_form_schema()
    end
  end

  defp baseline_form_schema do
    %{
      "sections" => [
        %{
          "name" => "Beneficiary Information",
          "fields" => [
            %{
              "name" => "beneficiary_id",
              "label" => "Beneficiary ID",
              "type" => "text",
              "required" => true
            },
            %{
              "name" => "interview_date",
              "label" => "Interview Date",
              "type" => "date",
              "required" => true
            },
            %{
              "name" => "location",
              "label" => "Location",
              "type" => "gps",
              "required" => false
            }
          ]
        },
        %{
          "name" => "Demographics",
          "fields" => [
            %{
              "name" => "age",
              "label" => "Age",
              "type" => "number",
              "required" => true,
              "min" => 0,
              "max" => 120
            },
            %{
              "name" => "gender",
              "label" => "Gender",
              "type" => "select",
              "required" => true,
              "options" => ["Male", "Female", "Other", "Prefer not to say"]
            },
            %{
              "name" => "education_level",
              "label" => "Education Level",
              "type" => "select",
              "required" => false,
              "options" => ["None", "Primary", "Secondary", "Tertiary", "Vocational"]
            }
          ]
        }
      ]
    }
  end

  defp monitoring_form_schema do
    %{
      "sections" => [
        %{
          "name" => "Progress Tracking",
          "fields" => [
            %{
              "name" => "reporting_period",
              "label" => "Reporting Period",
              "type" => "select",
              "required" => true,
              "options" => ["Monthly", "Quarterly", "Semi-annual", "Annual"]
            },
            %{
              "name" => "activities_completed",
              "label" => "Activities Completed",
              "type" => "multiselect",
              "required" => false,
              "options" => []
            },
            %{
              "name" => "challenges_faced",
              "label" => "Challenges Faced",
              "type" => "textarea",
              "required" => false
            }
          ]
        }
      ]
    }
  end

  defp evaluation_form_schema do
    %{
      "sections" => [
        %{
          "name" => "Impact Assessment",
          "fields" => [
            %{
              "name" => "outcome_achieved",
              "label" => "Was the intended outcome achieved?",
              "type" => "radio",
              "required" => true,
              "options" => ["Yes", "Partially", "No"]
            },
            %{
              "name" => "satisfaction_rating",
              "label" => "Satisfaction Rating (1-5)",
              "type" => "select",
              "required" => true,
              "options" => ["1", "2", "3", "4", "5"]
            },
            %{
              "name" => "recommendations",
              "label" => "Recommendations for Improvement",
              "type" => "textarea",
              "required" => false
            }
          ]
        }
      ]
    }
  end

  defp survey_form_schema do
    %{
      "sections" => [
        %{
          "name" => "Survey Questions",
          "fields" => [
            %{
              "name" => "respondent_consent",
              "label" => "I consent to participate in this survey",
              "type" => "checkbox",
              "required" => true
            },
            %{
              "name" => "question_1",
              "label" => "Sample Question 1",
              "type" => "text",
              "required" => false
            }
          ]
        }
      ]
    }
  end

  defp basic_form_schema do
    %{
      "sections" => [
        %{
          "name" => "General Information",
          "fields" => [
            %{
              "name" => "data_collector",
              "label" => "Data Collector Name",
              "type" => "text",
              "required" => true
            },
            %{
              "name" => "collection_date",
              "label" => "Data Collection Date",
              "type" => "date",
              "required" => true
            }
          ]
        }
      ]
    }
  end
end