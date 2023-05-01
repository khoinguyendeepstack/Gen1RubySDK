# Ruby SDK

The official DeepStack Ruby client library.


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Ruby SDK](#ruby-sdk)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Bundling from Git](#bundling-from-git)
  - [Locally installing Gem](#locally-installing-gem)
- [Documentation](#documentation)
  - [Initialize the Client](#initialize-the-client)
  - [API](#api)
    - [Setting up a credit card](#setting-up-a-credit-card)
    - [Getting a token](#getting-a-token)
    - [Authorization](#authorization)
    - [Capture](#capture)
    - [Purchase](#purchase)
    - [Refund](#refund)
  - [Testing](#testing)

<!-- /code_chunk_output -->


## Requirements

> Ruby 2.4.0 or later


## Installation ##

## Bundling from Git ##

We can add the repo as a gem using bundler. Based on Ruby configuration, this could install the gem into a bundler folder instead of the system's gems folder meaning that programs will need to be run with `bundle exec ruby FILE.rb` so that bundler is able to use the gem.

```Gemfile 
source 'http://rubygems.org'

gem 'activemerchant', :github => 'khoinguyendeepstack/Gen1RubySDK'
gem 'rexml'
gem 'jruby-openssl', platforms: :jruby
gem 'rubocop', require: false
gem 'awesome_print'
```

```bash
bundle install
bundle exec ruby FILE.rb
```
Don't forget to include `require 'activemerchant'` in the file using the gem.

## Locally installing gem ##


Installing the gem this way places the gem directly with other gems so that bundler is not required when running scripts. 

Clone the repository and run the following to locally install the gem

``` bash
git clone https://github.com/khoinguyendeepstack/Gen1RubySDK.git
```

```bash
cd active_merchant
gem build activemerchant.gemspec
gem install ./pkg/activemerchant-1.117.0.gem
```

Alternatively we can use rake

```bash
cd active_merchant
rake install:local
```

## Known gemfile issue

If rexml is not being listed as a dependency and tests are not able to be run due to this issue, run `gem install rexml` as a temporary fix until activemerchant addresses this issue

# Documentation


## API

## Initialize the Client

``` ruby
gateway = ActiveMerchant::Billing::Deepstack.new(
  :client_id => 'clientID',
  :api_username => 'username',
  :api_password => 'password'
)
```

## API

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
  #Defaulted to ""
  :employee_id = 'employee_id',
  :billing_address => {
    #Required
    :address1 => "123 some st",
    :zip => "12345",
    #Optional
    :city => "Irvine",
    :state => "CA",
    :country => "USA"
  }
}
response = gateway.getToken(credit_card, options)
token = response.params["clienttransdescription"]
```

### Authorization

Note: Amount is specified in the cent amount i.e. 1025 => 10.25

Authorization with card
```ruby
options = {
  # Required fields
  :billing_address => {
    #Required
    :address1 => "123 some st",
    :zip => "12345",
    #Optional
    :city => "Irvine",
    :state => "CA",
    :country => "USA"
  }
  # optional fields
  # Defaulted to ""
  :employee_id = 'employee_id',
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
  #Default Values "USA/USD"
  :iso_country_code => "USA",
  :iso_currency_code => "USD",
  #Optional internal fields
  :client_info => {
    :trans_id => '12345',
    :invoice_id => '6789',
    :client_trans_description => 'testing'
  },
  :cc_ip_address => 'ip_of_cardholder',
  :device_session_id => 'device_session_id'
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

Authorization with token

```ruby
options = {
  # Required
  :ccexp => "mmYY", #card expiration in mmYY
  :billing_address => {
    #Required
    :address1 => "123 some st",
    :zip => "12345",
    #Optional
    :city => "Irvine",
    :state => "CA",
    :country => "USA"
  }
  # Optional fields
  #Defaulted to ""
  :employee_id = 'employee_id',
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
  :iso_country_code => "USA",
  :iso_currency_code => "USD",
  #Optional internal fields
  :client_info => {
    :trans_id => '12345',
    :invoice_id => '6789',
    :client_trans_description => 'testing'
  },
  :cc_ip_address => 'ip_of_cardholder',
  :device_session_id => 'device_session_id'
}
```

### Purchase

Note: Amount is specified in the cent amount i.e. 1025 => 10.25

Purchase with card
```ruby
options = {
  # Required fields
  :billing_address => {
    #Required
    :address1 => "123 some st",
    :zip => "12345",
    #Optional
    :city => "Irvine",
    :state => "CA",
    :country => "USA"
  }
  # optional fields
  # Defaulted to ""
  :employee_id = 'employee_id',
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
  :iso_country_code => "USA",
  :iso_currency_code => "USD",
  #Optional internal fields
  :client_info => {
    :trans_id => '12345',
    :invoice_id => '6789',
    :client_trans_description => 'testing'
  },
  :cc_ip_address => 'ip_of_cardholder',
  :device_session_id => 'device_session_id'
}
response = gateway.purchase(amount, paymentInstrument, options)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
cvvResponse = response.params["cvvresponse"]
avsResponse = response.params["avsresponse"]
# Transaction ID
transactionID = response.params["anatransactionid"]
```

Purchase with token

```ruby
options = {
  # Required
  :ccexp => "mmYY", #card expiration in mmYY,
  :billing_address => {
    #Required
    :address1 => "123 some st",
    :zip => "12345",
    #Optional
    :city => "Irvine",
    :state => "CA",
    :country => "USA"
  }
  # Optional fields
  #Defaulted to ""
  :employee_id = 'employee_id',
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
  :iso_country_code => "USA",
  :iso_currency_code => "USD",
  #Optional internal fields
  :client_info => {
    :trans_id => '12345',
    :invoice_id => '6789',
    :client_trans_description => 'testing'
  },
  :cc_ip_address => 'ip_of_cardholder',
  :device_session_id => 'device_session_id'
}
response = gateway.purchase(amount, paymentInstrument, options)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
cvvResponse = response.params["cvvresponse"]
avsResponse = response.params["avsresponse"]
# Transaction ID
transactionID = response.params["anatransactionid"]
```


### Capture

Note: Amount is specified in the cent amount i.e. 1025 => 10.25

``` ruby
# Amount in cents
amount = 1025
# Transaction ID from Auth
response = gateway.capture(amount, transactionID)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
```

### Void

Note: Amount is specified in the cent amount i.e. 1025 => 10.25

```ruby
# Amount in cents
amount = 1025
# Transaction ID from Auth
response = gateway.void(amount, transactionID)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
```

### Refund

Note: Amount is specified in the cent amount i.e. 1025 => 10.25

```ruby
# Amount in cents
amount = 1025
# Transaction ID from Auth
response = gateway.refund(amount, transactionID)
# Response codes
responseCode = response.params["responsecode"]
responseText = response.params["responsetext"]
```


# Testing #

The Deepstack gateway uses the built-in active-merchant testing suite

For running Deepstack specific tests follow below:

## Unit tests (no requests made) ##

From within the active_merchant folder

``` bash
 bundle exec rake test:units TEST=test/unit/gateways/deepstack_test.rb
```

## Remote tests (requests made to our sandbox endpoint) ##

```bash
 bundle exec rake test:remote TEST=test/remote/gateways/remote_deepstack_test.rb
```

## End Deepstack








