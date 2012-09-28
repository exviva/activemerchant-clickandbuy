require 'spec_helper'

describe ActiveMerchant::ClickandBuy::Request::PayRequest do
  let(:url) { proc {|variation| "http://example.com/callback/#{variation}" } }
  let(:success_url) { url[:success] }
  let(:failure_url) { url[:failure] }
  let(:order_id) { Time.now.to_i }
  let(:ip) { '1.2.3.4' }
  let(:locale) { 'en' }
  let(:order_description) { 'Foo bar baz' }
  let(:success_url) { url[:success] }

  let(:auth) { {merchant_id: 123, project_id: 456, secret_key: 'foo'} }
  let(:amount) { Money.new(1000, 'EUR') }
  let(:options) { {success_url: success_url, failure_url: failure_url, order_id: order_id, ip: ip, order_description: order_description, locale: locale} }

  let(:request) { described_class.new(auth, amount, options) }

  describe '#body' do
    let(:body) { request.body }
    let(:body_hash) { Hash.from_xml(request.body) }
    let(:request_hash) { body_hash['Envelope']['Body']['payRequest_Request'] }
    let(:details) { request_hash['details'] }

    it 'uses the auth argument to provide authentication' do
      authentication = request_hash['authentication']
      authentication['merchantID'].should eq('123')
      authentication['projectID'].should eq('456')
      authentication['token'].should match(/\A\d{14}::\w{40}\z/)
    end

    it 'uses the amount argument to provide amount' do
      amount_tag = details['amount']
      amount_tag['amount'].should eq(sprintf('%.2f', amount.to_f))
      amount_tag['currency'].should eq(amount.currency_as_string)
    end

    it 'uses the order_description option for order details text' do
      text = details['orderDetails']['text']
      text.should eq(order_description)
    end

    it 'uses the success_url option for successURL' do
      details['successURL'].should eq(success_url)
    end

    it 'uses the failure_url option for failureURL' do
      details['failureURL'].should eq(failure_url)
    end

    it 'uses the order_id option for externalID' do
      details['externalID'].should eq(order_id.to_s)
    end

    it 'uses the ip option for consumerIPAddress' do
      details['consumerIPAddress'].should eq(ip)
    end

    it 'uses the locale option for consumerLanguage' do
      details['consumerLanguage'].should eq(locale)
    end

    it 'does not have successExpiration' do
      details.should_not have_key('successExpiration')
    end

    describe 'with success_expiration provided' do
      before { options[:success_expiration] = 1439 }

      it 'uses the success_expiration option for successExpiration' do
        details['successExpiration'].should eq('1439')
      end
    end
  end

  describe '#handle_response' do
    let(:response_string) { File.read(File.expand_path('../../../../support/requests/pay_request_response.xml', __FILE__)) }
    subject { request.handle_response(response_string) }

    it 'returns the transaction hash' do
      subject['transactionID'].should eq('1397737001')
      subject['redirectURL'].should eq('https://checkout.clickandbuy-s1.com/frontend/secure/checkout?tx=1397737001&s=988809699F35D642&h=09FBBC928EDAA067207D4E69B5EA9CAD441D4812')
    end
  end
end
