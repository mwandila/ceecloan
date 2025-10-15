defmodule CeecWeb.SurveyComponents do
  @moduledoc """
  Web-only survey helpers: progress indicators and navigation.
  
  The actual form sections are split into focused component modules under
  CeecWeb.SurveyComponents.* (see lib/ceec_web/components/survey/).
  """

  use Phoenix.Component
  import Phoenix.HTML.Form
  import CeecWeb.CoreComponents

  @doc """
  Renders a progress indicator for the survey.
  """
  attr :current_step, :integer, required: true
  attr :total_steps, :integer, required: true
  attr :completion_percentage, :integer, default: 0

  def survey_progress(assigns) do
    ~H"""
    <div class="bg-white p-4 rounded-lg shadow-sm mb-6">
      <div class="flex justify-between items-center mb-2">
        <span class="text-sm font-medium text-gray-700">Survey Progress</span>
        <span class="text-sm text-gray-500">Step {@current_step} of {@total_steps}</span>
      </div>

      <div class="w-full bg-gray-200 rounded-full h-2">
        <div
          class="bg-blue-600 h-2 rounded-full transition-all duration-300"
          style={"width: #{@completion_percentage}%"}
        >
        </div>
      </div>

      <div class="text-right mt-1">
        <span class="text-xs text-gray-500">{@completion_percentage}% complete</span>
      </div>
    </div>
    """
  end

  @doc """
  Renders survey navigation buttons.
  """
  attr :can_go_back, :boolean, default: true
  attr :can_go_forward, :boolean, default: true
  attr :is_last_step, :boolean, default: false
  attr :is_submitting, :boolean, default: false

  def survey_navigation(assigns) do
    ~H"""
    <div class="flex justify-between items-center mt-8 pt-6 border-t border-gray-200">
      <button
        :if={@can_go_back}
        type="button"
        phx-click="prev_step"
        class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
      >
        <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Previous
      </button>
      <div :if={!@can_go_back} class="w-1"></div>

      <div class="flex space-x-3">
        <button
          type="button"
          phx-click="save_draft"
          class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
        >
          <.icon name="hero-document" class="w-4 h-4 mr-2" /> Save Draft
        </button>
        <button
          :if={!@is_last_step and @can_go_forward}
          type="button"
          phx-click="next_step"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          Next <.icon name="hero-arrow-right" class="w-4 h-4 ml-2" />
        </button>
        <button
          :if={@is_last_step}
          type="submit"
          disabled={@is_submitting}
          class="inline-flex items-center px-6 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <.icon :if={@is_submitting} name="hero-arrow-path" class="w-4 h-4 mr-2 animate-spin" />
          <.icon :if={!@is_submitting} name="hero-paper-airplane" class="w-4 h-4 mr-2" /> {if @is_submitting,
            do: "Submitting...",
            else: "Submit Survey"}
        </button>
      </div>
    </div>
    """
  end
end
