defmodule CeecWeb.Helpers.NumberHelper do
  @moduledoc """
  Helper functions for number formatting.
  """

  @doc """
  Format a decimal number as Zambian Kwacha (ZMK) currency with comma delimiters.
  """
  def format_currency(nil), do: ""
  
  def format_currency(%Decimal{} = amount) do
    amount
    |> Decimal.to_float()
    |> format_currency()
  end
  
  def format_currency(amount) when is_number(amount) do
    formatted_amount = 
      amount
      |> trunc()
      |> Integer.to_string()
      |> add_commas()
    "ZMK #{formatted_amount}"
  end
  
  def format_currency(amount) when is_binary(amount) do
    case Float.parse(amount) do
      {float_val, _} -> format_currency(float_val)
      :error -> amount
    end
  end

  defp add_commas(string) do
    string
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end
end