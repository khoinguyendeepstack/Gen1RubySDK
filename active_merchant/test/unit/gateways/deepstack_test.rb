require './test/test_helper'
require './lib/active_merchant/billing/gateways/Deepstack'
require 'yaml'
require 'json'

class DeepstackTest < Test::Unit::TestCase
    def setup
        hash = Psych.load_file('./test/fixtures.yml', aliases: true)
        @gateway = ActiveMerchant::Billing::Deepstack.new(
            :client_id => hash['deepstack']['client_id'],
            :api_username => hash['deepstack']['api_username'],
            :api_password => hash['deepstack']['api_password']
        )
        @credit_card = ActiveMerchant::Billing::CreditCard.new(
            :first_name => hash['deepstack']['firstName'],
            :last_name => hash['deepstack']['lastName'],
            :number => hash['deepstack']['number'],
            :month => hash['deepstack']['month'],
            :year => hash['deepstack']['year'],
            :verification_value => hash['deepstack']['cvv']
        )
        @options = {
            :card_billing_address => "123 Main St",
            :card_billing_zipcode => '12345',
            :merchant_uuid => hash['deepstack']['merchant_uuid'],
            :employee_id => hash['deepstack']['employee_id']
        }
    end

    def test_setup
        # @gateway.getToken(@credit_card, @options)
        # @gateway.authorize(10.25,@credit_card, @options)
        assert 1==1
    end

    def test_auth
        shipping = {
            :shipping => {
                :first_name => "",
                :last_name => "",
                :city => "",
                :zip => "",
                :country => "",
                :phone => "",
                :email => ""
            }
        }
        testOptions = @options.merge(shipping)
        client = {
            :clientInfo => {
                :trans_id => "1237485",
                :invoice_id => "125478",
                :client_trans_description => "sale transaction"
            }
        }
        testOptions = testOptions.merge(client)
        @gateway.authorize(10.25, @credit_card, testOptions)
    end

    def test_refund
        transactionID = "1918436551"
        @gateway.refund(0.02, transactionID, @options)
        assert 1==1 
    end
end