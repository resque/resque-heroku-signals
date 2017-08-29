# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "resque-heroku-signals"
  spec.version       = '1.27.4.2'
  spec.authors       = ["Michael Bianco"]
  spec.email         = ["mike@suitesync.io"]

  spec.summary       = "Patch resque to be compatible with the Heroku platform"
  spec.homepage      = "https://github.com/iloveitaly/resque-heroku-signals"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "resque", "1.27.4"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
