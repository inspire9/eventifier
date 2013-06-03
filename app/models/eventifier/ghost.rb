require 'eventifier/ghost_mixin'

module Eventifier
  class Ghost < ActiveRecord::Base
    include Eventifier::GhostMixin

    serialize :data_hash
  end
end