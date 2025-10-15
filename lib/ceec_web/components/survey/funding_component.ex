defmodule CeecWeb.SurveyComponents.FundingComponent do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML.Form
  import CeecWeb.CoreComponents

  @doc """
  Renders a funding requirements form section.
  """
  attr :form, Phoenix.HTML.Form, required: true
  attr :class, :string, default: ""

  def funding_requirements_form(assigns) do
    ~H"""
    <div class={["bg-white p-6 rounded-lg shadow-md", @class]}>
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
          <.icon name="hero-banknotes" class="w-5 h-5 mr-2 text-green-600" /> Funding Requirements
        </h3>

        <p class="text-sm text-gray-600">Tell us about your funding needs and preferences.</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <.input
            field={@form[:funding_purpose]}
            type="textarea"
            label="Purpose of Funding *"
            placeholder="Describe how you plan to use the funding"
            rows="3"
          />
        </div>

        <.input
          field={@form[:funding_amount_requested]}
          type="number"
          label="Amount Requested (ZMW) *"
          placeholder="0.00"
          step="0.01"
          min="1"
        />
        <.input
          field={@form[:funding_type_preferred]}
          type="select"
          label="Preferred Funding Type *"
          options={[
            {"Select Funding Type", ""},
            {"Loan", "Loan"},
            {"Grant", "Grant"},
            {"Equipment Financing", "Equipment Financing"},
            {"Working Capital", "Working Capital"},
            {"Asset Financing", "Asset Financing"}
          ]}
        />
        <.input
          field={@form[:repayment_period_preferred]}
          type="number"
          label="Preferred Repayment Period (months)"
          placeholder="e.g., 12, 24, 36"
          min="1"
        />
      </div>

      <div class="mt-4">
        <label class="flex items-center text-sm font-medium text-gray-700 mb-4">
          <input
            type="checkbox"
            {[
            name: input_name(@form, :collateral_available),
            checked: input_value(@form, :collateral_available),
            class: "mr-2 rounded border-gray-300"
          ]}
          /> I have collateral available
        </label>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input
            field={@form[:collateral_type]}
            label="Collateral Type"
            placeholder="e.g., Property, Vehicle, Equipment"
          />
          <.input
            field={@form[:collateral_value]}
            type="number"
            label="Estimated Collateral Value (ZMW)"
            placeholder="0.00"
            step="0.01"
            min="0"
          />
        </div>
      </div>
    </div>
    """
  end
end
