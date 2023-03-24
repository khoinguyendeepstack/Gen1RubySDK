# Dir.glob('./active_merchant/**/*.rb')
require 'activemerchant'

@gateway = ActiveMerchant::Billing::Deepstack.new(
    :client_id => '123',
    :api_username => '123',
    :api_password => '123'
)
puts("Hello world")

# gateway = ActiveMerchant::Billing::GloballyPaidGateway.new(
#     :publishable_api_key => 'T0FL5VDNQRK0V6H1Z6S9H2WRP8VKIVWO', 
#     :app_id => '6652820b-6a7a-4d36-bc32-786e49da1cbd', 
#     :shared_secret => 'ME1uVox0hrk7i87e7kbvnID38aC2U3X8umPH0D+BsVA=', 
#     :sandbox => true)