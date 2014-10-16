# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "eventifier"
  s.version     = '0.1.3'
  s.authors     = ["Nathan Sampimon", "Peter Murray", "Pat Allan"]
  s.email       = ["nathan@inspire9.com"]
  s.homepage    = "http://github.com/inspire9/eventifier"
  s.summary     = "Event tracking and notifying for active record models"
  s.description = "Tracks and logs events and sends notifications of events on Active Record models."
  s.license     = 'MIT'

  s.rubyforge_project = "eventifier"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails',           '>= 4.0.3'
  s.add_runtime_dependency "bson_ext"
  s.add_runtime_dependency 'haml-rails',      '~> 0.4'
  s.add_runtime_dependency 'coffee-rails',    '~> 4.0.0'
  s.add_runtime_dependency 'compass-rails'
  s.add_runtime_dependency 'multi_json',      '>= 1.7.4'
  s.add_runtime_dependency 'jbuilder',        '>= 2.0.4'
  s.add_runtime_dependency 'rails-observers', '~> 0.1.2'
  s.add_runtime_dependency 'sliver',          '~> 0.0.3'

  s.add_development_dependency 'combustion',  '~> 0.5.0'
  s.add_development_dependency 'fabrication', '~> 2.11.0'
  s.add_development_dependency "pg"
  s.add_development_dependency 'rspec-rails', '~> 3.0.0.beta2'
end
