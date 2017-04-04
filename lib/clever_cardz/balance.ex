defmodule CleverCardz.Balance do
  alias CleverCardz.Client

  import SweetXml

  def card_balance(card_number, security_code) do
    response =
      card_balance_request_body(card_number, security_code)
      |> Client.post
      |> process_response
  end

  defp card_balance_request_body(card_number, security_code) do
    """
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <GetCardBalance xmlns="http://webservices.storefinancial.net/tantalus/public">
          <cardNumber>#{card_number}</cardNumber>
          <securityCode>#{security_code}</securityCode>
        </GetCardBalance>
      </soap:Body>
    </soap:Envelope>
    """
  end

  @doc """
  Process the following result:
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
      <GetCardBalanceResponse xmlns="http://webservices.storefinancial.net/tantalus/public">
        <BalanceInformation>
          <FormattedCardNumber>xxxx xxxx xxxx xxxx</FormattedCardNumber>
          <ActualBalance>20.00</ActualBalance>
          <AvailableBalance>20.00</AvailableBalance>
          <AdjustedBalance>20.00</AdjustedBalance>
          <PromotionBalance>0</PromotionBalance>
          <PromotionFundingOptionId xsi:nil="true"/>
          <CurrencyAlphaCode>GBP</CurrencyAlphaCode>
          <CurrencySymbol>£</CurrencySymbol>
          <Status>Active</Status>
          <Registered>false</Registered>
          <ActivatingMerchantGroupId>442</ActivatingMerchantGroupId>
          <ActivatingMerchantGroupName>...</ActivatingMerchantGroupName>
          <ActivationDate>2017-01-01T09:24:51.1770000-05:00</ActivationDate>
          <ProgramAllowsRegistration>false</ProgramAllowsRegistration>
          <PlasticExpired>false</PlasticExpired>
          <PlasticExpirationDate>9999-12-31T23:59:59.9990000-06:00</PlasticExpirationDate>
          <ProgramId>123</ProgramId>
          <Program>Lend Lease PVL</Program>
          <BIN>123123</BIN>
          <BINUniqueTag>MasterC017</BINUniqueTag>
          <ActivationCountry>United Kingdom</ActivationCountry>
          <DeveloperId>123</DeveloperId>
          <DeveloperUniqueTag>...</DeveloperUniqueTag>
          <ActivationProvince>England</ActivationProvince>
          <AccountExpirationDate>9999-12-31T00:00:00.0000000-05:00</AccountExpirationDate>
          <AMFStartDate>0001-01-01T00:00:00.0000000-06:00</AMFStartDate>
          <NextAMFDate>0001-01-01T00:00:00.0000000-06:00</NextAMFDate>
          <DistributorRefunded>false</DistributorRefunded>
          <IsInstructionRequired>false</IsInstructionRequired>
          <IsReloadable>false</IsReloadable>
          <IsOrganizationRegistration>false</IsOrganizationRegistration>
          <IsPinSet>false</IsPinSet>
          <IsBinPinEnabled>false</IsBinPinEnabled>
        </BalanceInformation>
      </GetCardBalanceResponse>
    </soap:Body>
  </soap:Envelope>
  """
  defp process_response({:ok, response_body}) do
    response_map =
      response_body
      |> xpath(~x"//BalanceInformation",
        formatted_card_number: ~x"./FormattedCardNumber/text()",
        actual_balance: ~x"./ActualBalance/text()",
        available_balance: ~x"./AvailableBalance/text()",
        adjusted_balance: ~x"./AdjustedBalance/text()",
        promotion_balance: ~x"./PromotionBalance/text()",
        promotion_funding_option_id: ~x"./PromotionFundingOptionId/text()",
        currency_alpha_code: ~x"./CurrencyAlphaCode/text()",
        currency_symbol: ~x"./CurrencySymbol/text()",
        status: ~x"./Status/text()",
        registered: ~x"./Registered/text()",
        activation_date: ~x"./ActivationDate/text()",
        plastic_expiration_date: ~x"./PlasticExpirationDate/text()"
      )
    {:ok, response_map}
  end
  defp process_response({:error, error}) when is_binary(error) do
    error =
      error
      |> xpath(~x"//exceptionType/text()")
      |> to_string
      |> Macro.underscore
      |> String.to_atom
    {:error, error}
  end
  defp process_response({:error, error}) do
    {:error, error}
  end

end
