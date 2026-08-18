require_relative 'lib/wsaa/version'

Gem::Specification.new do |spec|
  spec.name          = 'wsaa-ruby'
  spec.version       = Wsaa::VERSION
  spec.authors       = ['Leandro Marcucci']
  spec.email         = ['leanucci@gmail.com']

  spec.summary       = 'Ruby client for AFIP WSAA authentication service'
  spec.description   = 'Ruby implementation of AFIP WSAA (Web Service de Autenticación y Autorización) for authenticating with Argentine tax authority web services'
  spec.homepage      = 'https://github.com/leanucci/wsaa-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'savon', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
