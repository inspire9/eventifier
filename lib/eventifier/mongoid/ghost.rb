require 'eventifier/ghost_mixin'

module Eventifier
  class Ghost
    include Mongoid::Document
    include Mongoid::Timestamps
    include Eventifier::GhostMixin

    field :ghost_id, :type => BSON::ObjectId
    field :ghost_class, :type => String
    field :data_hash, :type => Hash

    index({ ghost_class: 1, ghost_id: 1 })
  end
end