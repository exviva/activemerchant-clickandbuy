require 'active_merchant/clickand_buy/request/base'

module ActiveMerchant::ClickandBuy::Request
  class PayRequest < Base
    def initialize(auth, amount, options)
      super(auth)
      @amount = amount
      @options = options
    end

    private
    def details(xml)
      xml.amount do
        xml.amount sprintf('%.2f', @amount.to_f)
        xml.currency @amount.currency_as_string
      end
      xml.orderDetails do
        xml.text @options[:order_description]
      end
      xml.successURL @options[:success_url]
      xml.failureURL @options[:failure_url]
      xml.externalID @options[:order_id]
      xml.consumerIPAddress @options[:ip]
      xml.consumerLanguage @options[:locale]
      xml.successExpiration @options[:success_expiration] if @options.key?(:success_expiration)
    end

    def extract_response_details(response)
      response['transaction']
    end
  end
end
