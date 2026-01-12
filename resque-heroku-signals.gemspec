# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "resque-heroku-signals"
  spec.version       = '3.0.0'
  spec.authors       = ["Michael Bianco"]
  spec.email         = ["mike@mikebian.co"]

  spec.summary       = "Patch resque to be compatible with Heroku"
  spec.homepage      = "https://github.com/resque/resque-heroku-signals"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata['rubygems_mfa_required'] = 'true'

  # strict resque dependency is intentional
  spec.add_dependency "resque", "3.0.0"

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end
