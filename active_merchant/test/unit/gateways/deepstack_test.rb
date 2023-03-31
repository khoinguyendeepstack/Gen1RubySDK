require './test/test_helper'
require './lib/active_merchant/billing/gateways/Deepstack'
require 'yaml'
require 'json'

class DeepstackTest < Test::Unit::TestCase
    def setup
        hash = Psych.load_file('./test/fixtures.yml', aliases: true)
        @gateway = ActiveMerchant::Billing::DeepstackGateway.new(
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
        response = @gateway.getToken(@credit_card, @options)
        assert_success response
        # puts response.params["responsecode"]
        assert response.params["responsecode"] == "00"
        response = @gateway.getToken(@credit_card)
        assert response.params["responsecode"] == "00"
        # puts response.params["clienttransdescription"]
        # @gateway.authorize(10.25,@credit_card, @options)
        assert_success response
    end

    def test_auth
        # shipping = {
        #     :shipping => {
        #         :first_name => "",
        #         :last_name => "",
        #         :city => "",
        #         :zip => "",
        #         :country => "",
        #         :phone => "",
        #         :email => ""
        #     }
        # }
        # testOptions = @options.merge(shipping)


        response = @gateway.authorize(10.25, @credit_card, @options)
        assert response.params["responsecode"] == "00"

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

        #Test auth with shipping
        response = @gateway.authorize(10.25, @credit_card, testOptions)
        assert response.params["responsecode"] == "00"


        # Test auth with shipping + client info
        client = {
            :client_info => {
                :trans_id => "1237485",
                :invoice_id => "125478",
                :client_trans_description => "sale transaction"
            }
        }
        testOptions = testOptions.merge(client)
        response = @gateway.authorize(10.25, @credit_card, testOptions)
        assert_success response
        assert response.params["responsecode"] == "00"


        testOptions = testOptions.merge({
            :ccexp => "0127"
        })
        token = @gateway.getToken(@credit_card, @options).params["clienttransdescription"]
        response = @gateway.authorize(10.25, token, testOptions)
        assert_success response
        puts response.params.to_json
        assert response.params["responsecode"] == "00"

    end

    def test_refund
        transactionID = "1918436551"
        response = @gateway.refund(0.02, transactionID, @options)
        assert_success response
        assert response.params["responsecode"] == "00" 
    end

    def test_capture
        transactionID = "1918436551"
        response = @gateway.refund(10.25, transactionID)
        assert_success response
        assert response.params["responsecode"] == "00"
    end
end