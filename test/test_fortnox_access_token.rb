require 'minitest/autorun'
require 'fortnox_access_token'
require 'webmock/minitest'
require 'byebug'

class FortnoxAccessTokenTest < Minitest::Test
  def setup
    @authorization_code = 'authorization_code'
    @client_secret = 'client_secret'
  end

  def teardown
    ENV['FORTNOX_CLIENT_SECRET'] = nil
    ENV['FORTNOX_BASE_URL'] = nil
  end

  def test_retrieve_calles_get
    stub_request(:get, "https://api.fortnox.se/3/customers").
      with(headers: { 'Authorization-Code'=>@authorization_code, 'Client-Secret'=>@client_secret }).
      to_return(status: 200, body: { "ErrorInformation"=> "", "Authorization"=>{"AccessToken"=>'access_token'} }.to_json, headers: {"Content-Type"=> "application/json"})
    subject = FortnoxAccessToken.new(@authorization_code, client_secret: @client_secret)

    response = subject.retrieve!


    assert_equal "access_token", response
  end

  def test_will_use_client_secret_from_env
    ENV['FORTNOX_CLIENT_SECRET'] = @client_secret
    stub_request(:get, "https://api.fortnox.se/3/customers").
      with(headers: { 'Authorization-Code'=>@authorization_code, 'Client-Secret'=>@client_secret }).
      to_return(status: 200, body: { "ErrorInformation"=> "", "Authorization"=>{"AccessToken"=>'access_token'} }.to_json, headers: {"Content-Type"=> "application/json"})
    subject = FortnoxAccessToken.new(@authorization_code)

    response = subject.retrieve!

    assert_equal "access_token", response
  end

  def test_will_use_base_uri_from_env
    base_url = 'https://api.test.se/'
    ENV['FORTNOX_BASE_URL'] = base_url
    stub_request(:get, base_url + "customers").
      with(headers: { 'Authorization-Code'=>@authorization_code, 'Client-Secret'=>@client_secret }).
      to_return(status: 200, body: { "ErrorInformation"=> "", "Authorization"=>{"AccessToken"=>'access_token'} }.to_json, headers: {"Content-Type"=> "application/json"})
    subject = FortnoxAccessToken.new(@authorization_code, client_secret: @client_secret)

    response = subject.retrieve!

    assert_equal "access_token", response
  end

  def test_will_raise_error_with_error_information
    error_information = { "Message" => "SuperError" }
    stub_request(:get, 'https://api.fortnox.se/3/customers').
      with(headers: { 'Authorization-Code'=>@authorization_code, 'Client-Secret'=>@client_secret }).
      to_return(status: 200, body: { "ErrorInformation"=> error_information, "Authorization"=>{"AccessToken"=>'access_token'} }.to_json, headers: {"Content-Type"=> "application/json"})
    subject = FortnoxAccessToken.new(@authorization_code, client_secret: @client_secret)

    assert_raises FortnoxAccessToken::RetrievalFailedError do
      response = subject.retrieve!
    end
  end
end
