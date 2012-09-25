module ActiveMerchant
  module ClickandBuy
    module Request
      class PayRequest
        def initialize(auth, amount, options)
          @auth = auth
          @amount = amount
          @options = options
        end

        def body
          xml = Builder::XmlMarkup.new
          xml.instruct!

          xml.SOAP :Envelope, 'xmlns:SOAP' => 'http://schemas.xmlsoap.org/soap/envelope/' do
            xml.SOAP :Body do
              xml.payRequest_Request xmlns: 'http://api.clickandbuy.com/webservices/pay_1_1_0/' do
                xml.authentication do
                  xml.merchantID @auth[:merchant_id]
                  xml.projectID @auth[:project_id]
                  xml.token token
                end

                xml.details do
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
                end
              end
            end
          end

          xml.target!
        end

        def handle_response(response_string)
          response = Hash.from_xml(response_string)
          response['Envelope']['Body']['payRequest_Response']['transaction']
        end

        private
        def token
          timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
          hash_input = [@auth[:project_id], @auth[:secret_key], timestamp].join('::')
          hash = Digest::SHA1.hexdigest(hash_input)
          [timestamp, hash].join('::')
        end
      end
    end
  end
end
