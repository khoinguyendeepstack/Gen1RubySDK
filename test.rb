
require 'activemerchant'

gateway = ActiveMerchant::Billing::DeepstackGateway.new(
    :client_id => '1003',
    :api_username => 'GPF1e74ujhy',
    :api_password => 'GPikuyujhy'
)

creditCard = ActiveMerchant::Billing::CreditCard.new(
    :first_name => "John",
    :last_name => "Doe",
    :number => "4120469701788378",
    :month => "01",
    :year => "27",
    :verification_value => "999"
)

options = {
    :card_billing_address => "123 Main St",
    :card_billing_zipcode => '12345',
}

response = gateway.getToken(creditCard, options)
puts response.params

# puts("Hello world")
