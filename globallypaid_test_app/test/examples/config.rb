@credentials = {
    :publishable_api_key => 'pk_test_pr9IokgZOcNd0YGLuW3unrvYvLoIkCCk', 
    :app_id => 'sk_test_3a164632-7951-4688-9d49-c9c5', 
    :shared_secret => 'u9TQah3vzkLjsiB/vB6+C9tuQhjvO8/3h+XB2YTaxr0=', 
    :sandbox => true
}

def credit_card_gp(number)
    creditcard = {}
    creditcard[:number] = number # "4847182731147117"
    creditcard[:expiration] = "0627"
    creditcard[:cvv] = "361"
    creditcard
end
  
def address(options = {})
{
    name:     'Jim Smith',
    address1: '456 My Street',
    address2: 'Apt 1',
    company:  'Widgets Inc',
    city:     'Ottawa',
    state:    'ON',
    zip:      'K1C2N6',
    country:  'CA',
    phone:    '(555)555-5555',
    fax:      '(555)555-6666'
}.update(options)
end
  
def billing_contact
billing_contact = {}
billing_contact[:first_name] = "Peco"
billing_contact[:last_name] = "Danajlovski"
billing_contact[:address] = address
billing_contact[:phone] = "070261666"
billing_contact[:email] = "peco.danajlovski@gmail.com"
billing_contact
end
  
def customer_data
    customer_data = {
        billing_contact: billing_contact,
        # address: address,
        description: 'Store Purchase',
        client_customer_id: "1474687",
        client_transaction_id: "154896575",
        client_transaction_description: "ChargeWithToken for TesterXXX3",
        client_invoice_id: "758496",
        currency_code: "USD"
    }
    customer_data
end

  # credit_card = ActiveMerchant::Billing::CreditCard.new(
#     :first_name         => 'Bob',
#     :last_name          => 'Bobsen',
#     :number             => '4242424242424242',
#     :month              => '8',
#     :year               => Time.now.year+1,
#     :verification_value => '000')  