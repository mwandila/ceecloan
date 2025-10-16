defmodule Ceec.Surveys do
  @moduledoc """
  The Surveys context.
  """

  import Ecto.Query, warn: false
  alias Ceec.Repo

  alias Ceec.Surveys.{Survey, SurveyResponse, SurveyQuestion, QuestionResponse, SurveyInvitation}
  alias Ceec.Finance.Loan

  @doc """
  Returns the list of surveys.

  ## Examples

      iex> list_surveys()
      [%Survey{}, ...]

  """
  def list_surveys do
    Repo.all(Survey)
  end

  @doc """
  Gets a single survey.

  Raises `Ecto.NoResultsError` if the Survey does not exist.

  ## Examples

      iex> get_survey!(123)
      %Survey{}

      iex> get_survey!(456)
      ** (Ecto.NoResultsError)

  """
  def get_survey!(id), do: Repo.get!(Survey, id)

  @doc """
  Gets a single survey.

  Returns `nil` if the Survey does not exist.

  ## Examples

      iex> get_survey(123)
      %Survey{}

      iex> get_survey(456)
      nil

  """
  def get_survey(id), do: Repo.get(Survey, id)

  @doc """
  Creates a survey.

  ## Examples

      iex> create_survey(%{field: value})
      {:ok, %Survey{}}

      iex> create_survey(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_survey(attrs \\ %{}) do
    %Survey{}
    |> Survey.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a survey.

  ## Examples

      iex> update_survey(survey, %{field: new_value})
      {:ok, %Survey{}}

      iex> update_survey(survey, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_survey(%Survey{} = survey, attrs) do
    survey
    |> Survey.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a survey.

  ## Examples

      iex> delete_survey(survey)
      {:ok, %Survey{}}

      iex> delete_survey(survey)
      {:error, %Ecto.Changeset{}}

  """
  def delete_survey(%Survey{} = survey) do
    Repo.delete(survey)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking survey changes.

  ## Examples

      iex> change_survey(survey)
      %Ecto.Changeset{data: %Survey{}}

  """
  def change_survey(%Survey{} = survey, attrs \\ %{}) do
    Survey.changeset(survey, attrs)
  end

  # Survey Response functions

  @doc """
  Returns the list of survey responses for a given survey.
  """
  def list_survey_responses(survey_id) do
    from(r in SurveyResponse, where: r.survey_id == ^survey_id)
    |> Repo.all()
  end

  @doc """
  Gets a single survey response.
  """
  def get_survey_response!(id), do: Repo.get!(SurveyResponse, id)

  @doc """
  Creates a survey response.
  """
  def create_survey_response(attrs \\ %{}) do
    %SurveyResponse{}
    |> SurveyResponse.changeset(attrs)
    |> Repo.insert()
  end
  
  @doc """
  Creates a minimal survey response for dynamic question-based surveys.
  """
  def create_minimal_survey_response(attrs \\ %{}) do
    %SurveyResponse{}
    |> SurveyResponse.minimal_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a survey response.
  """
  def update_survey_response(%SurveyResponse{} = survey_response, attrs) do
    survey_response
    |> SurveyResponse.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a survey response.
  """
  def delete_survey_response(%SurveyResponse{} = survey_response) do
    Repo.delete(survey_response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking survey response changes.
  """
  def change_survey_response(%SurveyResponse{} = survey_response, attrs \\ %{}) do
    SurveyResponse.changeset(survey_response, attrs)
  end

  @doc """
  Returns the list of active surveys.
  """
  def list_active_surveys do
    from(s in Survey, where: s.status == "active")
    |> Repo.all()
  end

  @doc """
  Gets the total count of survey responses across all surveys.
  """
  def get_total_responses_count do
    from(r in SurveyResponse, select: count(r.id))
    |> Repo.one()
  end

  @doc """
  Gets the total count of surveys.
  """
  def get_total_surveys_count do
    from(s in Survey, select: count(s.id))
    |> Repo.one()
  end

  @doc """
  Lists survey responses with optional filtering
  """
  def list_survey_responses_with_filters(filters \\ %{}) do
    from(r in SurveyResponse,
      join: s in Survey, on: r.survey_id == s.id,
      select: %{
        id: r.id,
        beneficiary_name: r.beneficiary_name,
        visit_type: r.visit_type,
        visit_date: r.visit_date,
        interviewer_name: r.interviewer_name,
        province: r.province,
        district: r.district,
        business_type: r.business_type,
        loan_amount: r.loan_amount,
        project_rating: r.project_rating,
        survey_title: s.title,
        survey_id: r.survey_id,
        submitted_at: r.inserted_at
      },
      order_by: [desc: r.inserted_at]
    )
    |> apply_filters(filters)
    |> Repo.all()
  end
  
  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {"search", ""}, query -> query
      {"search", search}, query ->
        search_term = "%#{search}%"
        from(r in query,
          where: ilike(r.beneficiary_name, ^search_term) or
                 ilike(r.province, ^search_term) or
                 ilike(r.district, ^search_term) or
                 ilike(r.interviewer_name, ^search_term)
        )
      
      {"date_from", ""}, query -> query
      {"date_from", date_from}, query ->
        case Date.from_iso8601(date_from) do
          {:ok, date} -> from(r in query, where: r.visit_date >= ^date)
          _ -> query
        end
      
      {"date_to", ""}, query -> query  
      {"date_to", date_to}, query ->
        case Date.from_iso8601(date_to) do
          {:ok, date} -> from(r in query, where: r.visit_date <= ^date)
          _ -> query
        end
      
      _, query -> query
    end)
  end
  
  @doc """
  Gets survey responses statistics
  """
  def get_survey_responses_stats do
    total_responses = Repo.aggregate(SurveyResponse, :count)
    
    recent_responses = from(r in SurveyResponse, where: r.inserted_at >= ago(7, "day"))
                      |> Repo.aggregate(:count)
    
    avg_rating = from(r in SurveyResponse, 
                     where: not is_nil(r.project_rating),
                     select: avg(r.project_rating)
                 )
                 |> Repo.one()
                 |> case do
                   nil -> 0.0
                   rating -> Float.round(rating, 2)
                 end
    
    by_visit_type = from(r in SurveyResponse,
                        group_by: r.visit_type,
                        select: {r.visit_type, count(r.id)}
                    )
                    |> Repo.all()
                    |> Enum.into(%{})
    
    %{
      total_responses: total_responses,
      recent_responses: recent_responses,
      average_project_rating: avg_rating,
      responses_by_visit_type: by_visit_type
    }
  end

  @doc """
  Gets survey statistics including total responses, completion rates, etc.
  """
  def get_survey_stats(survey_id) do
    responses = list_survey_responses(survey_id)
    total_responses = length(responses)
    
    satisfaction_avg = if total_responses > 0 do
      responses
      |> Enum.filter(& &1.overall_satisfaction)
      |> Enum.map(& &1.overall_satisfaction)
      |> case do
        [] -> 0.0
        ratings -> Enum.sum(ratings) / length(ratings)
      end
    else
      0.0
    end

    recommendations = responses |> Enum.count(& &1.would_recommend == true)
    
    %{
      total_responses: total_responses,
      average_satisfaction: Float.round(satisfaction_avg, 2),
      recommendation_rate: if(total_responses > 0, do: Float.round(recommendations / total_responses * 100, 1), else: 0)
    }
  end

  # Dynamic Survey Questions functions

  @doc """
  Gets all questions for a survey ordered by order_index.
  """
  def get_survey_questions(survey_id) do
    from(q in SurveyQuestion, 
      where: q.survey_id == ^survey_id,
      order_by: q.order_index
    )
    |> Repo.all()
  end

  @doc """
  Gets a survey with its questions preloaded.
  """
  def get_survey_with_questions!(survey_id) do
    Survey
    |> where([s], s.id == ^survey_id)
    |> preload([s], questions: ^from(q in SurveyQuestion, order_by: q.order_index))
    |> Repo.one!()
  end

  @doc """
  Creates a survey question.
  """
  def create_survey_question(attrs \\ %{}) do
    %SurveyQuestion{}
    |> SurveyQuestion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a survey question.
  """
  def update_survey_question(%SurveyQuestion{} = question, attrs) do
    question
    |> SurveyQuestion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a survey question.
  """
  def delete_survey_question(%SurveyQuestion{} = question) do
    Repo.delete(question)
  end

  @doc """
  Creates a survey with predefined loan assessment questions.
  """
  def create_loan_assessment_survey(attrs \\ %{}) do
    survey_attrs = Map.merge(%{
      "title" => "Loan Impact Assessment Survey",
      "description" => "Comprehensive assessment of loan usage, challenges, and impact",
      "status" => "active",
      "created_by" => "System"
    }, attrs)

    Repo.transaction(fn ->
      with {:ok, survey} <- create_survey(survey_attrs) do
        # Create questions from template
        questions = SurveyQuestion.loan_assessment_template()
        
        Enum.each(questions, fn question_attrs ->
          question_attrs = Map.put(question_attrs, :survey_id, survey.id)
          create_survey_question(question_attrs)
        end)
        
        survey
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Creates or updates a question response.
  """
  def upsert_question_response(survey_response_id, question_id, response_attrs) do
    case Repo.get_by(QuestionResponse, survey_response_id: survey_response_id, question_id: question_id) do
      nil ->
        %QuestionResponse{}
        |> QuestionResponse.changeset(Map.merge(response_attrs, %{
          survey_response_id: survey_response_id,
          question_id: question_id
        }))
        |> Repo.insert()
        
      existing_response ->
        existing_response
        |> QuestionResponse.changeset(response_attrs)
        |> Repo.update()
    end
  end

  @doc """
  Gets survey response with question responses preloaded.
  """
  def get_survey_response_with_answers!(survey_response_id) do
    SurveyResponse
    |> where([sr], sr.id == ^survey_response_id)
    |> preload([
      question_responses: [question: []],
      survey: [questions: ^from(q in SurveyQuestion, order_by: q.order_index)]
    ])
    |> Repo.one!()
  end

  @doc """
  Submits a survey response (marks it as completed).
  """
  def submit_survey_response(%SurveyResponse{} = survey_response) do
    survey_response
    |> SurveyResponse.changeset(%{
      completion_status: "completed",
      submitted_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  @doc """
  Gets loan assessment analytics from dynamic survey responses.
  """
  def get_loan_assessment_analytics(survey_id) do
    questions = get_survey_questions(survey_id)
    
    # Get completed responses
    completed_responses = from(sr in SurveyResponse,
      where: sr.survey_id == ^survey_id and sr.completion_status == "completed",
      preload: [question_responses: [question: []]]
    )
    |> Repo.all()
    
    total_responses = length(completed_responses)
    
    if total_responses == 0 do
      %{
        total_responses: 0,
        loan_usage_breakdown: %{},
        common_challenges: [],
        impact_metrics: %{},
        satisfaction_scores: %{}
      }
    else
      %{
        total_responses: total_responses,
        loan_usage_breakdown: analyze_loan_usage(completed_responses),
        common_challenges: analyze_challenges(completed_responses),
        impact_metrics: analyze_impact(completed_responses),
        satisfaction_scores: analyze_satisfaction(completed_responses)
      }
    end
  end
  
  defp analyze_loan_usage(responses) do
    responses
    |> Enum.flat_map(& &1.question_responses)
    |> Enum.filter(&(&1.question.category == "loan_usage" and &1.question.question_type in ["select", "radio"]))
    |> Enum.group_by(& &1.response_value)
    |> Enum.map(fn {usage, responses} -> {usage, length(responses)} end)
    |> Enum.into(%{})
  end
  
  defp analyze_challenges(responses) do
    responses
    |> Enum.flat_map(& &1.question_responses)
    |> Enum.filter(&(&1.question.category == "challenges" and &1.question.question_type == "checkbox"))
    |> Enum.flat_map(fn response ->
      if response.response_data && response.response_data["selections"] do
        response.response_data["selections"]
      else
        [response.response_value]
      end
    end)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_, count} -> count end, :desc)
    |> Enum.take(10)
  end
  
  defp analyze_impact(responses) do
    impact_responses = responses
    |> Enum.flat_map(& &1.question_responses)
    |> Enum.filter(&(&1.question.category == "impact"))
    |> Enum.group_by(&(&1.question.question_text))
    
    %{
      employment_change: calculate_average_change(impact_responses["How many employees did you have before the loan?"], impact_responses["How many employees do you have now?"]),
      revenue_change: calculate_average_change(impact_responses["What was your approximate monthly revenue before the loan? (ZMK)"], impact_responses["What is your approximate monthly revenue now? (ZMK)"]),
      business_impact_rating: calculate_average_rating(impact_responses["Rate the overall impact of the loan on your business"])
    }
  end
  
  defp analyze_satisfaction(responses) do
    satisfaction_responses = responses
    |> Enum.flat_map(& &1.question_responses)
    |> Enum.filter(&(&1.question.category == "satisfaction" and &1.question.question_type == "rating"))
    |> Enum.group_by(&(&1.question.question_text))
    
    satisfaction_responses
    |> Enum.map(fn {question, responses} ->
      avg_score = calculate_average_rating(responses)
      {question, avg_score}
    end)
    |> Enum.into(%{})
  end
  
  defp calculate_average_change(before_responses, after_responses) when is_list(before_responses) and is_list(after_responses) do
    before_values = Enum.map(before_responses, &(String.to_integer(&1.response_value || "0")))
    after_values = Enum.map(after_responses, &(String.to_integer(&1.response_value || "0")))
    
    if length(before_values) > 0 and length(after_values) > 0 do
      avg_before = Enum.sum(before_values) / length(before_values)
      avg_after = Enum.sum(after_values) / length(after_values)
      Float.round(avg_after - avg_before, 2)
    else
      0.0
    end
  rescue
    _ -> 0.0
  end
  
  defp calculate_average_change(_, _), do: 0.0
  
  defp calculate_average_rating(responses) when is_list(responses) do
    ratings = responses
    |> Enum.map(&(String.to_integer(&1.response_value || "0")))
    |> Enum.filter(&(&1 > 0))
    
    if length(ratings) > 0 do
      Float.round(Enum.sum(ratings) / length(ratings), 2)
    else
      0.0
    end
  rescue
    _ -> 0.0
  end
  
  defp calculate_average_rating(_), do: 0.0

  # Survey Distribution functions

  @doc """
  Distributes a survey to all disbursed loan holders in a project.
  """
  def distribute_survey_to_project(%Survey{} = survey, project_id) do
    # Get all disbursed loans for the project
    disbursed_loans = from(l in Loan,
      where: l.project_id == ^project_id and l.status == "disbursed",
      preload: [:borrower, :project]
    )
    |> Repo.all()

    if length(disbursed_loans) == 0 do
      {:error, "No disbursed loans found for this project"}
    else
      # Create invitations for each disbursed loan holder
      invitations = Enum.map(disbursed_loans, fn loan ->
        create_survey_invitation(%{
          survey_id: survey.id,
          loan_id: loan.id,
          project_id: project_id,
          recipient_email: (loan.borrower && loan.borrower.email) || loan.email,
          recipient_name: (loan.borrower && loan.borrower.name) || loan.applicant_name || "#{loan.first_name} #{loan.last_name}",
          recipient_phone: (loan.borrower && loan.borrower.phone) || loan.phone,
          status: "sent"
        })
      end)

      # Check for any failures
      failed_invitations = Enum.filter(invitations, fn
        {:error, _} -> true
        _ -> false
      end)

      successful_invitations = Enum.filter(invitations, fn
        {:ok, _} -> true
        _ -> false
      end)

      # Update survey status to active if it was draft
      if survey.status == "draft" do
        update_survey(survey, %{status: "active"})
      end

      {
        :ok,
        %{
          total_sent: length(successful_invitations),
          failed: length(failed_invitations),
          invitations: successful_invitations
        }
      }
    end
  end

  @doc """
  Creates a survey invitation.
  """
  def create_survey_invitation(attrs \\ %{}) do
    %SurveyInvitation{}
    |> SurveyInvitation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a survey invitation by token.
  """
  def get_survey_invitation_by_token(token) do
    from(si in SurveyInvitation,
      where: si.token == ^token and si.status != "expired" and si.expires_at > ^DateTime.utc_now(),
      preload: [:survey, :loan, :project]
    )
    |> Repo.one()
  end

  @doc """
  Gets survey invitations for a survey.
  """
  def get_survey_invitations(survey_id) do
    from(si in SurveyInvitation,
      where: si.survey_id == ^survey_id,
      preload: [:loan, :project],
      order_by: [desc: si.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Updates a survey invitation status.
  """
  def update_survey_invitation(%SurveyInvitation{} = invitation, attrs) do
    invitation
    |> SurveyInvitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Marks a survey invitation as responded when a response is submitted.
  """
  def mark_invitation_responded(invitation_token, survey_response_id) do
    case get_survey_invitation_by_token(invitation_token) do
      nil -> {:error, "Invalid or expired invitation"}
      invitation ->
        update_survey_invitation(invitation, %{
          status: "responded",
          response_id: survey_response_id,
          responded_at: DateTime.utc_now()
        })
    end
  end

  @doc """
  Gets survey distribution statistics.
  """
  def get_survey_distribution_stats(survey_id) do
    invitations = get_survey_invitations(survey_id)
    total_sent = length(invitations)
    
    responded = Enum.count(invitations, &(&1.status == "responded"))
    expired = Enum.count(invitations, &(&1.status == "expired"))
    pending = Enum.count(invitations, &(&1.status == "sent"))
    
    response_rate = if total_sent > 0, do: Float.round(responded / total_sent * 100, 1), else: 0.0
    
    %{
      total_sent: total_sent,
      responded: responded,
      pending: pending,
      expired: expired,
      response_rate: response_rate
    }
  end

  @doc """
  Expires old survey invitations (can be run periodically).
  """
  def expire_old_invitations do
    now = DateTime.utc_now()
    
    from(si in SurveyInvitation,
      where: si.expires_at <= ^now and si.status == "sent"
    )
    |> Repo.update_all(set: [status: "expired", updated_at: now])
  end
end
