defmodule Ceec.Surveys.QuestionResponse do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ceec.Surveys.{SurveyResponse, SurveyQuestion}

  schema "question_responses" do
    field :response_value, :string
    field :response_data, :map

    belongs_to :survey_response, SurveyResponse
    belongs_to :question, SurveyQuestion

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question_response, attrs) do
    question_response
    |> cast(attrs, [:survey_response_id, :question_id, :response_value, :response_data])
    |> validate_required([:survey_response_id, :question_id])
    |> validate_response_format()
    |> unique_constraint([:survey_response_id, :question_id])
    |> foreign_key_constraint(:survey_response_id)
    |> foreign_key_constraint(:question_id)
  end

  defp validate_response_format(changeset) do
    response_value = get_field(changeset, :response_value)
    response_data = get_field(changeset, :response_data)

    cond do
      is_nil(response_value) && is_nil(response_data) ->
        add_error(changeset, :response_value, "either response_value or response_data must be provided")
      
      true ->
        changeset
    end
  end

  def format_response(%__MODULE__{} = response) do
    case response.question.question_type do
      "checkbox" ->
        if response.response_data && is_list(response.response_data["selections"]) do
          Enum.join(response.response_data["selections"], ", ")
        else
          response.response_value || ""
        end

      "rating" ->
        value = response.response_value
        max_value = response.question.options["max_value"] || 5
        "#{value}/#{max_value}"

      "yes_no" ->
        case response.response_value do
          "true" -> "Yes"
          "false" -> "No"
          val -> val || ""
        end

      _ ->
        response.response_value || ""
    end
  end

  def numeric_response(%__MODULE__{} = response) do
    case response.question.question_type do
      "rating" -> String.to_integer(response.response_value || "0")
      "number" -> String.to_integer(response.response_value || "0")
      "yes_no" -> if response.response_value == "true", do: 1, else: 0
      _ -> 0
    end
  rescue
    _ -> 0
  end
end