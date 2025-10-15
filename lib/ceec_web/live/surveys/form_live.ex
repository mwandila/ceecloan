defmodule CeecWeb.Surveys.FormLive do
  use CeecWeb, :live_view
  alias Ceec.CeecSurveys
  alias Ceec.CeecSurveys.Survey
  import CeecWeb.SurveyComponents
  import CeecWeb.SurveyComponents.PersonalInfoComponent
  import CeecWeb.SurveyComponents.AddressComponent
  import CeecWeb.SurveyComponents.BusinessComponent
  import CeecWeb.SurveyComponents.FundingComponent
  import CeecWeb.SurveyComponents.LoanFollowupComponent

  @steps [
    %{id: 1, name: "Personal Info", title: "Personal Information"},
    %{id: 2, name: "Address", title: "Address & Location"},
    %{id: 3, name: "Business", title: "Business Details"},
    %{id: 4, name: "Funding", title: "Funding Requirements"},
    %{id: 5, name: "Loan Survey", title: "Loan Follow-up Questionnaire"},
    %{id: 6, name: "Review", title: "Review & Submit"}
  ]

  def mount(_params, _session, socket) do
    changeset = CeecSurveys.change_survey(%Survey{})

    socket =
      socket
      |> assign(:survey, %Survey{})
      |> assign(:changeset, changeset)
      |> assign(:current_step, 1)
      |> assign(:steps, @steps)
      |> assign(:is_submitting, false)
      |> assign(:page_title, "CEEC Funding Survey")

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    case params do
      %{"id" => id} ->
        survey = CeecSurveys.get_survey!(id)
        changeset = CeecSurveys.change_survey(survey)

        socket =
          socket
          |> assign(:survey, survey)
          |> assign(:changeset, changeset)
          |> assign(:page_title, "Edit CEEC Survey - #{survey.reference_number}")

        {:noreply, socket}

      %{"reference" => reference} ->
        case CeecSurveys.get_survey_by_reference(reference) do
          nil ->
            socket = put_flash(socket, :error, "Survey not found")
            {:noreply, push_navigate(socket, to: ~p"/ceec-survey")}

          survey ->
            changeset = CeecSurveys.change_survey(survey)

            socket =
              socket
              |> assign(:survey, survey)
              |> assign(:changeset, changeset)
              |> assign(:page_title, "CEEC Survey - #{survey.reference_number}")

            {:noreply, socket}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"survey" => survey_params}, socket) do
    changeset =
      socket.assigns.survey
      |> CeecSurveys.change_survey(survey_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("next_step", _params, socket) do
    current_step = socket.assigns.current_step
    total_steps = length(@steps)

    if current_step < total_steps do
      {:noreply, assign(socket, :current_step, current_step + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("prev_step", _params, socket) do
    current_step = socket.assigns.current_step

    if current_step > 1 do
      {:noreply, assign(socket, :current_step, current_step - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("save_draft", %{"survey" => survey_params}, socket) do
    survey = socket.assigns.survey

    case save_survey_draft(survey, survey_params) do
      {:ok, updated_survey} ->
        socket =
          socket
          |> assign(:survey, updated_survey)
          |> put_flash(
            :info,
            "Draft saved successfully! Reference: #{updated_survey.reference_number}"
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("submit_survey", %{"survey" => survey_params}, socket) do
    socket = assign(socket, :is_submitting, true)
    survey = socket.assigns.survey

    # Add completion status to params
    final_params = Map.put(survey_params, "survey_status", "submitted")

    case save_and_submit_survey(survey, final_params) do
      {:ok, updated_survey} ->
        socket =
          socket
          |> assign(:survey, updated_survey)
          |> put_flash(
            :info,
            "Survey submitted successfully! Reference: #{updated_survey.reference_number}"
          )
          |> push_navigate(to: ~p"/ceec-survey/success/#{updated_survey.reference_number}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign(:changeset, changeset)
          |> assign(:is_submitting, false)
          |> put_flash(:error, "Please correct the errors below")

        {:noreply, socket}
    end
  end

  def handle_event("jump_to_step", %{"step" => step_str}, socket) do
    step = String.to_integer(step_str)
    total_steps = length(@steps)

    if step >= 1 and step <= total_steps do
      {:noreply, assign(socket, :current_step, step)}
    else
      {:noreply, socket}
    end
  end

  defp save_survey_draft(survey, params) do
    if survey.id do
      CeecSurveys.update_survey(survey, params)
    else
      CeecSurveys.create_survey(params)
    end
  end

  defp save_and_submit_survey(survey, params) do
    case save_survey_draft(survey, params) do
      {:ok, updated_survey} ->
        CeecSurveys.submit_survey(updated_survey)

      error ->
        error
    end
  end

  defp get_completion_percentage(changeset) do
    changeset.data.completion_percentage || 0
  end

  defp can_go_forward?(current_step, changeset) do
    case current_step do
      1 ->
        # Personal info step - require basic fields
        required_fields = [:first_name, :last_name, :national_id, :phone_number]

        Enum.all?(required_fields, fn field ->
          value = Ecto.Changeset.get_field(changeset, field)
          value != nil && value != ""
        end)

      4 ->
        # Funding step - require funding details
        required_fields = [:funding_purpose, :funding_amount_requested, :funding_type_preferred]

        Enum.all?(required_fields, fn field ->
          value = Ecto.Changeset.get_field(changeset, field)
          value != nil && value != ""
        end)

      5 ->
        has_received_loan = Ecto.Changeset.get_field(changeset, :has_received_loan)

        if has_received_loan do
          required_fields = [
            :loan_disbursement_date,
            :loan_amount_received,
            :loan_usage_description,
            :loan_repayment_status,
            :loan_satisfaction_rating
          ]

          Enum.all?(required_fields, fn field ->
            value = Ecto.Changeset.get_field(changeset, field)
            value != nil && value != ""
          end) and
            match?([_ | _], Ecto.Changeset.get_field(changeset, :loan_usage_categories) || [])
        else
          true
        end

      _ ->
        true
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-8">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">CEEC Funding Survey</h1>

          <p class="text-lg text-gray-600">Citizens Economic Empowerment Commission</p>

          <p class="text-sm text-gray-500 mt-2">
            Complete this survey to apply for government funding opportunities
          </p>
        </div>
        <!-- Progress Indicator -->
        <.survey_progress
          current_step={@current_step}
          total_steps={length(@steps)}
          completion_percentage={get_completion_percentage(@changeset)}
        />
        <!-- Step Navigation -->
        <div class="bg-white rounded-lg shadow-sm p-4 mb-6">
          <nav class="flex space-x-8 overflow-x-auto">
            <%= for step <- @steps do %>
              <button
                phx-click="jump_to_step"
                phx-value-step={step.id}
                class={[
                  "whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm transition-colors",
                  if(@current_step == step.id,
                    do: "border-blue-500 text-blue-600",
                    else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  )
                ]}
              >
                <span class="flex items-center">
                  <span class={[
                    "flex-shrink-0 w-6 h-6 rounded-full mr-2 flex items-center justify-center text-xs font-semibold",
                    if(@current_step == step.id,
                      do: "bg-blue-600 text-white",
                      else: "bg-gray-200 text-gray-600"
                    )
                  ]}>
                    {step.id}
                  </span>
                  {step.name}
                </span>
              </button>
            <% end %>
          </nav>
        </div>
        <!-- Form -->
        <.form
          :let={f}
          for={@changeset}
          phx-change="validate"
          phx-submit="submit_survey"
          class="space-y-6"
        >
          <%= case @current_step do %>
            <% 1 -> %>
              <.personal_info_form form={f} />
              <.address_form form={f} />
            <% 2 -> %>
              <div class="bg-white p-6 rounded-lg shadow-md">
                <div class="mb-6">
                  <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
                    <.icon name="hero-academic-cap" class="w-5 h-5 mr-2 text-purple-600" />
                    Education & Employment
                  </h3>

                  <p class="text-sm text-gray-600">
                    Tell us about your educational background and current employment status.
                  </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <.input
                    field={f[:education_level]}
                    type="select"
                    label="Highest Education Level"
                    options={[
                      {"Select Education Level", ""},
                      {"Primary", "Primary"},
                      {"Secondary", "Secondary"},
                      {"Certificate", "Certificate"},
                      {"Diploma", "Diploma"},
                      {"Bachelor's Degree", "Bachelor's Degree"},
                      {"Master's Degree", "Master's Degree"},
                      {"Doctorate", "Doctorate"},
                      {"Other", "Other"}
                    ]}
                  />
                  <.input
                    field={f[:employment_status]}
                    type="select"
                    label="Employment Status"
                    options={[
                      {"Select Status", ""},
                      {"Employed", "Employed"},
                      {"Self-employed", "Self-employed"},
                      {"Unemployed", "Unemployed"},
                      {"Student", "Student"},
                      {"Retired", "Retired"}
                    ]}
                  />
                  <.input
                    field={f[:current_occupation]}
                    label="Current Occupation"
                    placeholder="e.g., Teacher, Farmer, Student"
                  />
                  <.input
                    field={f[:monthly_income]}
                    type="number"
                    label="Monthly Income (ZMW)"
                    placeholder="0.00"
                    step="0.01"
                    min="0"
                  />
                  <.input
                    field={f[:dependents_count]}
                    type="number"
                    label="Number of Dependents"
                    placeholder="0"
                    min="0"
                  />
                </div>
              </div>
            <% 3 -> %>
              <.business_info_form form={f} />
            <% 4 -> %>
              <.funding_requirements_form form={f} />
              <div class="bg-white p-6 rounded-lg shadow-md">
                <div class="mb-6">
                  <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
                    <.icon name="hero-building-library" class="w-5 h-5 mr-2 text-blue-600" />
                    Banking Information
                  </h3>

                  <p class="text-sm text-gray-600">
                    Provide your banking details for potential funding disbursement.
                  </p>
                </div>

                <div class="mb-4">
                  <label class="flex items-center text-sm font-medium text-gray-700 mb-4">
                    <input
                      type="checkbox"
                      name="survey[has_bank_account]"
                      value="true"
                      checked={Phoenix.HTML.Form.input_value(f, :has_bank_account)}
                      class="mr-2 rounded border-gray-300"
                    /> I have a bank account
                  </label>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <.input
                    field={f[:bank_name]}
                    label="Bank Name"
                    placeholder="Select or enter your bank name"
                  />
                  <.input
                    field={f[:account_number]}
                    label="Account Number"
                    placeholder="Enter your account number"
                  />
                </div>
              </div>
            <% 5 -> %>
              <.loan_impact_form form={f} />
            <% 6 -> %>
              <!-- Review Step -->
              <div class="bg-white p-6 rounded-lg shadow-md">
                <div class="mb-6">
                  <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
                    <.icon name="hero-document-check" class="w-5 h-5 mr-2 text-green-600" />
                    Review Your Information
                  </h3>

                  <p class="text-sm text-gray-600">
                    Please review all information before submitting your survey.
                  </p>
                </div>

                <%= if Phoenix.HTML.Form.input_value(f, :reference_number) do %>
                  <div class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-md">
                    <p class="text-sm text-blue-700">
                      <strong>Reference Number:</strong> {Phoenix.HTML.Form.input_value(
                        f,
                        :reference_number
                      )}
                    </p>
                  </div>
                <% end %>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                  <div>
                    <h4 class="font-semibold text-gray-900 mb-2">Personal Information</h4>

                    <p>
                      <strong>Name:</strong> {Phoenix.HTML.Form.input_value(f, :first_name)} {Phoenix.HTML.Form.input_value(
                        f,
                        :last_name
                      )}
                    </p>

                    <p>
                      <strong>National ID:</strong> {Phoenix.HTML.Form.input_value(f, :national_id)}
                    </p>

                    <p><strong>Phone:</strong> {Phoenix.HTML.Form.input_value(f, :phone_number)}</p>

                    <p><strong>Province:</strong> {Phoenix.HTML.Form.input_value(f, :province)}</p>
                  </div>

                  <div>
                    <h4 class="font-semibold text-gray-900 mb-2">Funding Request</h4>

                    <p>
                      <strong>Amount:</strong>
                      ZMW {Phoenix.HTML.Form.input_value(f, :funding_amount_requested)}
                    </p>

                    <p>
                      <strong>Type:</strong> {Phoenix.HTML.Form.input_value(
                        f,
                        :funding_type_preferred
                      )}
                    </p>

                    <p>
                      <strong>Purpose:</strong> {Phoenix.HTML.Form.input_value(f, :funding_purpose)
                      |> to_string()
                      |> String.slice(0, 100)}...
                    </p>
                  </div>
                </div>

                <div class="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-md">
                  <div class="flex">
                    <.icon
                      name="hero-exclamation-triangle"
                      class="w-5 h-5 text-yellow-400 mr-2 mt-0.5"
                    />
                    <div class="text-sm text-yellow-700">
                      <p class="font-semibold">Important Notice</p>

                      <p>
                        By submitting this survey, you confirm that all information provided is accurate and complete.
                        False information may result in disqualification from funding opportunities.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
          <% end %>
          <!-- Navigation -->
          <.survey_navigation
            can_go_back={@current_step > 1}
            can_go_forward={can_go_forward?(@current_step, @changeset)}
            is_last_step={@current_step == length(@steps)}
            is_submitting={@is_submitting}
          />
        </.form>
      </div>
    </div>
    """
  end
end
