# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email-fetch-and-process/version'

Gem::Specification.new do |spec|
  spec.name          = 'email-fetch-and-process'
  spec.version       = EmailFetchAndProcess::VERSION
  spec.authors       = ['Kirk Haines']
  spec.email         = ['wyhaines@gmail.com']

  spec.summary       = 'Simple utility gem for pulling emails and processing them.'
  spec.description   = 'This is an extraction of a useful pattern for pulling emails and their attached files and processing them.'
  spec.homepage      = 'https://github.com/wyhaines/email-fetch-and-process'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'mail'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
