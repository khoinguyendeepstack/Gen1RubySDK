require 'json'
require 'awesome_print'
require 'base64'

require 'uri'
require 'net/http'
require 'net/https'


module ActiveMerchant #nodoc
    module Billing
        class Deepstack < Gateway

            self.test_url = 'https://sandbox.transactions.gpgway.com/'
            self.live_url = 'some_url'
            self.supported_countries = ['US']
            self.default_currency = 'USD'
            self.supported_cardtypes = [:visa, :master, :american_express, :discover]
            self.money_format = :dollars

            def initialize(options={})
                requires!(options, :client_id, :api_username, :api_password)
                @client_id, @api_username, @api_password = options.values_at(:client_id, :api_username, :api_password)
                @isProduction = options.key?(:isProduction) ? options[:isProduction] : false
                super
            end

            #Requests
            def getJWT()
                # Implement method for getting JWT
                # Not used for server-server
            end

            # Get token representing card data
            def getToken(creditCard, options={})
                params = {}
                params = addCredentials(params)
                params = params.merge(addPaymentInstrument(creditCard, options))
                params = addTransactionType(params, "gettoken")
                if options.key?(:employee_id)
                    params = addEmployeeID(params, options)
                end
                # puts params
                commit(params)
            end

            def authorize(amount, paymentInstrument, options={})
                params = {}
                params = addCredentials(params)
                params = params.merge(addPaymentInstrument(paymentInstrument, options))
                params = addAmount(params, amount, options)
                params = addTransactionType(params, "auth")
                if options.key?(:employee_id)
                    params = addEmployeeID(params, options)
                end
                if options.key?(:shipping)
                    params = addShipping(params, options)
                end
                if options.key?(:clientInfo)
                    params = addClient(params, options)
                end
                # puts params.to_json
                commit(params)
            end

            def refund(amount, transactionID, options = {})
                params = {}
                params = addCredentials(params)
                params = addAmount(params, amount, options)
                params = addTransactionType(params, "refund")
                params = addTransactionID(params, transactionID)
                puts params.to_json
                commit(params)
            end

            def capture()

            end

            # Take params -> create request -> send request
            def commit(params)
                begin
                    headers = getHeaders()
                    myURI = @isProduction ? self.live_url : self.test_url
                    # puts myURI
                    # Unsure if this approach uses SSL handshake
                    uri = URI(myURI)
                    https = Net::HTTP.new(uri.host, uri.port)
                    https.use_ssl = true
                    req = Net::HTTP::Post.new(uri.path, init_header = headers)
                    req.body = URI.encode_www_form(params)
                    response = https.request(req)
                    puts response.body
                    oResponse = parseResponse(response)
                    puts oResponse

                rescue ResponseError => e
                    puts "ruh roh"
                end

            end

            # Helper functions

            def parseResponse(response)
                useFullResponse = response.body[0,response.body.index("\n")]
                URI.decode_www_form(useFullResponse).to_h.to_json
            end

            def addClient(params, options)
                client = options[:clientInfo]
                params.merge({
                    :clienttransid => client.key?(:trans_id) ? client[:trans_id] : "",
                    :clientinvoiceid => client.key?(:invoice_id) ? client[:invoice_id] : "",
                    :clienttransdescription => client.key?(:client_trans_description) ? client[:client_trans_description] : ""
                })
            end

            def addAmount(params, amount)
                params.merge({
                    :amount => amount
                })
            end

            def addAmount(params, amount, options)
                # Want to add amount here and also CountryCode and CurrencyCode (defaulted to US)
                params.merge({
                    :amount => amount,
                    :isocountrycode => options.key?(:iso_country_code) ? options[:iso_country_code] : "USD",
                    :isocurrencycode => options.key?(:iso_currency_code) ? options[:iso_currency_code] : "USD",
                    :avs => options.key?(:avs) ? options[:avs] : "y"
                })
            end

            def addShipping(params, options)
                shipping = options[:shipping]
                params.merge({
                    :ShippingFirstName => shipping.key?(:first_name) ? shipping[:first_name] : "",
                    :ShippingLastName => shipping.key?(:last_name) ? shipping[:last_name] : "",
                    :ShippingCity => shipping.key?(:city) ? shipping[:city] : "",
                    :ShippingZip => shipping.key?(:zip) ? shipping[:zip] : "",
                    :ShippingCountry => shipping.key?(:country) ? shipping[:country] : "",
                    :ShippingPhone => shipping.key?(:phone) ? shipping[:phone] : "",
                    :ShippingEmail => shipping.key?(:email) ? shipping[:email] : ""
                })
            end

            def addCredentials(params)
                params.merge({
                    :clientid => @client_id,
                    :apiusername => @api_username,
                    :apipassword => @api_password
                })
            end
            def addPaymentInstrument(paymentInstrument, options)
                if paymentInstrument.instance_of?(CreditCard)
                    {
                    :ccnumber => paymentInstrument.number,
                    :ccexp => "%02d%02d" % [paymentInstrument.month, paymentInstrument.year],
                    :cvv => paymentInstrument.verification_value,
                    :CCHolderFirstName => paymentInstrument.first_name,
                    :CCHolderLastName => paymentInstrument.last_name,
                    # Deepstack specific fields (not in CreditCard class)
                    :CCBillingAddress => options.key?(:card_billing_address) ? options[:card_billing_address] : "",
                    :CCBillingZip => options.key?(:card_billing_zipcode) ? options[:card_billing_zipcode] : ""
                    }
                else
                    {

                    }
                end
            end

            def addTransactionID(params, transactionID)
                params.merge({
                    :anatransactionid => transactionID
                })
            end

            def addEmployeeID(params, options)
                params.merge({:employeeid => options[:employee_id]})
            end

            def getHeaders()
                {
                    "Content-Type" => "application/x-www-form-urlencoded",
                    "Accept" => "*/*" 
                }
            end

            def addTransactionType(params, type)
                params.merge({"transactiontype" => type})
            end

        end
    end
end