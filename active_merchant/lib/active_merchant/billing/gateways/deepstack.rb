require 'json'
require 'awesome_print'
require 'base64'

require 'uri'
require 'net/http'
require 'net/https'

# require 'active_merchant/lib/active_merchant/billing/gateway.rb'

module ActiveMerchant #nodoc
    module Billing
        class DeepstackGateway < Gateway

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
            # Arguments: 
            #   creditCard: ActiveMerchant card object
            #   options: List of fields not listed in creditCard
            # Output:
            #   response.params["clienttransdescription"]: contains result token
            def getToken(creditCard, options={})
                params = {}
                params = addCredentials(params)
                params = params.merge(addPaymentInstrument(creditCard, options))
                params = addTransactionType(params, "gettoken")
                if options.key?(:employee_id)
                    params = addEmployeeID(params, options)
                end
                commit(params)
            end

            # Authorize transaction using either CreditCard or token
            # Arguments:
            #   amount: amount to authorize in dollar format
            #   paymentInstrument: either a CreditCard object or string for token
            #   options: hash of required and optional fields for authorization
            # Output:
            #   response.params["anatransactionid"] : transaction ID used for refund/charge
            #   response.params["responsecode"] : "00" for success
            #   response.params["responsetext"] : transaction message (either successful or reason why not)
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
                if options.key?(:client_info)
                    params = addClient(params, options)
                end
                # puts params.to_json
                commit(params)
            end

            # Refund amount based on transactionID
            # Arguments:
            #   amount: amount to refund in dollar format
            #   transactionID: Identifier used for transaction
            #   options: hash of required and optional fields for authorization
            # Output:
            #   response.params["responsecode"] : "00" for success
            #   response.params["responsetext"] : transaction message (either successful or reason why not)
            def refund(amount, transactionID, options = {})
                params = {}
                params = addCredentials(params)
                params = addAmount(params, amount, options)
                params = addTransactionType(params, "refund")
                params = addTransactionID(params, transactionID)
                # puts params.to_json
                commit(params)
            end

            # Capture authorized amount based on transactionID
            # Arguments:
            #   amount: amount to refund in dollar format
            #   transactionID: Identifier used for transaction
            #   options: hash of required and optional fields for authorization
            # Output:
            #   response.params["responsecode"] : "00" for success
            #   response.params["responsetext"] : transaction message (either successful or reason why not)
            def capture(amount, transactionID, options = {})
                params = {}
                params = addCredentials(params)
                params = addAmount(params, amount, options)
                params = addTransactionType(params, "capture")
                params = addTransactionID(params, transactionID)
                puts params.to_json
                commit(params)
            end

            # Take params -> create request -> send request
            # Take hash of parameters and convert into url-encoded before sending request
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
                    if response.code != "200"
                        raise "Bad request... code:  " + response.code + " message: " + response.message
                    end
                    # puts response.body
                    oResponse = parseResponse(response)
                    # puts oResponse
                    Response.new(
                        success_from(response),
                        message_from(response),
                        JSON.parse(oResponse)
                    )

                rescue ResponseError => e
                    puts "Caught error: "
                    ap e.response.message
                    Response.new(
                        e.response.code.to_i,
                        e.response.body,
                        {}
                    )
                end

            end

            # Helper functions
            # convert url-encoded response into JSON
            def parseResponse(response)
                useFullResponse = response.body[0,response.body.index("\n")]
                URI.decode_www_form(useFullResponse).to_h.to_json
            end

            def addClient(params, options)
                client = options[:client_info]
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
                        # Required Fields
                        :ccnumber => paymentInstrument.number,
                        :ccexp => "%02d%02d" % [paymentInstrument.month, paymentInstrument.year],
                        :cvv => paymentInstrument.verification_value,
                        :CCHolderFirstName => paymentInstrument.first_name,
                        :CCHolderLastName => paymentInstrument.last_name,
                        :CCBillingAddress => options[:card_billing_address],
                        :CCBillingZip => options[:card_billing_zipcode],
                        # Deepstack specific fields (not in CreditCard class)
                        :CCBillingCity => options.key?(:card_billing_city) ? options[:card_billing_city] : "",
                        :CCBillingState => options.key?(:card_billing_state) ? options[:card_billing_state] : "",
                        :CCBillingCountry => options.key?(:card_billing_country) ? options[:card_billing_country] : ""
                    }
                else
                    {
                        # Required Fields
                        :ccnumber => paymentInstrument,
                        :ccexp => options[:ccexp],
                        :CCBillingAddress => options[:card_billing_address],
                        :CCBillingZip => options[:card_billing_zipcode],
                        # :CCBillingAddress => options.key?(:card_billing_address) ? options[:card_billing_address] : "",
                        # :CCBillingZip => options.key?(:card_billing_zipcode) ? options[:card_billing_zipcode] : "",
                        # Optional Fields
                        :CCBillingCity => options.key?(:card_billing_city) ? options[:card_billing_city] : "",
                        :CCBillingState => options.key?(:card_billing_state) ? options[:card_billing_state] : "",
                        :CCBillingCountry => options.key?(:card_billing_country) ? options[:card_billing_country] : ""
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

            def success_from(response)
                return response.code != 200
            end

            def message_from(response)
                return response.body["status"]
            end
        end
    end
end