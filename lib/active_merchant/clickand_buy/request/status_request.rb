require 'active_merchant/clickand_buy/request/base'

module ActiveMerchant::ClickandBuy::Request
  class StatusRequest < Base
    def initialize(auth, transaction_id)
      super(auth)
      @transaction_id = transaction_id
    end

    private
    def details(xml)
      xml.transactionIDList do
        xml.transactionID @transaction_id
      end
    end

    def extract_response_details(response)
      response['transactionList']['transaction']
    end
  end
end
