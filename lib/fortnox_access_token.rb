require 'httparty'

# Public: Used for retrieving the access token for a specific customer.
class FortnoxAccessToken
  include HTTParty

  attr_reader :authorization_code, :client_secret

  class RetrievalFailedError < StandardError; end

  # Public: Initialize a FortnoxAccessToken.
  #
  # authorization_code - The String fortnox authorization code. A customer may
  #                      receive this from their fortnox account by adding our
  #                      application as an integration.
  # client_secret      - The String fortnox client secret used by our
  #                      integration. It is received upon registering your
  #                      account.
  def initialize(authorization_code, client_secret: nil)
    @authorization_code = authorization_code
    @client_secret = client_secret || ENV.fetch('FORTNOX_CLIENT_SECRET')
  end

  # Public: Retrieve the access token used to authenticate further requests.
  #
  # Examples
  #   FortnoxAccessToken.new('9161dcb4-9d35-85e0-6131-cbe68e60f0a8').retrieve!
  #   #=> "b8932e4f-a48b-4381-94cc-bf028b88ee6f"
  #
  # Returns the String fortnox access token. May only be retrieved once before
  #   invalidating authorization code.
  # Raises RetrievalFailedError if the fortnox acces token could not be
  #   retrieved.
  def retrieve!
    response = retrieve_customer_information
    raise_if_failed!(response)
    response['Authorization']['AccessToken']
  end

  private

  def retrieve_customer_information
    self.class.get('/customers', headers: headers, base_uri: fortnox_base_uri).parsed_response
  end

  def headers
    {
      'Authorization-Code' => authorization_code,
      'Client-Secret' => client_secret
    }
  end

  def raise_if_failed!(response)
    error_information = response['ErrorInformation']
    return if error_information.empty?

    raise RetrievalFailedError, error_information['Message']
  end

  def fortnox_base_uri
    ENV.fetch('FORTNOX_BASE_URL', 'https://api.fortnox.se/3/')
  end
end
