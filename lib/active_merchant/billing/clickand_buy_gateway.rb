require 'active_merchant/clickand_buy/request/pay_request'
require 'active_merchant/clickand_buy/request/status_request'

module ActiveMerchant
  module Billing
    class ClickandBuyGateway < Gateway
      self.test_url = 'https://api.clickandbuy-s1.com/webservices/soap/pay_1_1_0'
      self.live_url = 'https://api.clickandbuy.com/webservices/soap/pay_1_1_0'

      self.homepage_url = 'http://www.clickandbuy.com'
      self.display_name = 'ClickandBuy'

      def initialize(auth)
        requires!(auth, :project_id, :merchant_id, :secret_key)
        @auth = auth
      end

      def setup_purchase(amount, options)
        requires!(options, :success_url, :failure_url, :order_id, :ip, :order_description, :locale)
        perform(ClickandBuy::Request::PayRequest.new(@auth, amount, options))
      end

      def check_status(transaction_id)
        perform(ClickandBuy::Request::StatusRequest.new(@auth, transaction_id))
      end

      private
      def perform(request)
        response_string = ssl_post(endpoint_url, request.body, headers)
        request.handle_response(response_string)
      end

      def headers
        {'Content-Type' => 'text/xml; charset=UTF-8'}
      end

      def endpoint_url
        test? ? test_url : live_url
      end
    end
  end
end
