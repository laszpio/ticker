defmodule Ticker do
  @moduledoc """
  European Central Bank current foregin exchange rates.
  """

  @endpoint "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"

  def query do
    case HTTPotion.get(@endpoint) do
      %HTTPotion.Response{body: body, status_code: 200} ->
        case body |> parse_response_body do
          {:ok, response} -> process_response_data(response)
          {:error, message} -> message
        end

      %HTTPotion.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  def parse_response_body(response) do
    case XmlToMap.naive_map(response) do
      %{"{http://www.gesmes.org/xml/2002-08-01}Envelope" => data} -> {:ok, data}
      {:error, message} -> {:error, message}
    end
  end

  def process_response_data(data) do
    data
    |> Map.get("Cube")
    |> Map.get("Cube")
    |> extract_rates()
  end

  def extract_rates(data) when is_map(data) do
    %{
      date: data["time"],
      rates:
        Enum.map(data["Cube"], fn r -> {r["currency"], r["rate"] |> Float.parse() |> elem(0)} end)
    }
  end

  def extract_rates(data) when is_list(data) do
    data |> Enum.map(&extract_rates(&1))
  end
end
