lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_merchant/clickand_buy/version'

Gem::Specification.new do |gem|
  gem.name          = 'activemerchant-clickandbuy'
  gem.version       = ActiveMerchant::ClickandBuy::VERSION
  gem.authors       = ['Olek Janiszewski']
  gem.email         = ['olek.janiszewski@gmail.com']
  gem.description   = %q{This gem provides integration of ClickandBuy with Active Merchant}
  gem.summary       = %q{Integration of ClickandBuy with Active Merchant}
  gem.homepage      = "https://github.com/exviva/activemerchant-clickandbuy"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'activemerchant'

  gem.add_development_dependency 'rspec'
end
