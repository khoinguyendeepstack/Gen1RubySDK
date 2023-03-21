# Ruby SDK

The official GloballyPaid Ruby client library.


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Ruby SDK](#ruby-sdk)
  - [Requirements](#requirements)
  - [Bundler](#bundler)
  - [Manual Installation](#manual-installation)
- [Documentation](#documentation)
  - [Initialize the Client](#initialize-the-client)
  - [API](#api)
    - [Setting up a credit card](#setting-up-a-credit-card)
    - [Make a Instant Charge Sale Transaction](#make-a-instant-charge-sale-transaction)
    - [Payment requests](#payment-requests)
    - [Customer requests](#customer-requests)
    - [Payment instrument requests](#payment-instrument-requests)
  - [Testing](#testing)

<!-- /code_chunk_output -->


## Requirements

> Ruby 2.4.0 or later

> ActiveMerchant 1.110 or later

## Bundler

The library will be built as a gem and can be referenced in the Gemfile with:

```ruby
gem 'active-merchant-globally-paid-gateway'
```

## Manual Installation

The library can be also referenced locally

```ruby
gem 'active-merchant-globally-paid-gateway', :local => '/path/to/the/library'
```

or from a github repository:

```ruby
gem 'active-merchant-globally-paid-gateway', :github => 'user/repo'
```

## Example

For a working example of usage, please visit [Globally Paid Ruby SDK example](https://github.com/globallypaid/globallypaid-sdk-ruby-samples).


# Documentation


## Deepstack

## Initialize the Client

``` ruby

gateway = ActiveMerchant::Billing::Deepstack.new(
  :client_id => 'clientID',
  :api_username => 'username',
  :api_password => 'password'
)
```

### Setting up a credit card 

Validating the card automatically detects the card type.

```ruby
credit_card = ActiveMerchant::Billing::CreditCard.new(
                :first_name         => 'Bob',
                :last_name          => 'Bobsen',
                :number             => '4242424242424242',
                :month              => '8',
                :year               => Time.now.year+1,
                :verification_value => '000')
```

### Getting a token

```ruby
options = {
  #optional fields
  #Defaulted to ""
  :employee_id = 'employee_id',
  :card_billing_address = 'card_billing_address',
  :card_billing_zipcode = 'card_billing_zipcode',
  :card_billing_city = 'some city',
  :card_billing_state = 'CA',
  :card_billing_country = 'US'
}
response = gateway.getToken(credit_card, options)
token = response.params["clienttransdescription"]
```

### Authorization

```ruby
options = {
  #optional fields
  #Defaulted to ""
  :employee_id = 'employee_id',
  :card_billing_address = 'card_billing_address',
  :card_billing_zipcode = 'card_billing_zipcode',
  :card_billing_city = 'some city',
  :card_billing_state = 'CA',
  :card_billing_country = 'US'
  #shipping defaulted to ""
  :shipping =>{
    :first_name => 'John',
    :last_name => 'Doe',
    :city => 'some city',
    :zip => '12345',
    :country => 'US',
    :phone => '1234567890',
    :email => 'johnDoe@gmail.com'
  },
  #Default value "y"
  :avs => 'y',
  #Default Values "USD"
  :iso_country_code => "USD",
  :iso_currency_code => "USD",
  #Optional internal fields
  :client_info => {
    :trans_id => '12345',
    :invoice_id => '6789',
    :client_trans_description => 'testing'
  }

}
response = gateway.authorize(amount, paymentInstrument, options)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
cvvResponse = response.params["cvvresponse"]
avsResponse = response.params["avsresponse"]
# Transaction ID
transactionID = response.params["anatransactionid"]
```
### Capture

``` ruby
# Amount in dollars
amount = 10.25
# Transaction ID from Auth
response = gateway.capture(amount, transactionID)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
```

### Refund

```ruby
# Amount in dollars
amount = 10.25
# Transaction ID from Auth
response = gateway.refund(amount, transactionID)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
```



## End Deepstack


## Testing

There are two types of unit tests for each gateway.  The first are the normal unit tests, which test the normal functionality of the gateway, and use "Mocha":http://mocha.rubyforge.org/ to stub out any communications with live servers.

The second type are the remote unit tests.  These use real test accounts, if available, and communicate with the test servers of the payments gateway.  These are critical to having confidence in the implementation of the gateway.  If the gateway doesn't have a global public test account then you should remove your private test account credentials from the file before submitting your patch.

To run tests:

```bash
$ bundle install
$ bundle exec rake test:local   #Runs `test:units` and `rubocop`. All these tests should pass.
$ bundle exec rake test:remote  #Will not pass without updating test/fixtures.yml with credentials
```

To run a test suite individually:

```bash
$ bundle exec rake test:units TEST=test/unit/gateways/globally_paid_test.rb
$ bundle exec rake test:remote TEST=test/remote/gateways/remote_globally_paid_test.rb
```

To run a specific test case use the `-n` flag:

```bash
$ ruby -Itest test/remote/gateways/remote_globally_paid_test.rb -n test_successful_purchase
```

It is useful to work on remote tests first, both because they're less complex (no mocking/stubbing) and because you can capture the request/response easily which can then be copied to the unit tests. To capture the actual HTTP request sent and response received, use the `DEBUG_ACTIVE_MERCHANT` environment variable.

```bash
$ DEBUG_ACTIVE_MERCHANT=true ruby -Itest test/remote/gateways/remote_globally_paid_test.rb -n test_successful_purchase
<- "POST /api/v1/capture....
<- "<?xml version=\"1.0\" ..."
-> "HTTP/1.1 200 OK\r\n"
-> "Content-Type: text/xml;charset=ISO-8859-1\r\n"
-> "Content-Length: 954\r\n"
...
```





