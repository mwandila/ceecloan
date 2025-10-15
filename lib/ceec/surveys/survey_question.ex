defmodule Ceec.Surveys.SurveyQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ceec.Surveys.{Survey, QuestionResponse}

  @question_types [
    "text",
    "textarea", 
    "select",
    "radio",
    "checkbox",
    "rating",
    "yes_no",
    "number",
    "email",
    "phone"
  ]

  @categories [
    "loan_usage",
    "challenges", 
    "impact",
    "satisfaction",
    "demographics",
    "business_profile",
    "recommendations"
  ]

  schema "survey_questions" do
    field :question_text, :string
    field :question_type, :string
    field :options, :map
    field :required, :boolean, default: false
    field :order_index, :integer
    field :help_text, :string
    field :validation_rules, :map
    field :category, :string

    belongs_to :survey, Survey
    has_many :question_responses, QuestionResponse, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(survey_question, attrs) do
    survey_question
    |> cast(attrs, [
      :survey_id, :question_text, :question_type, :options, :required, 
      :order_index, :help_text, :validation_rules, :category
    ])
    |> validate_required([:survey_id, :question_text, :question_type, :order_index])
    |> validate_inclusion(:question_type, @question_types)
    |> validate_inclusion(:category, @categories)
    |> validate_number(:order_index, greater_than_or_equal_to: 0)
    |> validate_options_for_type()
    |> foreign_key_constraint(:survey_id)
  end

  defp validate_options_for_type(changeset) do
    question_type = get_field(changeset, :question_type)
    options = get_field(changeset, :options)

    case question_type do
      type when type in ["select", "radio", "checkbox"] ->
        if options && is_list(options["choices"]) && length(options["choices"]) > 0 do
          changeset
        else
          add_error(changeset, :options, "must include choices for #{type} questions")
        end

      "rating" ->
        if options && is_integer(options["max_value"]) && options["max_value"] > 0 do
          changeset
        else
          add_error(changeset, :options, "must include max_value for rating questions")
        end

      _ ->
        changeset
    end
  end

  def question_types, do: @question_types
  def categories, do: @categories

  def loan_assessment_template do
    [
      # Loan Usage Questions
      %{
        category: "loan_usage",
        order_index: 1,
        question_text: "How did you primarily use the loan funds?",
        question_type: "select",
        required: true,
        options: %{
          "choices" => [
            "Business expansion/inventory",
            "Equipment purchase", 
            "Working capital",
            "Debt consolidation",
            "Emergency expenses",
            "Other"
          ]
        }
      },
      %{
        category: "loan_usage",
        order_index: 2,
        question_text: "Please provide details about how exactly you used the loan funds",
        question_type: "textarea",
        required: true,
        help_text: "Be as specific as possible about purchases, investments, or expenses"
      },
      %{
        category: "loan_usage", 
        order_index: 3,
        question_text: "Did you use the entire loan amount as planned?",
        question_type: "yes_no",
        required: true
      },

      # Challenges Questions
      %{
        category: "challenges",
        order_index: 4,
        question_text: "What challenges have you faced since receiving the loan?",
        question_type: "checkbox",
        required: false,
        options: %{
          "choices" => [
            "High interest rates",
            "Short repayment period", 
            "Market competition",
            "Supply chain issues",
            "Customer payment delays",
            "Regulatory/licensing issues",
            "Health/personal issues",
            "No major challenges"
          ]
        }
      },
      %{
        category: "challenges",
        order_index: 5,
        question_text: "Please describe your biggest challenge in detail",
        question_type: "textarea",
        required: false
      },

      # Impact Assessment
      %{
        category: "impact",
        order_index: 6,
        question_text: "How many employees did you have before the loan?",
        question_type: "number",
        required: true
      },
      %{
        category: "impact",
        order_index: 7,
        question_text: "How many employees do you have now?",
        question_type: "number", 
        required: true
      },
      %{
        category: "impact",
        order_index: 8,
        question_text: "What was your approximate monthly revenue before the loan? (ZMK)",
        question_type: "number",
        required: true
      },
      %{
        category: "impact",
        order_index: 9,
        question_text: "What is your approximate monthly revenue now? (ZMK)",
        question_type: "number",
        required: true
      },
      %{
        category: "impact",
        order_index: 10,
        question_text: "Rate the overall impact of the loan on your business",
        question_type: "rating",
        required: true,
        options: %{
          "max_value" => 5,
          "labels" => ["Very Negative", "Negative", "Neutral", "Positive", "Very Positive"]
        }
      },

      # Satisfaction
      %{
        category: "satisfaction",
        order_index: 11,
        question_text: "How satisfied are you with the loan application process?",
        question_type: "rating",
        required: true,
        options: %{
          "max_value" => 5,
          "labels" => ["Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied"]
        }
      },
      %{
        category: "satisfaction",
        order_index: 12,
        question_text: "How likely are you to recommend CEEC to other entrepreneurs?",
        question_type: "rating",
        required: true,
        options: %{
          "max_value" => 10,
          "labels" => ["Not at all likely", "", "", "", "", "", "", "", "", "Extremely likely"]
        }
      },

      # Recommendations
      %{
        category: "recommendations",
        order_index: 13,
        question_text: "What improvements would you suggest for CEEC's loan program?",
        question_type: "textarea",
        required: false,
        help_text: "Your suggestions help us improve our services"
      }
    ]
  end
end