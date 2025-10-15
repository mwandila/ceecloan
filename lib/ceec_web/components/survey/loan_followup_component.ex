defmodule CeecWeb.SurveyComponents.LoanFollowupComponent do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML.Form
  import CeecWeb.CoreComponents
  alias Ceec.CeecSurveys.Survey

  @doc """
  Renders the loan follow-up questionnaire section.
  """
  attr :form, Phoenix.HTML.Form, required: true
  attr :class, :string, default: ""

  def loan_impact_form(assigns) do
    ~H"""
    <div class={["bg-white p-6 rounded-lg shadow-md", @class]}>
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
          <.icon name="hero-chart-bar-square" class="w-5 h-5 mr-2 text-indigo-600" />
          Loan Follow-up Questionnaire
        </h3>
        <p class="text-sm text-gray-600">
          Help us understand your CEEC loan experience so we can better support your business and community outcomes.
        </p>
      </div>

      <div class="space-y-6">
        <div>
          <label class="flex items-center text-sm font-medium text-gray-700">
            <input
              type="checkbox"
              {[
              name: input_name(@form, :has_received_loan),
              checked: input_value(@form, :has_received_loan),
              class: "mr-2 rounded border-gray-300"
            ]}
            /> I have accessed a CEEC loan
          </label>
        </div>

        <%= if Phoenix.HTML.Form.input_value(@form, :has_received_loan) do %>
          <% loan_usage_options = Survey.loan_usage_options() %>
          <% repayment_statuses = Survey.loan_repayment_statuses() %>
          <% revenue_options = Survey.monthly_revenue_changes() %>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input
              field={@form[:loan_disbursement_date]}
              type="date"
              label="Date you received the loan *"
            />
            <.input
              field={@form[:loan_amount_received]}
              type="number"
              label="Loan Amount Received (ZMW) *"
              step="0.01"
              min="0"
            />

            <div class="md:col-span-2">
              <.input
                field={@form[:loan_usage_description]}
                type="textarea"
                label="How was the loan used? *"
                rows="3"
                placeholder="Summarize key activities funded with the loan"
              />
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Main ways you used the loan *
              </label>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <%= for option <- loan_usage_options do %>
                  <label class="flex items-center text-sm">
                    <input
                      type="checkbox"
                      name={input_name(@form, :loan_usage_categories) <> "[]"}
                      value={option}
                      checked={option in (input_value(@form, :loan_usage_categories) || [])}
                      class="mr-2 rounded border-gray-300 text-indigo-600"
                    />
                    {option}
                  </label>
                <% end %>
              </div>
            </div>

            <.input
              field={@form[:monthly_revenue_change]}
              type="select"
              label="Monthly revenue trend"
              options={[{"Select an option", ""} | Enum.map(revenue_options, &{&1, &1})]}
            />

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Business performance rating (1-5)
              </label>
              <div class="flex space-x-2">
                <% selected_performance =
                  normalize_choice(input_value(@form, :business_performance_rating)) %>
                <%= for i <- 1..5 do %>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={input_name(@form, :business_performance_rating)}
                      value={Integer.to_string(i)}
                      checked={selected_performance == Integer.to_string(i)}
                      class="mr-1 text-indigo-600"
                    />
                    <span class="text-sm">{i}</span>
                  </label>
                <% end %>
              </div>
              <p class="text-xs text-gray-500 mt-1">1 = Significant decline, 5 = Strong growth</p>
            </div>

            <.input
              field={@form[:employment_created]}
              type="number"
              label="Jobs created so far"
              min="0"
              placeholder="0"
            />

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Loan satisfaction rating (1-5) *
              </label>
              <div class="flex space-x-2">
                <% selected_satisfaction =
                  normalize_choice(input_value(@form, :loan_satisfaction_rating)) %>
                <%= for i <- 1..5 do %>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={input_name(@form, :loan_satisfaction_rating)}
                      value={Integer.to_string(i)}
                      checked={selected_satisfaction == Integer.to_string(i)}
                      class="mr-1 text-indigo-600"
                    />
                    <span class="text-sm">{i}</span>
                  </label>
                <% end %>
              </div>
              <p class="text-xs text-gray-500 mt-1">1 = Very dissatisfied, 5 = Very satisfied</p>
            </div>

            <.input
              field={@form[:loan_repayment_status]}
              type="select"
              label="Loan repayment status *"
              options={[{"Select repayment status", ""} | Enum.map(repayment_statuses, &{&1, &1})]}
            />

            <div class="md:col-span-2">
              <.input
                field={@form[:loan_repayment_challenges]}
                type="textarea"
                label="Repayment challenges"
                rows="3"
                placeholder="Describe any obstacles affecting your repayments"
              />
            </div>

            <div class="md:col-span-2">
              <.input
                field={@form[:loan_impact_on_livelihood]}
                type="textarea"
                label="Impact on your livelihood"
                rows="3"
                placeholder="Share how the loan has affected your household or community"
              />
            </div>

            <div class="md:col-span-2 space-y-3">
              <label class="flex items-center text-sm font-medium text-gray-700">
                <input
                  type="checkbox"
                  {[
                  name: input_name(@form, :requires_additional_support),
                  checked: input_value(@form, :requires_additional_support),
                  class: "mr-2 rounded border-gray-300"
                ]}
                /> I need further CEEC support or mentorship
              </label>

              <%= if Phoenix.HTML.Form.input_value(@form, :requires_additional_support) do %>
                <.input
                  field={@form[:additional_support_details]}
                  type="textarea"
                  label="Describe the support you need"
                  rows="3"
                />
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp normalize_choice(nil), do: ""
  defp normalize_choice(value) when is_binary(value), do: value
  defp normalize_choice(value) when is_integer(value), do: Integer.to_string(value)
  defp normalize_choice(%Decimal{} = value), do: Decimal.to_string(value)
  defp normalize_choice(value) when is_float(value), do: Integer.to_string(trunc(value))
  defp normalize_choice(_), do: ""
end
