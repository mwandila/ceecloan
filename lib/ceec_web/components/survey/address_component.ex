defmodule CeecWeb.SurveyComponents.AddressComponent do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML.Form
  import CeecWeb.CoreComponents

  @doc """
  Renders an address information form section.
  """
  attr :form, Phoenix.HTML.Form, required: true
  attr :class, :string, default: ""

  def address_form(assigns) do
    ~H"""
    <div class={["bg-white p-6 rounded-lg shadow-md", @class]}>
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
          <.icon name="hero-map-pin" class="w-5 h-5 mr-2 text-green-600" /> Address Information
        </h3>

        <p class="text-sm text-gray-600">Please provide your current residential address details.</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <.input
          field={@form[:province]}
          type="select"
          label="Province"
          options={[
            {"Select Province", ""},
            {"Central", "Central"},
            {"Copperbelt", "Copperbelt"},
            {"Eastern", "Eastern"},
            {"Luapula", "Luapula"},
            {"Lusaka", "Lusaka"},
            {"Muchinga", "Muchinga"},
            {"Northern", "Northern"},
            {"North-Western", "North-Western"},
            {"Southern", "Southern"},
            {"Western", "Western"}
          ]}
        />
        <.input field={@form[:district]} label="District" placeholder="Enter your district" />
        <div class="md:col-span-2">
          <.input
            field={@form[:physical_address]}
            type="textarea"
            label="Physical Address"
            placeholder="Enter your complete physical address"
            rows="2"
          />
        </div>

        <div class="md:col-span-2">
          <.input
            field={@form[:postal_address]}
            type="textarea"
            label="Postal Address"
            placeholder="P.O. Box number and location"
            rows="2"
          />
        </div>
      </div>
    </div>
    """
  end
end
