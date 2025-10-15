defmodule CeecWeb.SurveyComponents.BusinessComponent do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML.Form
  import CeecWeb.CoreComponents

  @doc """
  Renders a business information form section.
  """
  attr :form, Phoenix.HTML.Form, required: true
  attr :class, :string, default: ""

  def business_info_form(assigns) do
    ~H"""
    <div class={["bg-white p-6 rounded-lg shadow-md", @class]}>
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
          <.icon name="hero-building-storefront" class="w-5 h-5 mr-2 text-orange-600" />
          Business Information
        </h3>

        <p class="text-sm text-gray-600">
          Provide details about your existing business or planned business venture.
        </p>
      </div>

      <div class="mb-4">
        <label class="flex items-center text-sm font-medium text-gray-700">
          <input
            type="checkbox"
            {[
            name: input_name(@form, :has_existing_business),
            checked: input_value(@form, :has_existing_business),
            class: "mr-2 rounded border-gray-300"
          ]}
          /> I have an existing business
        </label>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <.input
          field={@form[:business_name]}
          label="Business Name"
          placeholder="Enter your business name"
        />
        <.input
          field={@form[:business_type]}
          label="Business Type"
          placeholder="e.g., Sole Proprietorship, Partnership"
        />
        <.input
          field={@form[:business_sector]}
          type="select"
          label="Business Sector"
          options={[
            {"Select Sector", ""},
            {"Agriculture", "Agriculture"},
            {"Manufacturing", "Manufacturing"},
            {"Trade", "Trade"},
            {"Services", "Services"},
            {"Tourism", "Tourism"},
            {"Construction", "Construction"},
            {"Transport", "Transport"},
            {"Mining", "Mining"},
            {"ICT", "ICT"},
            {"Other", "Other"}
          ]}
        />
        <.input
          field={@form[:business_registration_number]}
          label="Registration Number"
          placeholder="Business registration number (if applicable)"
        />
        <.input
          field={@form[:years_in_business]}
          type="number"
          label="Years in Business"
          placeholder="0"
          min="0"
        />
        <.input
          field={@form[:number_of_employees]}
          type="number"
          label="Number of Employees"
          placeholder="0"
          min="0"
        />
        <div class="md:col-span-2">
          <.input
            field={@form[:annual_turnover]}
            type="number"
            label="Annual Turnover (ZMW)"
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
