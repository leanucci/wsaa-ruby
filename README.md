# WSAA Ruby

Ruby client for AFIP's WSAA (Web Service de Autenticación y Autorización).

WSAA is the authentication service required to access AFIP's web services in Argentina. This gem handles the login process to obtain TOKEN and SIGN credentials needed to call other AFIP services like WSFE (electronic invoicing).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wsaa-ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install wsaa-ruby
```

## Usage

```ruby
require 'wsaa'

# Configure the client
Wsaa.configure do |config|
  config.pkey = '/path/to/private_key.pem'
  config.cert = '/path/to/certificate.crt'
  config.environment = :production  # or :testing for homologation
  config.service = 'wsfe'           # the service you want to access
end

# Get authentication credentials
credentials = Wsaa.authenticate

credentials.token  # => "PD94bWwg..."
credentials.sign   # => "dGhpcyBp..."
```

## Documentation

- [WSAA Technical Specification (PDF)](https://www.afip.gov.ar/ws/WSAA/Especificacion_Tecnica_WSAA_1.2.0.pdf)

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
