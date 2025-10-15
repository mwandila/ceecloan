defmodule CeecWeb.Components.Stepper do
  @moduledoc """
  Stepper component for multi-step form navigation
  """
  
  use Phoenix.Component
  
  @doc """
  Renders a stepper component with steps and current step indicator
  
  ## Examples
  
      <.stepper current_step={1} steps={[
        %{id: 1, title: "Visit Information", icon: "clipboard"},
        %{id: 2, title: "Project Location", icon: "map-pin"},
        %{id: 3, title: "Beneficiary Information", icon: "user"}
      ]} />
  """
  attr :current_step, :integer, required: true
  attr :steps, :list, required: true
  attr :class, :string, default: ""
  
  def stepper(assigns) do
    ~H"""
    <div class={["w-full py-6", @class]}>
      <nav aria-label="Progress">
        <ol role="list" class="flex items-center justify-center">
          <%= for {step, index} <- Enum.with_index(@steps, 1) do %>
            <li class={[
              "relative",
              index < length(@steps) && "pr-8 sm:pr-20"
            ]}>
              <!-- Step separator line -->
              <%= if index < length(@steps) do %>
                <div class="absolute inset-0 flex items-center" aria-hidden="true">
                  <div class={[
                    "h-0.5 w-full",
                    @current_step > index && "bg-indigo-600" || "bg-gray-200"
                  ]}></div>
                </div>
              <% end %>
              
              <!-- Step indicator -->
              <div class="relative flex h-8 w-8 items-center justify-center">
                <%= if @current_step > index do %>
                  <!-- Completed step -->
                  <div class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 hover:bg-indigo-900">
                    <svg class="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                <% else %>
                  <%= if @current_step == index do %>
                    <!-- Current step -->
                    <div class="flex h-8 w-8 items-center justify-center rounded-full border-2 border-indigo-600 bg-white">
                      <span class="text-indigo-600 text-sm font-medium"><%= index %></span>
                    </div>
                  <% else %>
                    <!-- Upcoming step -->
                    <div class="flex h-8 w-8 items-center justify-center rounded-full border-2 border-gray-300 bg-white group-hover:border-gray-400">
                      <span class="text-gray-500 text-sm font-medium group-hover:text-gray-900"><%= index %></span>
                    </div>
                  <% end %>
                <% end %>
              </div>
              
              <!-- Step label -->
              <div class="mt-2">
                <span class={[
                  "text-xs font-medium",
                  @current_step >= index && "text-indigo-600" || "text-gray-500"
                ]}>
                  <%= step.title %>
                </span>
              </div>
            </li>
          <% end %>
        </ol>
      </nav>
    </div>
    """
  end
  
  @doc """
  Renders step navigation buttons (Previous/Next)
  """
  attr :current_step, :integer, required: true
  attr :total_steps, :integer, required: true
  attr :class, :string, default: ""
  attr :on_previous, :string, default: nil
  attr :on_next, :string, default: nil
  attr :submit_text, :string, default: "Submit"
  
  def step_navigation(assigns) do
    ~H"""
    <div class={["flex justify-between items-center pt-6 border-t border-gray-200", @class]}>
      <div>
        <%= if @current_step > 1 do %>
          <button
            type="button"
            onclick={@on_previous}
            class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            <svg class="-ml-1 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
            Previous
          </button>
        <% end %>
      </div>
      
      <div class="flex items-center space-x-2">
        <span class="text-sm text-gray-500">
          Step <%= @current_step %> of <%= @total_steps %>
        </span>
      </div>
      
      <div>
        <%= if @current_step < @total_steps do %>
          <button
            type="button"
            onclick={@on_next}
            class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Next
            <svg class="ml-2 -mr-1 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        <% else %>
          <button
            type="submit"
            class="inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            <svg class="-ml-1 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            <%= @submit_text %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end
end