# Active Merchant ClickandBuy gateway

This gem provides integration of ClickandBuy (http://www.clickandbuy.com) with Active Merchant (http://activemerchant.org).

## Installation

Add this line to your application's Gemfile:

    gem 'activemerchant-clickandbuy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activemerchant-clickandbuy

## Usage

To use the gateway, you'll need to provide your merchant ID, project ID and secret key:

    auth = {merchant_id: 'foo', project_id: 'bar', secret_key: 'baz'}
    gateway = ActiveMerchant::Billing::ClickandBuyGateway.new(auth)

Now you can initiate a transaction at ClickandBuy:

    amount = Money.new(1000, 'EUR')
    options = {
      success_url: 'https://www.your-site.com/callback/success', # where to redirect the user on success
      failure_url: 'https://www.your-site.com/callback/failure', # where to redirect the user on failure
      order_id: 123,                                             # your unique order identifier
      ip: '1.2.3.4',                                             # user's IP address
      order_description: 'ACME Earthquake Pills',                # what the user is buying
      locale: 'en'                                               # user's locale ('en' or 'de')
    }
    response = gateway.setup_purchase(amount, options)

The `response` hash will contain amongst other keys two important ones: `transactionID` and `redirectURL`.
The `transactionID` identifies the transaction at ClickandBuy, make sure you store it together with your order.
The `redirectURL` is where you redirect the user so that they can confirm the purchase.

After a user lands on `success_url`, you can check whether or not the transaction had been confirmed:

    transaction = gateway.check_status(transaction_id)

The `transaction` variable is a hash containing the response details, amongst others a `transactionStatus` key.

## Running specs

Copy `spec/support/clickand_buy.yml.example` to `spec/support/clickand_buy.yml`. Now run:

    bundle exec rspec

By default, only "fast" specs will be running (the API will not be hit). In order to be able
to execute remote specs, populate the `clickand_buy.yml` file with your staging account's
authentication credentials. To run the remote specs, run the following:

    bundle exec rspec --tag remote

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
