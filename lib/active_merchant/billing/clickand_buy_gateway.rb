require 'active_merchant/clickand_buy/request/pay_request'

module ActiveMerchant
	module Billing
    class ClickandBuyGateway < Gateway
      def initialize(auth)
        requires!(auth, :project_id, :merchant_id, :secret_key)
        @auth = auth
      end

      def setup_purchase(amount, options)
        requires!(options, :success_url, :failure_url, :order_id, :ip, :order_description, :locale)
        perform(ClickandBuy::Request::PayRequest.new(@auth, amount, options))
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
        'https://api.clickandbuy-s1.com/webservices/soap/pay_1_1_0'
      end
    end
  end
end
