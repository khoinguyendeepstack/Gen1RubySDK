# Ruby SDK

The official GloballyPaid Ruby client library.


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
Authorization with card
```ruby
options = {
  # Required fields
  :card_billing_address = 'card_billing_address',
  :card_billing_zipcode = 'card_billing_zipcode',
  # optional fields
  # Defaulted to ""
  :employee_id = 'employee_id',
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

Authorization with token

```ruby
options = {
  # Required
  :ccexp => "mmYY", #card expiration in mmYY
  :card_billing_address = 'card_billing_address',
  :card_billing_zipcode = 'card_billing_zipcode',
  # Optional fields
  #Defaulted to ""
  :employee_id = 'employee_id',
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








