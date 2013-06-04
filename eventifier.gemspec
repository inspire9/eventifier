# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "eventifier"
  s.version     = '0.0.7'
  s.authors     = ["Nathan Sampimon", "Peter Murray"]
  s.email       = ["nathan@inspire9.com"]
  s.homepage    = "http://github.com/inspire9/eventifier"
  s.summary     = "Event tracking and notifying for active record models"
  s.description = "Tracks and logs events and sends notifications of events on Active Record models."

  s.rubyforge_project = "eventifier"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails',           '~> 3.2.0'
  s.add_runtime_dependency "bson_ext"
  s.add_runtime_dependency 'haml-rails',      '~> 0.4'
  s.add_runtime_dependency 'multi_json',      '~> 1.7.4'

  s.add_development_dependency 'combustion',  '~> 0.5.0'
  s.add_development_dependency 'fabrication', '~> 2.7.1'
  s.add_development_dependency "pg"
  s.add_development_dependency 'rspec-rails', '~> 2.13.2'
end
