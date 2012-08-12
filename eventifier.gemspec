# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "eventifier/version"

Gem::Specification.new do |s|
  s.name        = "eventifier"
  s.version     = Eventifier::VERSION
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

  s.add_development_dependency  "activerecord"
  s.add_development_dependency  "mongoid"
  s.add_runtime_dependency      "actionmailer"
  s.add_development_dependency  "fabrication"
  s.add_development_dependency  "database_cleaner"
  s.add_development_dependency  "pg"
  s.add_development_dependency  "rspec"

  s.add_runtime_dependency "activerecord"
  s.add_runtime_dependency "bson_ext"
  s.add_runtime_dependency "mongoid"
  s.add_runtime_dependency "actionmailer"
end
