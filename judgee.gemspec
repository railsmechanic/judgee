# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'judgee/version'

Gem::Specification.new do |gem|
  gem.name          = "judgee"
  gem.version       = Judgee::VERSION
  gem.authors       = ["Railsmechanic"]
  gem.email         = ["info@railsmechanic.de"]
  gem.description   = %q{A simple Bayesian Classifier with additive smoothing and its focus on performance.}
  gem.summary       = %q{Judgee is a simple Bayesian Classifier with additive smoothing, which uses Redis for persistance.}
  gem.homepage      = "https://github.com/railsmechanic/judgee"
  gem.homepage      = "https://github.com/railsmechanic/judgee"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  
  # Regular dependencies
  gem.add_dependency "redis"
  
  # Development dependencies
  gem.add_development_dependency "rspec"
  
end
