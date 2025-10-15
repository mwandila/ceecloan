defmodule CeecWeb.SurveyComponents.PersonalInfoComponent do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML.Form
  import CeecWeb.CoreComponents

  @doc """
  Renders a personal information form section.
  """
  attr :form, Phoenix.HTML.Form, required: true
  attr :class, :string, default: ""

  def personal_info_form(assigns) do
    ~H"""
    <div class={["bg-white p-6 rounded-lg shadow-md", @class]}>
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
          <.icon name="hero-user" class="w-5 h-5 mr-2 text-blue-600" /> Personal Information
        </h3>

        <p class="text-sm text-gray-600">
          Please provide your personal details as they appear on your National Registration Card.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <.input field={@form[:first_name]} label="First Name *" placeholder="Enter your first name" />
        <.input field={@form[:last_name]} label="Last Name *" placeholder="Enter your last name" />
        <.input
          field={@form[:national_id]}
          label="National ID Number *"
          placeholder="e.g., 123456789012"
          maxlength="15"
        />
        <.input field={@form[:date_of_birth]} type="date" label="Date of Birth" />
        <.input
          field={@form[:gender]}
          type="select"
          label="Gender"
          options={[
            {"Select Gender", ""},
            {"Male", "Male"},
            {"Female", "Female"},
            {"Other", "Other"},
            {"Prefer not to say", "Prefer not to say"}
          ]}
        />
        <.input
          field={@form[:marital_status]}
          type="select"
          label="Marital Status"
          options={[
            {"Select Status", ""},
            {"Single", "Single"},
            {"Married", "Married"},
            {"Divorced", "Divorced"},
            {"Widowed", "Widowed"},
            {"Separated", "Separated"}
          ]}
        />
        <.input field={@form[:phone_number]} label="Phone Number *" placeholder="+260 or 0XXXXXXXXX" />
        <.input
          field={@form[:email]}
          type="email"
          label="Email Address"
          placeholder="your.email@example.com"
        />
      </div>
    </div>
    """
  end
end
