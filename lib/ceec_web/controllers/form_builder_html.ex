defmodule CeecWeb.FormBuilderHTML do
  @moduledoc """
  This module contains pages rendered by FormBuilderController.
  """
  use CeecWeb, :html

  embed_templates "form_builder_html/*"

  @doc """
  Renders form field types for the field type selector.
  """
  def field_types do
    [
      %{value: "text", label: "Text Input", icon: "📝"},
      %{value: "number", label: "Number Input", icon: "🔢"},
      %{value: "date", label: "Date Picker", icon: "📅"},
      %{value: "select", label: "Dropdown Select", icon: "📋"},
      %{value: "multiselect", label: "Multi Select", icon: "☑️"},
      %{value: "textarea", label: "Text Area", icon: "📄"},
      %{value: "radio", label: "Radio Buttons", icon: "🔘"},
      %{value: "checkbox", label: "Checkbox", icon: "✅"},
      %{value: "file", label: "File Upload", icon: "📎"},
      %{value: "photo", label: "Photo Upload", icon: "📷"},
      %{value: "gps", label: "GPS Location", icon: "📍"},
      %{value: "signature", label: "Digital Signature", icon: "✍️"}
    ]
  end

  @doc """
  Renders a form field preview based on the field configuration.
  """
  def render_field_preview(field) do
    case field["type"] do
      "text" -> render_text_field_preview(field)
      "number" -> render_number_field_preview(field)
      "date" -> render_date_field_preview(field)
      "select" -> render_select_field_preview(field)
      "multiselect" -> render_multiselect_field_preview(field)
      "textarea" -> render_textarea_field_preview(field)
      "radio" -> render_radio_field_preview(field)
      "checkbox" -> render_checkbox_field_preview(field)
      "file" -> render_file_field_preview(field)
      "photo" -> render_photo_field_preview(field)
      "gps" -> render_gps_field_preview(field)
      "signature" -> render_signature_field_preview(field)
      _ -> render_unknown_field_preview(field)
    end
  end

  defp render_text_field_preview(field) do
    ~s(<input type="text" placeholder="#{field["placeholder"] || field["label"]}" class="w-full p-2 border border-gray-300 rounded" readonly />)
  end

  defp render_number_field_preview(field) do
    ~s(<input type="number" placeholder="#{field["placeholder"] || field["label"]}" class="w-full p-2 border border-gray-300 rounded" readonly />)
  end

  defp render_date_field_preview(_field) do
    ~s(<input type="date" class="w-full p-2 border border-gray-300 rounded" readonly />)
  end

  defp render_select_field_preview(field) do
    options = field["options"] || []
    options_html = Enum.map(options, fn opt -> ~s(<option>#{opt}</option>) end) |> Enum.join("")
    ~s(<select class="w-full p-2 border border-gray-300 rounded" disabled><option>Select #{field["label"]}</option>#{options_html}</select>)
  end

  defp render_multiselect_field_preview(field) do
    options = field["options"] || []
    checkboxes = Enum.map(options, fn opt -> 
      ~s(<label class="flex items-center space-x-2"><input type="checkbox" disabled /><span>#{opt}</span></label>)
    end) |> Enum.join("")
    ~s(<div class="space-y-2">#{checkboxes}</div>)
  end

  defp render_textarea_field_preview(field) do
    ~s(<textarea placeholder="#{field["placeholder"] || field["label"]}" class="w-full p-2 border border-gray-300 rounded" rows="3" readonly></textarea>)
  end

  defp render_radio_field_preview(field) do
    options = field["options"] || []
    radios = Enum.map(options, fn opt -> 
      ~s(<label class="flex items-center space-x-2"><input type="radio" name="preview_#{field["name"]}" disabled /><span>#{opt}</span></label>)
    end) |> Enum.join("")
    ~s(<div class="space-y-2">#{radios}</div>)
  end

  defp render_checkbox_field_preview(field) do
    ~s(<label class="flex items-center space-x-2"><input type="checkbox" disabled /><span>#{field["label"]}</span></label>)
  end

  defp render_file_field_preview(_field) do
    ~s(<div class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">Click to upload file</div>)
  end

  defp render_photo_field_preview(_field) do
    ~s(<div class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">📷 Click to take photo</div>)
  end

  defp render_gps_field_preview(_field) do
    ~s(<div class="flex items-center space-x-2 p-2 border border-gray-300 rounded bg-gray-50"><span>📍</span><span class="text-gray-500">GPS coordinates will be captured</span></div>)
  end

  defp render_signature_field_preview(_field) do
    ~s(<div class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">✍️ Digital signature pad</div>)
  end

  defp render_unknown_field_preview(field) do
    ~s(<div class="p-2 border border-red-300 rounded bg-red-50 text-red-600">Unknown field type: #{field["type"]}</div>)
  end
end