defmodule CleverCardz.Client do
  def post(request_body) do
    soap_url = "https://webservices.storefinancial.net/tantalus/PublicService.asmx"

    case HTTPoison.post(soap_url, request_body, gen_headers, ssl: [versions: [:"tlsv1.2"]]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, :unauthorized}
      {:ok, %HTTPoison.Response{status_code: 500, body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp gen_headers do
    %{"Content-Type"=>"text/xml; charset=\"utf-8\""}
  end
end
