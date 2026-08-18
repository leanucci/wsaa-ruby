# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Writing Convention

Use ASD-STE100 (Simplified Technical English) for all communication:

- Write short sentences (20 words maximum)
- Use active voice
- Use approved vocabulary only
- Use one meaning per word
- Write instructions as commands

## Coding Conventions

### RDoc Documentation

Add RDoc comments to all public classes and methods. Follow this format:

```ruby
##
# Short description of the class or method.
#
# @param name [Type] Description of the parameter.
# @return [Type] Description of the return value.
# @raise [ErrorClass] Description of when this error occurs.
#
# @example
#   result = method_name(arg)
#   # => expected output
```

Apply this requirement to all new code and modified code.

### Git Commits

- Make commits atomic: include only one coherent change or fix
- Do not mix unrelated work in a single commit
- Write succinct commit messages that describe the change

## Project Overview

wsaa-ruby is a Ruby gem for authenticating with AFIP's WSAA (Web Service de Autenticación y Autorización). It handles the login process to obtain TOKEN and SIGN credentials needed to call other AFIP services like WSFE (electronic invoicing).

## Build & Test Commands

```bash
bundle install          # Install dependencies
bundle exec rspec       # Run all RSpec tests
bundle exec rake        # Run default task (specs)
```

Run a single test file:
```bash
bundle exec rspec spec/wsaa/client_spec.rb
```

## Required Environment

- Ruby >= 2.7.0 (see gemspec)
- Valid AFIP X.509 certificate and private key
- Certificate must be registered with AFIP for the target service

## Architecture

### Core Classes

- **`Wsaa`** (`lib/wsaa.rb`) - Main module with configuration and authentication entry points
- **`Wsaa::Client`** (`lib/wsaa/client.rb`) - Orchestrates the authentication flow
- **`Wsaa::Tra`** (`lib/wsaa/tra.rb`) - Builds the Ticket de Requerimiento de Acceso XML
- **`Wsaa::CmsSigner`** (`lib/wsaa/cms_signer.rb`) - Signs TRA using OpenSSL PKCS#7
- **`Wsaa::Credentials`** (`lib/wsaa/credentials.rb`) - Immutable value object for TOKEN/SIGN
- **`Wsaa::CredentialStore`** (`lib/wsaa/credential_store.rb`) - File-based credential caching
- **`Wsaa::Configuration`** (`lib/wsaa/configuration.rb`) - Configuration with validation
- **`Wsaa::Errors`** (`lib/wsaa/errors.rb`) - Custom exceptions

### Authentication Flow

1. `Wsaa.authenticate` checks for cached credentials in `CredentialStore`
2. If no valid cache, builds TRA XML with service name and time boundaries
3. Signs TRA using CMS/PKCS#7 with certificate and private key
4. Calls WSAA `loginCms` SOAP operation via Savon
5. Parses response to extract TOKEN and SIGN
6. Caches credentials for reuse until expiration

### SOAP Communication

Uses Savon ~> 2.0 for AFIP web services:
- **Testing (Homologación)**: `https://wsaahomo.afip.gov.ar/ws/services/LoginCms`
- **Production**: `https://wsaa.afip.gov.ar/ws/services/LoginCms`

## Usage Example

```ruby
require 'wsaa'

Wsaa.configure do |config|
  config.pkey = 'path/to/private_key'
  config.cert = 'path/to/certificate'
  config.service = 'wsfe'
  config.environment = :testing  # or :production
end

credentials = Wsaa.authenticate
credentials.token  # => "PD94bWwg..."
credentials.sign   # => "GGG2XMe..."
```

## Key Dependencies

- **savon** (~> 2.0) - SOAP client
- **rack** (~> 2.0) - Pinned for httpi compatibility
- **openssl** - Ruby stdlib, for PKCS#7 signing
- **rexml** - Ruby stdlib, for XML building

## Documentation

- [WSAA Technical Specification (PDF)](https://www.afip.gov.ar/ws/WSAA/Especificacion_Tecnica_WSAA_1.2.0.pdf)
