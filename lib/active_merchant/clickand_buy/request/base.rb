module ActiveMerchant::ClickandBuy::Request
  class Base
    def initialize(auth)
      @auth = auth
    end

    def body
      xml = Builder::XmlMarkup.new
      xml.instruct!

      xml.SOAP :Envelope, 'xmlns:SOAP' => 'http://schemas.xmlsoap.org/soap/envelope/' do
        xml.SOAP :Body do
          xml.tag! request_tag, xmlns: 'http://api.clickandbuy.com/webservices/pay_1_1_0/' do
            xml.authentication do
              xml.merchantID @auth[:merchant_id]
              xml.projectID @auth[:project_id]
              xml.token token
            end

            xml.details do
              details(xml)
            end
          end
        end
      end

      xml.target!
    end

    def handle_response(response_string)
      response = Hash.from_xml(response_string)
      extract_response_details(response['Envelope']['Body'][response_tag])
    end

    private
    def details; raise NotImplementedError end
    def extract_response_details(response); raise NotImplementedError end

    def token
      timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
      hash_input = [@auth[:project_id], @auth[:secret_key], timestamp].join('::')
      hash = Digest::SHA1.hexdigest(hash_input)
      [timestamp, hash].join('::')
    end

    def request_name
      self.class.name.demodulize.camelize(:lower)
    end

    def request_tag
      "#{request_name}_Request"
    end

    def response_tag
      "#{request_name}_Response"
    end
  end
end
