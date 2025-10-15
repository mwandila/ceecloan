defmodule Ceec.CeecSurveys do
  @moduledoc """
  The CeecSurveys context manages CEEC funding surveys.
  
  This context handles the creation, updating, and management of surveys
  for citizens seeking economic empowerment funding from the Zambian government.
  """

  import Ecto.Query, warn: false
  alias Ceec.Repo
  alias Ceec.CeecSurveys.Survey

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
  Returns surveys filtered by various criteria.
  """
  def list_surveys(filters) when is_map(filters) do
    Survey
    |> filter_by_status(filters[:status])
    |> filter_by_province(filters[:province])
    |> filter_by_district(filters[:district])
    |> filter_by_business_sector(filters[:business_sector])
    |> filter_by_funding_type(filters[:funding_type])
    |> order_by_date()
    |> Repo.all()
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
  Gets a survey by reference number.
  """
  def get_survey_by_reference(reference_number) do
    Repo.get_by(Survey, reference_number: reference_number)
  end

  @doc """
  Gets a survey by national ID.
  """
  def get_survey_by_national_id(national_id) do
    Repo.get_by(Survey, national_id: national_id)
  end

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

  @doc """
  Submits a survey for review.
  """
  def submit_survey(%Survey{} = survey) do
    attrs = %{
      survey_status: "submitted",
      submitted_at: NaiveDateTime.utc_now()
    }

    update_survey(survey, attrs)
  end

  @doc """
  Marks a survey as reviewed.
  """
  def review_survey(%Survey{} = survey, reviewer_id, approval_status) do
    attrs = %{
      survey_status: "reviewed",
      reviewed_at: NaiveDateTime.utc_now(),
      reviewer_id: reviewer_id,
      approval_status: approval_status
    }

    update_survey(survey, attrs)
  end

  @doc """
  Gets survey statistics.
  """
  def get_survey_stats do
    total = Repo.aggregate(Survey, :count, :id)

    stats_query =
      from s in Survey,
        group_by: s.survey_status,
        select: {s.survey_status, count(s.id)}

    status_counts = Repo.all(stats_query) |> Enum.into(%{})

    province_query =
      from s in Survey,
        where: not is_nil(s.province),
        group_by: s.province,
        select: {s.province, count(s.id)},
        order_by: [desc: count(s.id)],
        limit: 5

    top_provinces = Repo.all(province_query)

    funding_query =
      from s in Survey,
        where: not is_nil(s.funding_type_preferred),
        group_by: s.funding_type_preferred,
        select: {s.funding_type_preferred, count(s.id)}

    funding_types = Repo.all(funding_query) |> Enum.into(%{})

    %{
      total_surveys: total,
      status_breakdown: status_counts,
      top_provinces: top_provinces,
      funding_type_distribution: funding_types,
      draft_count: Map.get(status_counts, "draft", 0),
      submitted_count: Map.get(status_counts, "submitted", 0),
      reviewed_count: Map.get(status_counts, "reviewed", 0)
    }
  end

  @doc """
  Searches surveys by various criteria.
  """
  def search_surveys(search_term) when is_binary(search_term) do
    search_pattern = "%#{search_term}%"

    from(s in Survey,
      where:
        ilike(s.first_name, ^search_pattern) or
          ilike(s.last_name, ^search_pattern) or
          ilike(s.national_id, ^search_pattern) or
          ilike(s.reference_number, ^search_pattern) or
          ilike(s.business_name, ^search_pattern),
      order_by: [desc: s.inserted_at]
    )
    |> Repo.all()
  end

  # Private filter functions

  defp filter_by_status(query, nil), do: query

  defp filter_by_status(query, status) do
    from s in query, where: s.survey_status == ^status
  end

  defp filter_by_province(query, nil), do: query

  defp filter_by_province(query, province) do
    from s in query, where: s.province == ^province
  end

  defp filter_by_district(query, nil), do: query

  defp filter_by_district(query, district) do
    from s in query, where: s.district == ^district
  end

  defp filter_by_business_sector(query, nil), do: query

  defp filter_by_business_sector(query, sector) do
    from s in query, where: s.business_sector == ^sector
  end

  defp filter_by_funding_type(query, nil), do: query

  defp filter_by_funding_type(query, funding_type) do
    from s in query, where: s.funding_type_preferred == ^funding_type
  end

  defp order_by_date(query) do
    from s in query, order_by: [desc: s.inserted_at]
  end

  @doc """
  Gets surveys requiring review.
  """
  def get_surveys_pending_review do
    from(s in Survey,
      where: s.survey_status == "submitted",
      order_by: [asc: s.submitted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets recently completed surveys.
  """
  def get_recent_completed_surveys(limit \\ 10) do
    from(s in Survey,
      where: s.completion_percentage == 100,
      order_by: [desc: s.updated_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Validates if a national ID is already registered.
  """
  def national_id_exists?(national_id) do
    from(s in Survey, where: s.national_id == ^national_id)
    |> Repo.exists?()
  end

  @doc """
  Gets completion rate analytics.
  """
  def get_completion_analytics do
    query =
      from s in Survey,
        select: %{
          avg_completion: avg(s.completion_percentage),
          total_surveys: count(s.id),
          completed_surveys: filter(count(s.id), s.completion_percentage == 100),
          in_progress:
            filter(count(s.id), s.completion_percentage > 0 and s.completion_percentage < 100)
        }

    Repo.one(query) ||
      %{avg_completion: 0, total_surveys: 0, completed_surveys: 0, in_progress: 0}
  end
end
