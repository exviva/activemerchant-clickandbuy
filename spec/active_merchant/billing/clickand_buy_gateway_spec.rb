require 'spec_helper'

describe ActiveMerchant::Billing::ClickandBuyGateway do
  let(:auth) { YAML.load_file(File.expand_path('../../../support/clickand_buy.yml', __FILE__)) }
  let(:gateway) { described_class.new(auth) }
  let(:amount) { Money.new(1000, 'EUR') }
  let(:order_id) { Time.now.to_i }
  let(:setup_purchase_options) { {success_url: 'http://example.com', failure_url: 'http://example.com', order_id: order_id, ip: '1.2.3.4', order_description: '', locale: 'en', success_expiration: 30} }

  def perform_setup_purchase
    gateway.setup_purchase(amount, setup_purchase_options)
  end

  describe '#initialize' do
    [:project_id, :merchant_id, :secret_key].each do |key|
      it "requires #{key} in auth" do
        expect { described_class.new(auth.except(key)) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#setup_purchase' do
    subject { perform_setup_purchase }

    [:success_url, :failure_url, :order_id, :ip, :order_description, :locale].each do |key|
      context "without #{key} in options" do
        subject { gateway.setup_purchase(amount, setup_purchase_options.except(key)) }

        it 'raises an argument error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    it 'returns a hash with transaction details', :remote do
      subject.should be_a(Hash)

      subject['transactionID'].should match(/\d+/)
      subject['transactionStatus'].should eq('CREATED')
      subject['transactionType'].should eq('PAY')
      subject['externalID'].should eq(order_id.to_s)

      URI.parse(subject['redirectURL']).tap do |redirect_url|
        redirect_url.scheme.should eq('https')
        redirect_url.host.should eq('checkout.clickandbuy-s1.com')
        redirect_url.path.should eq('/frontend/secure/checkout')
      end
    end
  end

  describe '#check_status', :remote do
    let(:transaction_id) { '123' }
    subject { gateway.check_status(transaction_id) }

    it 'returns the transaction ID' do
      subject['transactionID'].should eq('123')
    end

    it 'returns an error if transaction not found' do
      subject['errorDetails']['code'].should eq('3')
    end

    context 'with a valid transaction ID' do
      let(:transaction_id) { perform_setup_purchase['transactionID'] }

      it 'returns the transaction status' do
        subject['transactionStatus'].should eq('CREATED')
      end
    end
  end
end
